import Combine
import Foundation
import WrapKit
import XCTest

final class AuthenticatedHTTPClientDecoratorLifecycleTests: XCTestCase {
    private var contexts: [Context] = []

    override func setUp() {
        super.setUp()
        resetRefreshState()
    }

    override func tearDown() {
        // Red assertions must not leave a held Future or its callbacks in the
        // process-wide refresh publisher for the next test.
        contexts.forEach { $0.finishPendingWork() }
        drainMainQueue()
        contexts.removeAll()
        resetRefreshState()
        super.tearDown()
    }

    func test_overlapping401And403_acrossClients_shareRefreshAndRetryWithNewToken() throws {
        let context = makeContext()
        let otherClient = context.makeClient()
        context.dispatch(1)
        context.dispatch(2, using: otherClient)

        try context.respond(401, at: 0)
        try context.respond(403, at: 1)

        XCTAssertEqual(context.refresher.requestCount, 1)
        XCTAssertEqual(context.http.requests.count, 2, "Neither request may retry before refresh completes")

        try context.refresher.completeNext(.success(newTokens))
        drainMainQueue()

        XCTAssertEqual(context.http.requests.count, 4)
        XCTAssertEqual(context.http.requests.dropFirst(2).map(authorization), ["new_access", "new_access"])
        try context.respond(200, at: 2)
        try context.respond(200, at: 3)

        XCTAssertEqual(context.successCount(for: 1), 1)
        XCTAssertEqual(context.successCount(for: 2), 1)
        XCTAssertEqual(context.logoutCount, 0)
    }

    func test_lateOriginal403_afterRefresh_retriesWithCurrentTokenWithoutAnotherRefresh() throws {
        let context = makeContext()
        context.dispatch(1)
        context.dispatch(2)
        try context.respond(401, at: 0)
        try context.refresher.completeNext(.success(newTokens))
        drainMainQueue()
        try context.respond(200, at: 2)

        // Request 2 was sent with old_access, but its response arrives only
        // after the first refresh and the first successful retry have finished.
        try context.respond(403, at: 1)
        drainMainQueue()

        XCTAssertEqual(context.refresher.requestCount, 1, "A late response to the old token must not refresh the new token")
        XCTAssertEqual(context.http.requests.count, 4)
        let retry = try XCTUnwrap(context.http.requests.dropFirst(2).last(where: { $0.url == context.url(2) }))
        XCTAssertEqual(authorization(retry), "new_access")
        try context.respond(200, at: 3)
        XCTAssertEqual(context.successCount(for: 2), 1)
    }

    func test_refreshFailure_finishesAllWaitingRequestsAndLogsOutOnce() throws {
        let context = makeContext()
        context.dispatch(1)
        context.dispatch(2)
        try context.respond(401, at: 0)
        try context.respond(403, at: 1)

        try context.refresher.completeNext(.failure(.connectivity))
        drainMainQueue()

        XCTAssertEqual(context.refresher.requestCount, 1)
        XCTAssertEqual(context.http.requests.count, 2)
        XCTAssertEqual(context.failureCount(for: 1), 1, "The first caller must not wait forever after refresh failure")
        XCTAssertEqual(context.failureCount(for: 2), 1, "Every waiter must receive a terminal result")
        XCTAssertEqual(context.logoutCount, 1)
        XCTAssertNil(context.access.get())
        XCTAssertNil(context.refresh.get())
    }

    func test_repeated403_afterRefresh_stopsAfterOneRetryAndLogsOutOnce() throws {
        let context = makeContext()
        context.dispatch(1)
        try context.respond(403, at: 0)
        try context.refresher.completeNext(.success(newTokens))
        drainMainQueue()
        try context.respond(403, at: 1)
        drainMainQueue()

        XCTAssertEqual(context.refresher.requestCount, 1)
        XCTAssertEqual(context.http.requests.count, 2)
        XCTAssertEqual(context.failureCount(for: 1), 1)
        XCTAssertEqual(context.logoutCount, 1)
        XCTAssertNil(context.access.get())
        XCTAssertNil(context.refresh.get())
    }

    func test_logoutWhileRefreshIsPending_doesNotRestoreTokensOrRetry() throws {
        let context = makeContext()
        context.dispatch(1)
        try context.respond(401, at: 0)
        XCTAssertEqual(context.refresher.pendingCount, 1)

        // Keep coverage for callers that clear storage without the session API.
        context.access.clear()
        context.refresh.clear()
        drainMainQueue()

        try context.refresher.completeNext(.success(newTokens))
        drainMainQueue()

        XCTAssertNil(context.access.get(), "A response from the ended session must not restore access")
        XCTAssertNil(context.refresh.get(), "A response from the ended session must not restore refresh")
        XCTAssertEqual(context.http.requests.count, 1, "Logout must prevent the pending request from retrying")
        XCTAssertFalse(AuthenticatedHTTPClientDecorator.Session.shared.isRefreshing)
        XCTAssertEqual(context.failureCount(for: 1), 1)
    }

    func test_newLoginWhileOldRefreshIsPending_doesNotOverwriteNewSessionOrRetryOldRequest() throws {
        let context = makeContext()
        context.dispatch(1)
        try context.respond(401, at: 0)

        context.access.set(model: "different_login_access")
        context.refresh.set(model: "different_login_refresh")
        drainMainQueue()

        try context.refresher.completeNext(.success(newTokens))
        drainMainQueue()

        XCTAssertEqual(context.access.get(), "different_login_access")
        XCTAssertEqual(context.refresh.get(), "different_login_refresh")
        XCTAssertEqual(context.http.requests.count, 1, "The old request must not execute in a different login session")
        XCTAssertEqual(context.logoutCount, 0)
    }

    func test_cancelOneRefreshWaiter_doesNotRetryItAndOtherWaiterStillSucceeds() throws {
        let context = makeContext()
        let firstTask = context.dispatch(1)
        context.dispatch(2)
        try context.respond(401, at: 0)
        try context.respond(403, at: 1)

        firstTask.cancel()
        XCTAssertEqual(context.refresher.pendingCount, 1, "One cancelled waiter must not cancel the shared refresh")
        try context.refresher.completeNext(.success(newTokens))
        drainMainQueue()

        XCTAssertEqual(context.refresher.requestCount, 1)
        XCTAssertEqual(context.http.requests.filter { $0.url == context.url(1) }.count, 1, "The cancelled caller must not retry")
        XCTAssertEqual(context.http.requests.filter { $0.url == context.url(2) }.count, 2)
        let secondRetryIndex = try XCTUnwrap(context.http.requests.indices.last(where: {
            $0 > 1 && context.http.requests[$0].url == context.url(2)
        }))
        try context.respond(200, at: secondRetryIndex)

        XCTAssertEqual(context.successCount(for: 1), 0)
        XCTAssertEqual(context.successCount(for: 2), 1)
        XCTAssertEqual(context.logoutCount, 0)
    }

    func test_compositeCancel_cancelsExistingTasks() {
        let first = TaskSpy()
        let second = TaskSpy()
        let task = CompositeHTTPClientTask(tasks: [first, second])

        task.cancel()

        XCTAssertEqual(first.cancelCount, 1)
        XCTAssertEqual(second.cancelCount, 1)
    }

    func test_compositeCancel_beforeAddingTask_cancelsLateTaskAndDoesNotStartIt() {
        let task = CompositeHTTPClientTask()
        let lateTask = TaskSpy()

        task.cancel()
        task.add(lateTask)
        task.resume() // Also flushes CompositeHTTPClientTask's queued add.

        XCTAssertEqual(lateTask.cancelCount, 1)
        XCTAssertEqual(lateTask.startCount, 0, "Adding a task must not revive an already cancelled composite")
    }

    func test_sessionLogout_finishesAndCancelsPendingResourceBeforeItsResponse() throws {
        let context = makeContext()
        context.dispatch(1)

        AuthenticatedHTTPClientDecorator.Session.shared.updateCredentials {
            context.access.clear()
            context.refresh.clear()
        }

        XCTAssertEqual(context.failureCount(for: 1), 1)
        XCTAssertEqual(context.http.tasks[0].cancelCount, 1)
        try context.respond(200, at: 0)
        XCTAssertEqual(context.successCount(for: 1), 0)
        XCTAssertEqual(context.failureCount(for: 1), 1)
    }

    func test_sessionNewLogin_finishesOldWaiterAndIgnoresOldRefreshFailure() throws {
        let context = makeContext()
        context.dispatch(1)
        try context.respond(401, at: 0)

        AuthenticatedHTTPClientDecorator.Session.shared.updateCredentials {
            context.access.set(model: "login_access")
            context.refresh.set(model: "login_refresh")
        }
        XCTAssertEqual(context.failureCount(for: 1), 1)
        context.dispatch(2)
        try context.respond(200, at: 1)
        try context.refresher.completeNext(.failure(.connectivity))

        XCTAssertEqual(context.successCount(for: 2), 1)
        XCTAssertEqual(context.logoutCount, 0)
        XCTAssertEqual(context.access.get(), "login_access")
        XCTAssertEqual(context.refresh.get(), "login_refresh")
        XCTAssertEqual(context.http.requests.count, 2)
    }

    func test_refreshWithoutRotation_keepsExistingRefreshToken() throws {
        let context = makeContext()
        context.dispatch(1)
        try context.respond(401, at: 0)
        try context.refresher.completeNext(.success(Tokens(accessToken: "new_access")))

        XCTAssertEqual(context.access.get(), "new_access")
        XCTAssertEqual(context.refresh.get(), "old_refresh")
        try context.respond(200, at: 1)
        XCTAssertEqual(context.successCount(for: 1), 1)
    }

    func test_emptyRefreshAccessToken_finishesEveryWaiterAndLogsOutOnce() throws {
        let context = makeContext()
        context.dispatch(1)
        context.dispatch(2)
        try context.respond(401, at: 0)
        try context.respond(403, at: 1)
        try context.refresher.completeNext(.success(Tokens(accessToken: "")))

        XCTAssertEqual(context.failureCount(for: 1), 1)
        XCTAssertEqual(context.failureCount(for: 2), 1)
        XCTAssertEqual(context.logoutCount, 1)
        XCTAssertEqual(context.http.requests.count, 2)
    }

    func test_transportFailureOnRetry_finishesWithoutClearingValidCredentials() throws {
        let context = makeContext()
        context.dispatch(1)
        try context.respond(401, at: 0)
        try context.refresher.completeNext(.success(newTokens))
        try context.http.fail(at: 1)

        XCTAssertEqual(context.failureCount(for: 1), 1)
        XCTAssertEqual(context.logoutCount, 0)
        XCTAssertEqual(context.access.get(), "new_access")
        XCTAssertEqual(context.refresh.get(), "new_refresh")
    }

    func test_publicRefreshCancellation_finishesWaiterOnceWithoutCancellingOtherWaiters() throws {
        let context = makeContext()
        let client = context.makeClient()
        let cancelled = CompositeHTTPClientTask()
        let active = CompositeHTTPClientTask()
        var cancelledResults: [Tokens?] = []
        var activeResults: [Tokens?] = []
        client.refreshToken(for: "old_access", completion: { cancelledResults.append($0) }, compositeTask: cancelled)
        client.refreshToken(for: "old_access", completion: { activeResults.append($0) }, compositeTask: active)

        cancelled.cancel()
        XCTAssertEqual(cancelledResults.count, 1)
        XCTAssertNil(cancelledResults[0])
        try context.refresher.completeNext(.success(newTokens))

        XCTAssertEqual(cancelledResults.count, 1)
        XCTAssertEqual(activeResults.count, 1)
        XCTAssertEqual(activeResults[0]?.accessToken, "new_access")
        XCTAssertEqual(context.refresher.requestCount, 1)
    }

    func test_publicLogout_cancelsOtherRequestsAndDeduplicatesNotification() throws {
        let context = makeContext()
        let client = context.makeClient()
        context.dispatch(1)
        let sessionID = AuthenticatedHTTPClientDecorator.Session.shared.identifier

        client.invalidateAuthentication(sessionID: sessionID, accessToken: "old_access")
        client.invalidateAuthentication(sessionID: sessionID, accessToken: "old_access")
        try context.respond(200, at: 0)

        XCTAssertEqual(context.failureCount(for: 1), 1)
        XCTAssertEqual(context.successCount(for: 1), 0)
        XCTAssertEqual(context.logoutCount, 1)
    }

    func test_invalidationCallbacks_canStartNewSessionReentrantly() {
        let session = AuthenticatedHTTPClientDecorator.Session()
        let original = session.identifier
        var invalidations = 0
        session.onInvalidation(of: original) {
            invalidations += 1
            session.updateCredentials {}
        }
        session.updateCredentials {}
        XCTAssertEqual(invalidations, 1)
        XCTAssertNotEqual(session.identifier, original)
    }

    func test_conditionalCredentialUpdate_rejectsLateLoginCompletion() {
        let session = AuthenticatedHTTPClientDecorator.Session()
        let oldSession = session.identifier
        var credential = "first"
        session.updateCredentials { credential = "second" }

        let changed = session.updateCredentials(ifCurrent: oldSession) { credential = "stale" }

        XCTAssertFalse(changed)
        XCTAssertEqual(credential, "second")
    }

    func test_newLoginReenteredDuringRefreshPersistence_doesNotOverwriteItsTokens() throws {
        let access = InMemoryStorage(model: "old_access")
        let refresh = InMemoryStorage(model: "old_refresh")
        let session = AuthenticatedHTTPClientDecorator.Session()
        let refresher = GatedTokenRefresher()
        var logoutCount = 0
        let client = AuthenticatedHTTPClientDecorator(
            decoratee: GatedHTTPClient(), accessTokenStorage: access, refreshTokenStorage: refresh,
            tokenRefresher: refresher, onNotAuthenticated: { _ in logoutCount += 1 },
            enrichRequestWithToken: { request, _ in request }, isAuthenticated: { _ in .authenticated },
            authenticationSession: session
        )
        let observation = refresh.publisher.sink { value in
            guard value == "new_refresh" else { return }
            session.updateCredentials {
                access.set(model: "login_access")
                refresh.set(model: "login_refresh")
            }
        }
        defer { observation.cancel() }
        var results: [Tokens?] = []
        let task = CompositeHTTPClientTask()
        client.refreshToken(for: "old_access", completion: { results.append($0) }, compositeTask: task)

        try refresher.completeNext(.success(newTokens))

        XCTAssertEqual(access.get(), "login_access")
        XCTAssertEqual(refresh.get(), "login_refresh")
        XCTAssertEqual(logoutCount, 0)
        XCTAssertEqual(results.count, 1)
        XCTAssertNil(results[0])
        XCTAssertFalse(session.isRefreshing)
    }

    func test_waiterJoiningDuringTokenPersistence_receivesCompletedRefresh() throws {
        let access = InMemoryStorage(model: "old_access")
        let refresh = InMemoryStorage(model: "old_refresh")
        let session = AuthenticatedHTTPClientDecorator.Session()
        let refresher = GatedTokenRefresher()
        let client = AuthenticatedHTTPClientDecorator(
            decoratee: GatedHTTPClient(), accessTokenStorage: access, refreshTokenStorage: refresh,
            tokenRefresher: refresher,
            enrichRequestWithToken: { request, _ in request }, isAuthenticated: { _ in .authenticated },
            authenticationSession: session
        )
        let firstTask = CompositeHTTPClientTask()
        let lateTask = CompositeHTTPClientTask()
        var firstResults: [Tokens?] = []
        var lateResults: [Tokens?] = []
        let observation = refresh.publisher.sink { value in
            guard value == "new_refresh" else { return }
            client.refreshToken(for: "old_access", completion: { lateResults.append($0) }, compositeTask: lateTask)
        }
        defer { observation.cancel() }
        client.refreshToken(for: "old_access", completion: { firstResults.append($0) }, compositeTask: firstTask)

        try refresher.completeNext(.success(newTokens))

        XCTAssertEqual(refresher.requestCount, 1)
        XCTAssertEqual(firstResults.count, 1)
        XCTAssertEqual(lateResults.count, 1)
        XCTAssertEqual(firstResults.compactMap { $0?.accessToken }, ["new_access"])
        XCTAssertEqual(lateResults.compactMap { $0?.accessToken }, ["new_access"])
        XCTAssertEqual(access.get(), "new_access")
        XCTAssertEqual(refresh.get(), "new_refresh")
        XCTAssertFalse(session.isRefreshing)
    }

    func test_activeRefresh_retainsRefresherAfterStartingClientIsReleased() throws {
        let access = InMemoryStorage(model: "old_access")
        let refresh = InMemoryStorage(model: "old_refresh")
        let session = AuthenticatedHTTPClientDecorator.Session()
        let task = CompositeHTTPClientTask()
        var results: [Tokens?] = []
        weak var weakRefresher: GatedTokenRefresher?
        weak var weakClient: AuthenticatedHTTPClientDecorator?
        do {
            let refresher = GatedTokenRefresher()
            let client = AuthenticatedHTTPClientDecorator(
                decoratee: GatedHTTPClient(), accessTokenStorage: access, refreshTokenStorage: refresh,
                tokenRefresher: refresher,
                enrichRequestWithToken: { request, _ in request }, isAuthenticated: { _ in .authenticated },
                authenticationSession: session
            )
            weakRefresher = refresher
            weakClient = client
            client.refreshToken(for: "old_access", completion: { results.append($0) }, compositeTask: task)
        }

        XCTAssertNil(weakClient)
        XCTAssertNotNil(weakRefresher)
        try XCTUnwrap(weakRefresher).completeNext(.success(newTokens))

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.compactMap { $0?.accessToken }, ["new_access"])
        XCTAssertNil(weakRefresher)
        XCTAssertFalse(session.isRefreshing)
    }

    func test_logoutDuringRefresh_doesNotAffectIndependentSession() throws {
        let first = makeContext(session: AuthenticatedHTTPClientDecorator.Session())
        let second = makeContext(session: AuthenticatedHTTPClientDecorator.Session())
        first.dispatch(1)
        second.dispatch(2)
        try first.respond(401, at: 0)
        try second.respond(403, at: 0)

        XCTAssertTrue(first.session.isRefreshing)
        XCTAssertTrue(second.session.isRefreshing)
        XCTAssertEqual(first.refresher.requestCount, 1)
        XCTAssertEqual(second.refresher.requestCount, 1)

        first.session.invalidateCredentials {
            first.access.clear()
            first.refresh.clear()
        }

        XCTAssertEqual(first.failureCount(for: 1), 1)
        XCTAssertFalse(first.session.isActive)
        XCTAssertTrue(second.session.isActive)
        XCTAssertTrue(second.session.isRefreshing)
        XCTAssertEqual(second.failureCount(for: 2), 0)

        try first.refresher.completeNext(.success(newTokens))
        try second.refresher.completeNext(.success(newTokens))
        try second.respond(200, at: 1)

        XCTAssertNil(first.access.get())
        XCTAssertNil(first.refresh.get())
        XCTAssertEqual(first.http.requests.count, 1)
        XCTAssertEqual(first.failureCount(for: 1), 1)
        XCTAssertEqual(second.access.get(), "new_access")
        XCTAssertEqual(second.refresh.get(), "new_refresh")
        XCTAssertEqual(second.successCount(for: 2), 1)
        XCTAssertEqual(second.failureCount(for: 2), 0)
        XCTAssertEqual(second.logoutCount, 0)
        XCTAssertFalse(second.session.isRefreshing)
    }

    func test_concurrentPublicRefreshCalls_allJoinOneFlight() throws {
        let context = makeContext()
        let clients = (0..<20).map { _ in context.makeClient() }
        let tasks = (0..<20).map { _ in CompositeHTTPClientTask() }
        var results: [Tokens?] = []
        DispatchQueue.concurrentPerform(iterations: clients.count) { index in
            clients[index].refreshToken(for: "old_access", completion: { results.append($0) }, compositeTask: tasks[index])
        }
        XCTAssertEqual(context.refresher.requestCount, 1)
        XCTAssertTrue(AuthenticatedHTTPClientDecorator.Session.shared.isRefreshing)

        try context.refresher.completeNext(.success(newTokens))

        XCTAssertEqual(results.count, clients.count)
        XCTAssertTrue(results.allSatisfy { $0?.accessToken == "new_access" })
        XCTAssertFalse(AuthenticatedHTTPClientDecorator.Session.shared.isRefreshing)
    }

    func test_cancelLastWaiter_endsFlightAndLateRefreshCannotReplaceNextFlight() throws {
        let context = makeContext()
        let task = context.dispatch(1)
        try context.respond(401, at: 0)
        task.cancel()
        XCTAssertFalse(AuthenticatedHTTPClientDecorator.Session.shared.isRefreshing)
        XCTAssertEqual(context.failureCount(for: 1), 1)

        context.dispatch(2)
        try context.respond(401, at: 1)
        XCTAssertEqual(context.refresher.requestCount, 2)
        try context.refresher.completeNext(.success(Tokens(accessToken: "stale_access")))
        XCTAssertEqual(context.access.get(), "old_access")
        XCTAssertTrue(AuthenticatedHTTPClientDecorator.Session.shared.isRefreshing)
        try context.refresher.completeNext(.success(newTokens))
        try context.respond(200, at: 2)

        XCTAssertEqual(context.access.get(), "new_access")
        XCTAssertEqual(context.successCount(for: 2), 1)
        XCTAssertFalse(AuthenticatedHTTPClientDecorator.Session.shared.isRefreshing)
    }

    func test_newLoginReenteredDuringLogout_keepsBothNewTokens() {
        let access = InMemoryStorage(model: "old_access")
        let refresh = InMemoryStorage(model: "old_refresh")
        let session = AuthenticatedHTTPClientDecorator.Session()
        var logoutCount = 0
        let client = AuthenticatedHTTPClientDecorator(
            decoratee: GatedHTTPClient(), accessTokenStorage: access, refreshTokenStorage: refresh,
            tokenRefresher: GatedTokenRefresher(), onNotAuthenticated: { _ in logoutCount += 1 },
            enrichRequestWithToken: { request, _ in request }, isAuthenticated: { _ in .authenticated },
            authenticationSession: session
        )
        let observation = access.publisher.sink { value in
            guard value == nil else { return }
            session.updateCredentials {
                access.set(model: "login_access")
                refresh.set(model: "login_refresh")
            }
        }
        defer { observation.cancel() }

        client.invalidateAuthentication(sessionID: session.identifier, accessToken: "old_access")

        XCTAssertEqual(access.get(), "login_access")
        XCTAssertEqual(refresh.get(), "login_refresh")
        XCTAssertEqual(logoutCount, 0)
    }

    func test_failedCredentialDeletion_stillBlocksRequestsUntilExplicitLogin() throws {
        let context = makeContext()
        let client = context.makeClient()
        context.keychain.rejectDeletes = true

        AuthenticatedHTTPClientDecorator.Session.shared.invalidateCredentials {
            context.access.clear()
            context.refresh.clear()
        }
        context.dispatch(1)
        var refreshResults: [Tokens?] = []
        client.refreshToken(for: "old_access", completion: { refreshResults.append($0) }, compositeTask: CompositeHTTPClientTask())

        XCTAssertEqual(context.access.get(), "old_access", "Fixture must reproduce a failed deletion")
        XCTAssertEqual(context.refresh.get(), "old_refresh")
        XCTAssertFalse(AuthenticatedHTTPClientDecorator.Session.shared.isActive)
        XCTAssertEqual(context.http.requests.count, 0)
        XCTAssertEqual(context.refresher.requestCount, 0)
        XCTAssertEqual(context.failureCount(for: 1), 1)
        XCTAssertEqual(refreshResults.count, 1)
        XCTAssertNil(refreshResults[0])

        AuthenticatedHTTPClientDecorator.Session.shared.updateCredentials {
            context.access.set(model: "login_access")
            context.refresh.set(model: "login_refresh")
        }
        context.dispatch(2)
        try context.respond(200, at: 0)
        XCTAssertEqual(context.successCount(for: 2), 1)
    }

    func test_refreshTokenPersistenceFailure_finishesEveryWaiterWithoutRetry() throws {
        try assertRefreshPersistenceFailure(rejectedKey: "test_refresh", rejectsDeletion: false)
    }

    func test_accessTokenPersistenceFailureAfterRotation_finishesEveryWaiterWithoutRetry() throws {
        try assertRefreshPersistenceFailure(rejectedKey: "test_access", rejectsDeletion: false)
    }

    func test_refreshTokenPersistenceAndDeletionFailure_keepsSessionBlocked() throws {
        try assertRefreshPersistenceFailure(rejectedKey: "test_refresh", rejectsDeletion: true)
    }

    func test_accessTokenPersistenceAndDeletionFailure_keepsSessionBlocked() throws {
        try assertRefreshPersistenceFailure(rejectedKey: "test_access", rejectsDeletion: true)
    }

    // MARK: - Helpers

    private func assertRefreshPersistenceFailure(rejectedKey: String, rejectsDeletion: Bool) throws {
        let context = makeContext()
        context.dispatch(1)
        context.dispatch(2)
        try context.respond(401, at: 0)
        try context.respond(403, at: 1)
        context.keychain.rejectedWriteKeys = [rejectedKey]
        context.keychain.rejectDeletes = rejectsDeletion

        try context.refresher.completeNext(.success(newTokens))
        drainMainQueue()

        XCTAssertEqual(context.refresher.requestCount, 1)
        XCTAssertEqual(context.http.requests.count, 2, "An unpersisted token must never be used for retry")
        XCTAssertEqual(context.failureCount(for: 1), 1)
        XCTAssertEqual(context.failureCount(for: 2), 1)
        XCTAssertEqual(context.successCount(for: 1), 0)
        XCTAssertEqual(context.successCount(for: 2), 0)
        XCTAssertEqual(context.logoutCount, 1)
        XCTAssertFalse(AuthenticatedHTTPClientDecorator.Session.shared.isRefreshing)
        XCTAssertFalse(AuthenticatedHTTPClientDecorator.Session.shared.isActive)
        if rejectsDeletion {
            XCTAssertEqual(context.access.get(), "old_access")
            XCTAssertEqual(context.refresh.get(), rejectedKey == "test_refresh" ? "old_refresh" : "new_refresh")
        } else {
            XCTAssertNil(context.access.get())
            XCTAssertNil(context.refresh.get())
        }

        context.dispatch(3)
        XCTAssertEqual(context.failureCount(for: 3), 1)
        XCTAssertEqual(context.http.requests.count, 2)
        XCTAssertEqual(context.refresher.requestCount, 1)
        XCTAssertEqual(context.logoutCount, 1)
    }

    private var newTokens: Tokens {
        Tokens(accessToken: "new_access", refreshToken: "new_refresh")
    }

    private func makeContext(session: AuthenticatedHTTPClientDecorator.Session = .shared) -> Context {
        let context = Context(session: session)
        contexts.append(context)
        // Drain the initial storage publication before each controlled event
        // sequence; no fixed sleep or racing background callbacks are needed.
        drainMainQueue()
        return context
    }

    private func authorization(_ request: URLRequest) -> String? {
        request.value(forHTTPHeaderField: "Authorization")
    }

    private func resetRefreshState() {
        AuthenticatedHTTPClientDecorator.Session.shared.updateCredentials {}
        XCTAssertFalse(AuthenticatedHTTPClientDecorator.Session.shared.isRefreshing)
    }

    private func drainMainQueue() {
        let drained = expectation(description: "Previously enqueued main-queue callbacks finished")
        DispatchQueue.main.async { drained.fulfill() }
        wait(for: [drained], timeout: 1)
    }
}

private extension AuthenticatedHTTPClientDecoratorLifecycleTests {
    final class Context {
        let session: AuthenticatedHTTPClientDecorator.Session
        let keychain = InMemoryKeychain()
        let http = GatedHTTPClient()
        let refresher = GatedTokenRefresher()
        let access: KeychainStorage
        let refresh: KeychainStorage
        private var clients: [AuthenticatedHTTPClientDecorator] = []
        private var tasks: [HTTPClientTask] = []
        private var results: [Int: [HTTPClient.Result]] = [:]
        private(set) var logoutCount = 0

        init(session: AuthenticatedHTTPClientDecorator.Session) {
            self.session = session
            access = KeychainStorage(key: "test_access", keychain: keychain)
            refresh = KeychainStorage(key: "test_refresh", keychain: keychain)
            access.set(model: "old_access")
            refresh.set(model: "old_refresh")
            makeClient()
        }

        @discardableResult
        func makeClient() -> AuthenticatedHTTPClientDecorator {
            let client = AuthenticatedHTTPClientDecorator(
                decoratee: http,
                accessTokenStorage: access,
                refreshTokenStorage: refresh,
                tokenRefresher: refresher,
                onNotAuthenticated: { [weak self] _ in self?.logoutCount += 1 },
                enrichRequestWithToken: { request, token in
                    var request = request
                    request.setValue(token, forHTTPHeaderField: "Authorization")
                    return request
                },
                isAuthenticated: { _, response in
                    [401, 403].contains(response.statusCode) ? .needsRefresh(onErrorMessage: nil) : .authenticated
                },
                authenticationSession: session
            )
            clients.append(client)
            return client
        }

        func url(_ number: Int) -> URL {
            URL(string: "https://auth-tests.invalid/resource/\(number)")!
        }

        @discardableResult
        func dispatch(_ number: Int, using client: AuthenticatedHTTPClientDecorator? = nil) -> HTTPClientTask {
            let task = (client ?? clients[0]).dispatch(URLRequest(url: url(number))) { [weak self] result in
                self?.results[number, default: []].append(result)
            }
            tasks.append(task)
            task.resume()
            return task
        }

        func respond(_ status: Int, at index: Int, file: StaticString = #filePath, line: UInt = #line) throws {
            try http.complete(status: status, at: index, file: file, line: line)
        }

        func successCount(for number: Int) -> Int {
            results[number, default: []].filter { if case .success = $0 { return true }; return false }.count
        }

        func failureCount(for number: Int) -> Int {
            results[number, default: []].filter { if case .failure = $0 { return true }; return false }.count
        }

        func finishPendingWork() {
            refresher.finishPending()
            http.finishPending()
            tasks.forEach { $0.cancel() }
        }
    }

    final class GatedTokenRefresher: TokenRefresher {
        private var completions: [((Result<Tokens, ServiceError>) -> Void)?] = []
        var requestCount: Int { completions.count }
        var pendingCount: Int { completions.compactMap { $0 }.count }

        func refresh(completion: @escaping (Result<Tokens, ServiceError>) -> Void) {
            completions.append(completion)
        }

        func completeNext(_ result: Result<Tokens, ServiceError>, file: StaticString = #filePath, line: UInt = #line) throws {
            let index = try XCTUnwrap(completions.firstIndex(where: { $0 != nil }), "Expected a pending refresh", file: file, line: line)
            let completion = completions[index]
            completions[index] = nil
            completion?(result)
        }

        func finishPending() {
            let pending = completions.compactMap { $0 }
            completions = completions.map { _ in nil }
            pending.forEach { $0(.failure(.cancelled)) }
        }
    }

    final class GatedHTTPClient: HTTPClient {
        private struct Message {
            let request: URLRequest
            var completion: ((HTTPClient.Result) -> Void)?
        }
        private var messages: [Message] = []
        private(set) var tasks: [TaskSpy] = []
        var requests: [URLRequest] { messages.map(\.request) }

        func dispatch(_ request: URLRequest, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
            messages.append(Message(request: request, completion: completion))
            let task = TaskSpy()
            tasks.append(task)
            return task
        }

        func fail(at index: Int) throws {
            let completion = try XCTUnwrap(messages[index].completion)
            messages[index].completion = nil
            completion(.failure(ServiceError.connectivity))
        }

        func complete(status: Int, at index: Int, file: StaticString, line: UInt) throws {
            let message = try XCTUnwrap(messages.indices.contains(index) ? messages[index] : nil, "Expected request at index \(index)", file: file, line: line)
            let completion = try XCTUnwrap(message.completion, "Request already completed", file: file, line: line)
            messages[index].completion = nil
            let url = try XCTUnwrap(message.request.url, file: file, line: line)
            let response = try XCTUnwrap(HTTPURLResponse(url: url, statusCode: status, httpVersion: nil, headerFields: nil), file: file, line: line)
            completion(.success((Data(), response)))
        }

        func finishPending() {
            let pending = messages.compactMap(\.completion)
            for index in messages.indices { messages[index].completion = nil }
            pending.forEach { $0(.failure(ServiceError.cancelled)) }
        }
    }

    final class TaskSpy: HTTPClientTask {
        private(set) var cancelCount = 0
        private(set) var startCount = 0

        func cancel() { cancelCount += 1 }
        func resume() { if cancelCount == 0 { startCount += 1 } }
    }

    final class InMemoryKeychain: Keychain {
        var rejectDeletes = false
        var rejectedWriteKeys: Set<String> = []
        private var values: [String: String] = [:]
        private let lock = NSLock()

        func get(_ key: String) -> String? {
            lock.lock()
            defer { lock.unlock() }
            return values[key]
        }

        func set(_ value: String, forKey key: String) -> Bool {
            lock.lock()
            defer { lock.unlock() }
            guard !rejectedWriteKeys.contains(key) else { return false }
            values[key] = value
            return true
        }

        func delete(_ key: String) -> Bool {
            lock.lock()
            defer { lock.unlock() }
            guard !rejectDeletes else { return false }
            values[key] = nil
            return true
        }
    }
}
