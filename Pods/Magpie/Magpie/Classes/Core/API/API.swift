//
//  API.swift
//  Pods
//
//  Created by Salih Karasuluoglu on 13.09.2018.
//

import Foundation

#if canImport(AppKit)
import AppKit
#else
import UIKit
#endif

open class API {
    public var base: String

    open var cachePolicy: URLRequest.CachePolicy = .reloadIgnoringLocalCacheData
    open var timeout: TimeInterval = 60.0

    open var ignoresResponseOnCancelled = true
    open var ignoresResponseWhenListenersNotified = false
    open var ignoresResponseWhenEndpointsFailedFromUnauthorizedRequest = true

    open var notifiesListenersWhenEndpointsFailedFromUnauthorizedRequest = true
    open var notifiesListenersWhenEndpointsFailedFromUnavailableNetwork = false
    open var notifiesListenersWhenEndpointsFailedFromDefectiveClient = false
    open var notifiesListenersWhenEndpointsFailedFromUnresponsiveServer = false

    public let networking: Networking
    public let interceptor: APIInterceptor?
    public let networkMonitor: NetworkMonitor?

    lazy var storage = TaskStorage()
    lazy var logger = Logger<APILogCategory>(subsystem: "com.hipo.magpie")

    var listens: [ObjectIdentifier: APIListen] = [:]
    var networkMonitoringObservers: [NSObjectProtocol] = []

    public init(
        base: String,
        networking: Networking,
        interceptor: APIInterceptor? = nil,
        networkMonitor: NetworkMonitor? = nil
    ) {
        self.base = base
        self.networking = networking
        self.interceptor = interceptor
        self.networkMonitor = networkMonitor

        if networkMonitor != nil {
            allowNetworkMonitoring()
        }
    }

    deinit {
        cancelEndpoints()
        cancelNetworkMonitoring()
    }
}

extension API {
    public func filterLogsInConsole(by categories: [APILogCategory]) {
        logger.allowedCategories = categories
    }

    public func filterLogsInConsole(by levels: [LogLevel]) {
        logger.allowedLevels = levels
    }

    public func enableLogsInConsole() {
        logger.isEnabled = true
    }

    public func disableLogsInConsole() {
        logger.isEnabled = false
    }
}

extension API {
    public func cancelEndpoints(with path: String) {
        storage.cancelAndDeleteAll(with: path)
    }

    public func cancelEndpoints(relativeTo path: String) {
        storage.cancelAndDeleteAll(relativeTo: path)
    }
    
    public func cancelEndpoints() {
        storage.cancelAndDeleteAll()
    }
}

extension API {
    func send(_ endpoint: Endpoint) -> TaskConvertible? {
        let responseHandler: Networking.ResponseHandler = { [weak self] response in
            guard let self = self else { return }

            self.logger.log(response, response.isSuccess ? .info : .error)
            self.storage.delete(for: endpoint)

            if let interceptor = self.interceptor, interceptor.intercept(response, for: endpoint) { return }

            self.forward(response, for: endpoint)
        }

        interceptor?.intercept(endpoint)

        if let task = forward(endpoint, onReceived: responseHandler) {
            storage.add(task, for: endpoint)
            return task
        }
        return nil
    }

    private func forward(_ endpoint: Endpoint, onReceived responseHandler: @escaping Networking.ResponseHandler) -> TaskConvertible? {
        logger.log(endpoint.request, .info)

        switch endpoint.type {
        case .data:
            return networking.send(endpoint.request, validateResponse: endpoint.validatesResponseBeforeCompletion, onReceived: responseHandler)
        case .upload(let src):
            return networking.upload(src, with: endpoint.request, validateResponse: endpoint.validatesResponseBeforeCompletion, onCompleted: responseHandler)
        case .multipart(let form):
            return networking.upload(form, with: endpoint.request, validateResponse: endpoint.validatesResponseBeforeCompletion, onCompleted: responseHandler)
        }
    }

    private func forward(_ response: Response, for endpoint: Endpoint) {
        guard let error = response.error else {
            endpoint.forward(response)
            return
        }
        if let httpError = error as? HTTPError {
            forward(response, for: endpoint, onFailedFrom: httpError)
            return
        }
        if let connectionError = error as? ConnectionError {
            forward(response, for: endpoint, onFailedFrom: connectionError)
            return
        }
        endpoint.forward(response)
    }

    private func forward(_ response: Response, for endpoint: Endpoint, onFailedFrom error: HTTPError) {
        switch error.reason {
        case .unauthorized:
            if endpoint.notifiesListenersOnFailedFromUnauthorizedRequest {
                let notifier: ListenerNotifier = { $0.api(self, endpointDidFailFromUnauthorizedRequest: endpoint) }

                if endpoint.ignoresResponseOnFailedFromUnauthorizedRequest {
                    notifyListeners(notifier)
                } else {
                    forward(response, for: endpoint, afterNotifyingListeners: notifier)
                }
            } else {
                endpoint.forward(response)
            }
        case .badRequest,
             .notFound,
             .forbidden,
             .client:
            if endpoint.notifiesListenersOnFailedFromDefectiveClient {
                forward(response, for: endpoint) { $0.api(self, endpoint: endpoint, didFailFromDefectiveClient: error) }
            } else {
                endpoint.forward(response)
            }
        case .notImplemented,
             .serviceUnavailable,
             .server:
            if endpoint.notifiesListenersOnFailedFromUnresponsiveServer {
                forward(response, for: endpoint) { $0.api(self, endpoint: endpoint, didFailFromUnresponsiveServer: error) }
            } else {
                endpoint.forward(response)
            }
        default:
            endpoint.forward(response)
        }
    }

    private func forward(_ response: Response, for endpoint: Endpoint, onFailedFrom error: ConnectionError) {
        switch error.reason {
        case .notConnectedToInternet:
            if endpoint.notifiesListenersOnFailedFromUnavailableNetwork {
                forward(response, for: endpoint) { $0.api(self, endpoint: endpoint, didFailFromUnavailableNetwork: error) }
            } else {
                endpoint.forward(response)
            }
        case .cancelled:
            if !endpoint.ignoresResponseOnCancelled {
                endpoint.forward(response)
            }
        default:
            endpoint.forward(response)
        }
    }

    private func forward(_ response: Response, for endpoint: Endpoint, afterNotifyingListeners notifier: ListenerNotifier) {
        notifyListeners(notifier)

        if !endpoint.ignoresResponseWhenListenersNotified {
            endpoint.forward(response)
        }
    }
}

extension API {
    public func startNetworkMonitoring() {
        if let nm = networkMonitor {
            nm.listener = self
            nm.start(on: DispatchQueue(label: "com.hipo.magpie.queue.networkmonitoring"))
        } else {
            removeNetworkMonitoringObservers()

            logger.log(Log(message: "Network monitoring is disabled", category: .networkMonitoring, level: .info))
        }
    }

    public func stopNetworkMonitoring() {
        if let nm = networkMonitor {
            nm.stop()
        } else {
            removeNetworkMonitoringObservers()
        }
    }

    func allowNetworkMonitoring() {
        startNetworkMonitoring()
        addNetworkMonitoringObservers()
    }

    func cancelNetworkMonitoring() {
        stopNetworkMonitoring()
        removeNetworkMonitoringObservers()
    }

    func addNetworkMonitoringObservers() {
        let startObserverNotificationName: Notification.Name
        let stopObserverNotificationName: Notification.Name

        #if canImport(AppKit)
        startObserverNotificationName = NSApplication.didBecomeActiveNotification
        stopObserverNotificationName = NSApplication.didResignActiveNotification
        #else
        startObserverNotificationName = UIApplication.willEnterForegroundNotification
        stopObserverNotificationName = UIApplication.didEnterBackgroundNotification
        #endif

        let startObserver = NotificationCenter.default.addObserver(
            forName: startObserverNotificationName,
            object: nil,
            queue: OperationQueue.main
        ) { [weak self] _ in
            self?.startNetworkMonitoring()
        }
        let stopObserver = NotificationCenter.default.addObserver(
            forName: stopObserverNotificationName,
            object: nil,
            queue: OperationQueue.main
        ) { [weak self] _ in
            self?.stopNetworkMonitoring()

            if let self = self,
               let nm = self.networkMonitor {
                nm.listener?.networkMonitor(nm, didChangeNetworkStatus: NetworkStatusChange(.suspended, .undetermined))
            }
        }

        networkMonitoringObservers = [startObserver, stopObserver]
    }

    func removeNetworkMonitoringObservers() {
        for observer in networkMonitoringObservers {
            NotificationCenter.default.removeObserver(observer)
        }
        networkMonitoringObservers = []
    }
}


extension API {
    typealias ListenerNotifier = (APIListener) -> Void

    public func addListener(_ listener: APIListener) {
        let id = ObjectIdentifier(listener)
        listens[id] = APIListen(listener)
    }

    public func removeListener(_ listener: APIListener) {
        let id = ObjectIdentifier(listener)
        listens[id] = nil
    }

    public func removeAllListeners() {
        listens.removeAll()
    }

    func notifyListeners(_ notifier: ListenerNotifier) {
        for (id, listen) in listens {
            if let listener = listen.listener {
                notifier(listener)
            } else {
                listens[id] = nil
            }
        }
    }
}

extension API: NetworkListener {
    public func networkMonitor(_ networkMonitor: NetworkMonitor, didChangeNetworkStatus change: NetworkStatusChange) {
        DispatchQueue.main.async {
            self.notifyListeners { listener in
                switch change.new {
                case .unavailable:
                    break
                case .connected(let connection):
                    listener.api(self, networkMonitor: networkMonitor, didConnectVia: connection, from: change.old.connection)
                case .undetermined,
                     .disconnected:
                    listener.api(self, networkMonitor: networkMonitor, didDisconnectFrom: change.old.connection)
                case .suspended:
                    listener.api(self, networkMonitorDidEnterBackground: networkMonitor)
                }
            }
            self.logger.log(networkMonitor, .info)
        }
    }
}

extension API: Printable {
    /// <mark> CustomDebugStringConvertible
    public var debugDescription: String {
        return """
        \(base)
        \(interceptor?.debugDescription ?? "no interceptor")
        ongoing tasks
        \(storage.debugDescription)
        listeners
        [\(listens.map({ $0.value.debugDescription }).joined(separator: ","))]
        """
    }
}
