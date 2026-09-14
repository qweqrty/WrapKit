import Foundation

/// Share one session between clients that use the same credentials.
public final class AuthenticationSession {
    public static let shared = AuthenticationSession()

    // Synchronous HTTPClient/Storage APIs also run on older deployment targets.
    // All session state and credential mutations are serialized by this lock.
    private let lock = NSRecursiveLock()
    private var currentIdentifier = UUID()
    private var active = true
    private var invalidationHandlers: [UUID: () -> Void] = [:]
    private var lockDepth = 0
    private var deferredCallbacks: [() -> Void] = []
    struct Refresh {
        let id = UUID()
        let sessionID: UUID
        let accessToken: String
        let refreshToken: String?
        let refresher: TokenRefresher
        var waiters: [(id: UUID, completion: (Tokens?) -> Void)] = []
        let task = CompositeHTTPClientTask()
    }

    var refresh: Refresh?
    var hasHandledUnauthenticated = false
    var refreshedAccessToken: String?
    var refreshedRefreshToken: String?
    var invalidatedAccessToken: String?

    public init() {}

    public var identifier: UUID { synchronized { currentIdentifier } }
    public var isRefreshing: Bool { synchronized { refresh != nil } }
    public var isActive: Bool { synchronized { active } }

    public func isCurrentRefresh(accessToken: String?, refreshToken: String?) -> Bool {
        synchronized {
            active && refreshedAccessToken != nil && refreshedAccessToken == accessToken && refreshedRefreshToken == refreshToken
        }
    }

    public func readCredentials<T>(_ read: () -> T) -> (sessionID: UUID, value: T, isActive: Bool) {
        synchronized { (currentIdentifier, read(), active) }
    }

    /// Use for login/logout credential writes. Work started by the previous
    /// session cannot persist tokens or continue requests in the new session.
    public func updateCredentials(_ update: () -> Void) {
        _ = changeCredentials(ifCurrent: nil, active: true, update)
    }

    @discardableResult
    public func updateCredentials(ifCurrent sessionID: UUID, _ update: () -> Void) -> Bool {
        changeCredentials(ifCurrent: sessionID, active: true, update)
    }

    public func invalidateCredentials(_ clear: () -> Void) {
        _ = changeCredentials(ifCurrent: nil, active: false, clear)
    }

    @discardableResult
    public func invalidateCredentials(ifCurrent sessionID: UUID, _ clear: () -> Void) -> Bool {
        changeCredentials(ifCurrent: sessionID, active: false, clear)
    }

    private func changeCredentials(ifCurrent sessionID: UUID?, active: Bool, _ update: () -> Void) -> Bool {
        synchronized {
            guard sessionID == nil || sessionID == currentIdentifier else { return false }
            currentIdentifier = UUID()
            self.active = active
            hasHandledUnauthenticated = !active
            refreshedAccessToken = nil
            refreshedRefreshToken = nil
            invalidatedAccessToken = nil
            let pending = invalidateLocked()
            deferredCallbacks.append(contentsOf: pending)
            update()
            return true
        }
    }

    @discardableResult
    public func onInvalidation(of sessionID: UUID, perform action: @escaping () -> Void) -> UUID {
        let id = UUID()
        let invalid = synchronized { () -> Bool in
            guard sessionID == currentIdentifier else { return true }
            invalidationHandlers[id] = action
            return false
        }
        if invalid { deliver([action]) }
        return id
    }

    public func removeInvalidationHandler(_ id: UUID) {
        synchronized { invalidationHandlers[id] = nil }
    }

    func synchronized<T>(_ action: () -> T) -> T {
        lock.lock()
        lockDepth += 1
        let result = action()
        lockDepth -= 1
        let callbacks = lockDepth == 0 ? deferredCallbacks : []
        if lockDepth == 0 { deferredCallbacks.removeAll() }
        lock.unlock()
        callbacks.forEach { $0() }
        return result
    }

    // Storage publishers may reenter the session while a credential write is
    // in progress. Deliver lifecycle callbacks after the outer transaction.
    func deliver(_ callbacks: [() -> Void]) {
        synchronized { deferredCallbacks.append(contentsOf: callbacks) }
    }

    func invalidateLocked() -> [() -> Void] {
        let refreshTask = refresh?.task
        let waiters = refresh?.waiters.map { waiter in { waiter.completion(nil) } } ?? []
        refresh = nil
        let handlers = Array(invalidationHandlers.values)
        invalidationHandlers.removeAll()
        return [{ refreshTask?.cancel() }] + handlers + waiters
    }

    func endAuthenticationLocked() -> [() -> Void] {
        currentIdentifier = UUID()
        active = false
        return invalidateLocked()
    }
}
