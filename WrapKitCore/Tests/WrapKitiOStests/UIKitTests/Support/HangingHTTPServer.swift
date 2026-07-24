//
//  HangingHTTPServer.swift
//  WrapKit
//

import Foundation
import Network

final class HangingHTTPServer {
    private enum ServerError: Error {
        case failedToStart
    }

    private let listener: NWListener
    private let queue = DispatchQueue(label: "com.wrapkit.tests.hanging-http-server")
    private let lock = NSLock()
    private var port: UInt16?
    private var connections: [ObjectIdentifier: NWConnection] = [:]
    private var connectionURLs: [ObjectIdentifier: URL] = [:]
    private var disconnectedConnections: Set<ObjectIdentifier> = []
    private var _startedURLs: [URL] = []
    private var _disconnectedURLs: [URL] = []
    private var onStart: ((URL) -> Void)?
    private var onDisconnect: ((URL) -> Void)?
    private var isStopping = false

    var startedURLs: [URL] {
        lock.lock()
        defer { lock.unlock() }
        return _startedURLs
    }

    var disconnectedURLs: [URL] {
        lock.lock()
        defer { lock.unlock() }
        return _disconnectedURLs
    }

    init() throws {
        let parameters = NWParameters.tcp
        parameters.requiredLocalEndpoint = .hostPort(host: .ipv4(.loopback), port: .any)
        listener = try NWListener(using: parameters)
        try start()
    }

    deinit {
        stop()
    }

    func url(path: String) -> URL {
        lock.lock()
        let port = port
        lock.unlock()

        let normalizedPath = path.hasPrefix("/") ? path : "/\(path)"
        guard let port, let url = URL(string: "http://127.0.0.1:\(port)\(normalizedPath)") else {
            preconditionFailure("Hanging HTTP server is not ready")
        }
        return url
    }

    func observeStart(_ observer: @escaping (URL) -> Void) {
        lock.lock()
        onStart = observer
        lock.unlock()
    }

    func observeDisconnect(_ observer: @escaping (URL) -> Void) {
        lock.lock()
        onDisconnect = observer
        lock.unlock()
    }

    func stop() {
        lock.lock()
        guard !isStopping else {
            lock.unlock()
            return
        }
        isStopping = true
        onStart = nil
        onDisconnect = nil
        let connections = Array(connections.values)
        lock.unlock()

        connections.forEach { $0.cancel() }
        listener.cancel()
    }

    private func start() throws {
        let ready = DispatchSemaphore(value: 0)
        var startError: NWError?

        listener.stateUpdateHandler = { [weak self] state in
            guard let self else { return }
            switch state {
            case .ready:
                lock.lock()
                port = listener.port?.rawValue
                lock.unlock()
                ready.signal()
            case .failed(let error):
                startError = error
                ready.signal()
            default:
                break
            }
        }
        listener.newConnectionHandler = { [weak self] connection in
            self?.accept(connection)
        }
        listener.start(queue: queue)

        guard ready.wait(timeout: .now() + 2) == .success, startError == nil else {
            listener.cancel()
            throw startError ?? ServerError.failedToStart
        }
    }

    private func accept(_ connection: NWConnection) {
        let identifier = ObjectIdentifier(connection)
        lock.lock()
        guard !isStopping else {
            lock.unlock()
            connection.cancel()
            return
        }
        connections[identifier] = connection
        lock.unlock()

        connection.stateUpdateHandler = { [weak self] state in
            switch state {
            case .failed, .cancelled:
                self?.recordDisconnect(for: identifier)
            default:
                break
            }
        }
        connection.start(queue: queue)
        receiveRequest(on: connection, identifier: identifier, data: Data())
    }

    private func receiveRequest(on connection: NWConnection, identifier: ObjectIdentifier, data: Data) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65_536) { [weak self] chunk, _, isComplete, error in
            guard let self else { return }
            var requestData = data
            if let chunk {
                requestData.append(chunk)
            }

            if let request = String(data: requestData, encoding: .utf8),
               request.contains("\r\n\r\n"),
               let path = request.components(separatedBy: "\r\n").first?.split(separator: " ").dropFirst().first {
                recordStart(path: String(path), for: identifier)
                observeClientClosure(on: connection, identifier: identifier)
            } else if isComplete || error != nil {
                recordDisconnect(for: identifier)
            } else {
                receiveRequest(on: connection, identifier: identifier, data: requestData)
            }
        }
    }

    private func observeClientClosure(on connection: NWConnection, identifier: ObjectIdentifier) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 1) { [weak self] _, _, isComplete, error in
            guard let self else { return }
            if isComplete || error != nil {
                recordDisconnect(for: identifier)
            } else {
                observeClientClosure(on: connection, identifier: identifier)
            }
        }
    }

    private func recordStart(path: String, for identifier: ObjectIdentifier) {
        lock.lock()
        guard
            let port,
            let url = URL(string: "http://127.0.0.1:\(port)\(path)")
        else {
            lock.unlock()
            return
        }
        connectionURLs[identifier] = url
        _startedURLs.append(url)
        let observer = onStart
        lock.unlock()

        observer?(url)
    }

    private func recordDisconnect(for identifier: ObjectIdentifier) {
        lock.lock()
        guard
            !isStopping,
            !disconnectedConnections.contains(identifier),
            let url = connectionURLs[identifier]
        else {
            lock.unlock()
            return
        }
        disconnectedConnections.insert(identifier)
        _disconnectedURLs.append(url)
        let connection = connections.removeValue(forKey: identifier)
        connectionURLs.removeValue(forKey: identifier)
        let observer = onDisconnect
        lock.unlock()

        connection?.stateUpdateHandler = nil
        observer?(url)
    }
}
