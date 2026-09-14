import Foundation

public class AuthenticatedHTTPClientDecorator: HTTPClient {
    public enum AuthenticationPolicyResult {
        case authenticated
        case needsRefresh(onErrorMessage: String?)
        case logout(message: String?)
    }

    public typealias EnrichRequestWithToken = (URLRequest, String) -> URLRequest
    public typealias AuthenticationPolicy = ((Data, HTTPURLResponse)) -> AuthenticationPolicyResult

    private let decoratee: HTTPClient
    private let accessTokenStorage: any Storage<String>
    private let refreshTokenStorage: any Storage<String>
    private let tokenRefresher: TokenRefresher
    private let onNotAuthenticated: ((String?) -> Void)?
    private let enrichRequestWithToken: EnrichRequestWithToken
    private let isAuthenticated: AuthenticationPolicy
    private let session: AuthenticationSession

    public var authenticationSession: AuthenticationSession { session }

    public init(
        decoratee: HTTPClient,
        accessTokenStorage: any Storage<String>,
        refreshTokenStorage: any Storage<String>,
        tokenRefresher: TokenRefresher,
        onNotAuthenticated: ((String?) -> Void)? = nil,
        enrichRequestWithToken: @escaping EnrichRequestWithToken,
        isAuthenticated: @escaping AuthenticationPolicy,
        authenticationSession: AuthenticationSession = .shared
    ) {
        self.decoratee = decoratee
        self.accessTokenStorage = accessTokenStorage
        self.refreshTokenStorage = refreshTokenStorage
        self.tokenRefresher = tokenRefresher
        self.onNotAuthenticated = onNotAuthenticated
        self.enrichRequestWithToken = enrichRequestWithToken
        self.isAuthenticated = isAuthenticated
        self.session = authenticationSession
    }

    public func dispatch(_ request: URLRequest, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        let task = CompositeHTTPClientTask()
        let result = AuthenticationCompletion(completion)
        let snapshot = session.synchronized { () -> (UUID, String?) in
            let token = session.isActive ? accessTokenStorage.get() : nil
            return (session.identifier, token)
        }
        let registration = session.onInvalidation(of: snapshot.0) { [weak task] in
            task?.cancel()
            result.finish(.failure(ServiceError.cancelled))
        }
        task.add(AuthenticationCancellation { [session] in
            session.removeInvalidationHandler(registration)
            result.finish(.failure(ServiceError.cancelled))
        })
        result.onFinish { [session, weak task] in
            session.removeInvalidationHandler(registration)
            task?.finish()
        }

        guard let token = snapshot.1, !token.isEmpty else {
            result.finish(.failure(ServiceError.internal))
            handleUnauthenticated(message: nil, sessionID: snapshot.0, token: snapshot.1)
            return task
        }
        dispatch(request, token: token, sessionID: snapshot.0, canRefresh: true, task: task, result: result)
        return task
    }

    private func dispatch(_ request: URLRequest, token: String, sessionID: UUID, canRefresh: Bool,
                          task: CompositeHTTPClientTask, result: AuthenticationCompletion<HTTPClient.Result>) {
        guard !task.isCancelled, !result.isFinished, session.identifier == sessionID else { return }
        let child = decoratee.dispatch(enrichRequestWithToken(request, token)) { [weak self, task] response in
            guard let self, !task.isCancelled, !result.isFinished else { return }
            let belongsToSession = self.session.synchronized {
                self.session.identifier == sessionID &&
                (self.accessTokenStorage.get() == token ||
                 (self.session.refreshedAccessToken != nil && self.accessTokenStorage.get() == self.session.refreshedAccessToken))
            }
            guard belongsToSession else {
                result.finish(.failure(ServiceError.cancelled))
                return
            }
            switch response {
            case .failure:
                result.finish(response)
            case .success(let value):
                switch self.isAuthenticated(value) {
                case .authenticated:
                    result.finish(response)
                case .logout(let message):
                    result.finish(.failure(ServiceError.internal))
                    self.handleUnauthenticated(message: message, sessionID: sessionID, token: token)
                case .needsRefresh(let message):
                    guard canRefresh else {
                        result.finish(.failure(ServiceError.internal))
                        self.handleUnauthenticated(message: message, sessionID: sessionID, token: token)
                        return
                    }
                    self.refreshToken(for: token, sessionID: sessionID, message: message, completion: { [weak self, task] tokens in
                        guard let self, !task.isCancelled, !result.isFinished else { return }
                        guard let tokens else {
                            result.finish(.failure(ServiceError.internal))
                            return
                        }
                        self.dispatch(request, token: tokens.accessToken, sessionID: sessionID, canRefresh: false, task: task, result: result)
                    }, compositeTask: task)
                }
            }
        }
        task.add(child)
    }

    public func refreshToken(message: String? = nil, completion: ((Tokens?) -> Void)?, compositeTask: CompositeHTTPClientTask) {
        let snapshot = session.synchronized { (session.identifier, accessTokenStorage.get()) }
        refreshToken(for: snapshot.1, sessionID: snapshot.0, message: message, completion: completion, compositeTask: compositeTask)
    }

    public func refreshToken(for accessToken: String?, sessionID: UUID? = nil, message: String? = nil,
                             completion: ((Tokens?) -> Void)?, compositeTask: CompositeHTTPClientTask) {
        let expectedSession = sessionID ?? session.identifier
        let result = AuthenticationCompletion<Tokens?> { completion?($0) }
        let waiterID = UUID()
        var start: AuthenticationRefresh?
        var immediate: Tokens?
        var shouldComplete = false
        session.synchronized {
            guard !compositeTask.isCancelled, session.identifier == expectedSession,
                  session.isActive,
                  let current = accessTokenStorage.get(), !current.isEmpty,
                  !session.hasHandledUnauthenticated else {
                shouldComplete = true
                return
            }
            if current != accessToken {
                // Only tokens produced by this session's refresh may retry an
                // old response. A token from another login must not be used.
                if current == session.refreshedAccessToken {
                    immediate = Tokens(accessToken: current, refreshToken: refreshTokenStorage.get())
                }
                shouldComplete = true
                return
            }
            let operation: AuthenticationRefresh
            if let ongoing = session.refresh {
                operation = ongoing
            } else {
                operation = AuthenticationRefresh(sessionID: expectedSession, accessToken: current, refreshToken: refreshTokenStorage.get(), refresher: tokenRefresher)
                session.refresh = operation
                start = operation
            }
            operation.waiters.append(.init(id: waiterID, completion: { [compositeTask] tokens in
                result.finish(compositeTask.isCancelled ? nil : tokens)
            }))
        }
        if shouldComplete {
            session.deliver([{ result.finish(compositeTask.isCancelled ? nil : immediate) }])
            return
        }
        compositeTask.add(AuthenticationCancellation { [session] in
            let abandoned = session.synchronized { () -> CompositeHTTPClientTask? in
                guard let refresh = session.refresh else { return nil }
                refresh.waiters.removeAll { $0.id == waiterID }
                guard refresh.waiters.isEmpty else { return nil }
                session.refresh = nil
                return refresh.task
            }
            session.deliver([{
                abandoned?.cancel()
                result.finish(nil)
            }])
        })
        guard let operation = start else { return }
        // Starting the refresher reads/maps the refresh credential synchronously.
        // Keep that read in the same transaction as its session snapshot.
        let refreshTask = session.synchronized { () -> HTTPClientTask? in
            guard session.refresh === operation else { return nil }
            return operation.refresher.refreshTask { [session, accessTokenStorage, refreshTokenStorage, onNotAuthenticated] response in
                Self.completeRefresh(operation, with: response, message: message, session: session,
                                     accessTokenStorage: accessTokenStorage, refreshTokenStorage: refreshTokenStorage,
                                     onNotAuthenticated: onNotAuthenticated)
            }
        }
        if let refreshTask { operation.task.add(refreshTask) }
    }

    public func invalidateAuthentication(message: String? = nil, sessionID: UUID, accessToken: String? = nil) {
        let token = accessToken ?? session.synchronized { accessTokenStorage.get() }
        handleUnauthenticated(message: message, sessionID: sessionID, token: token)
    }

    private static func completeRefresh(_ operation: AuthenticationRefresh, with response: Result<Tokens, ServiceError>, message: String?,
                                        session: AuthenticationSession, accessTokenStorage: any Storage<String>,
                                        refreshTokenStorage: any Storage<String>, onNotAuthenticated: ((String?) -> Void)?) {
        var tokens: Tokens?
        var waiters: [AuthenticationRefresh.Waiter] = []
        var notify = false
        var invalidations: [() -> Void] = []
        var notificationSession: UUID?
        session.synchronized {
            guard session.refresh === operation else { return }
            defer {
                waiters = operation.waiters
                if session.refresh === operation { session.refresh = nil }
            }
            guard session.identifier == operation.sessionID,
                  !session.hasHandledUnauthenticated,
                  accessTokenStorage.get() == operation.accessToken,
                  refreshTokenStorage.get() == operation.refreshToken else { return }
            if case .success(let refreshed) = response, !refreshed.accessToken.isEmpty {
                if let refresh = refreshed.refreshToken, !refresh.isEmpty {
                    refreshTokenStorage.set(model: refresh)
                    guard session.identifier == operation.sessionID,
                          accessTokenStorage.get() == operation.accessToken else { return }
                    if refreshTokenStorage.get() != refresh {
                        notify = clearCredentialsLocked(session: session, access: accessTokenStorage, refresh: refreshTokenStorage)
                        if notify {
                            invalidations = session.endAuthenticationLocked()
                            notificationSession = session.identifier
                        }
                        return
                    }
                }
                accessTokenStorage.set(model: refreshed.accessToken)
                guard session.identifier == operation.sessionID else { return }
                if accessTokenStorage.get() == refreshed.accessToken {
                    session.refreshedAccessToken = refreshed.accessToken
                    session.refreshedRefreshToken = refreshTokenStorage.get()
                    tokens = refreshed
                    return
                }
            }
            notify = clearCredentialsLocked(session: session, access: accessTokenStorage, refresh: refreshTokenStorage)
            if notify {
                invalidations = session.endAuthenticationLocked()
                notificationSession = session.identifier
            }
        }
        session.deliver(invalidations + [{
            if notify, session.identifier == notificationSession { onNotAuthenticated?(message) }
            waiters.forEach { $0.completion(tokens) }
        }])
    }

    private static func clearCredentialsLocked(session: AuthenticationSession, access: any Storage<String>, refresh: any Storage<String>) -> Bool {
        guard !session.hasHandledUnauthenticated else { return false }
        session.hasHandledUnauthenticated = true
        session.invalidatedAccessToken = access.get()
        let sessionID = session.identifier
        access.clear()
        guard session.identifier == sessionID else { return false }
        refresh.clear()
        return session.identifier == sessionID
    }

    private func handleUnauthenticated(message: String?, sessionID: UUID, token: String?) {
        var invalidations: [() -> Void] = []
        var notificationSession: UUID?
        let notify = session.synchronized { () -> Bool in
            guard session.identifier == sessionID, accessTokenStorage.get() == token else { return false }
            let notify = Self.clearCredentialsLocked(session: session, access: accessTokenStorage, refresh: refreshTokenStorage)
            if notify {
                invalidations = session.endAuthenticationLocked()
                notificationSession = session.identifier
            }
            return notify
        }
        session.deliver(invalidations + [{
            if notify, self.session.identifier == notificationSession { self.onNotAuthenticated?(message) }
        }])
    }
}

final class AuthenticationCancellation: HTTPClientTask {
    private let lock = NSLock()
    private var action: (() -> Void)?

    init(_ action: @escaping () -> Void) { self.action = action }
    func resume() {}
    func cancel() {
        lock.lock()
        let callback = action
        action = nil
        lock.unlock()
        callback?()
    }
}

final class AuthenticationCompletion<Value> {
    private let lock = NSLock()
    private var completion: ((Value) -> Void)?
    private var finishAction: (() -> Void)?
    var isFinished: Bool {
        lock.lock()
        defer { lock.unlock() }
        return completion == nil
    }

    init(_ completion: @escaping (Value) -> Void) { self.completion = completion }
    func onFinish(_ action: @escaping () -> Void) {
        lock.lock()
        let finished = completion == nil
        if !finished { finishAction = action }
        lock.unlock()
        if finished { action() }
    }

    func finish(_ result: Value) {
        lock.lock()
        let callback = completion
        completion = nil
        let action = finishAction
        finishAction = nil
        lock.unlock()
        guard let callback else { return }
        action?()
        callback(result)
    }
}
