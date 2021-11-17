//
//  AlamofireNetworkMonitor.swift
//  Magpie
//
//  Created by Salih Karasuluoglu on 18.04.2019.
//

import Alamofire
import Foundation

open class AlamofireNetworkMonitor: NetworkMonitor {
    public typealias ReachabilityStatus = NetworkReachabilityManager.NetworkReachabilityStatus
    public typealias ReachabilityConnection = NetworkReachabilityManager.NetworkReachabilityStatus.ConnectionType

    public var reachabilityManager: NetworkReachabilityManager?
    public var lastStatus: NetworkStatus = .unavailable

    public weak var listener: NetworkListener?

    public var currentStatus: NetworkStatus {
        if let reachabilityManager = reachabilityManager {
            return formNetworkStatus(with: reachabilityManager.status)
        }
        return .unavailable
    }

    public init() { }

    deinit {
        stop()
    }

    open func start(on queue: DispatchQueue) {
        if reachabilityManager != nil {
            return
        }
        guard let reachabilityManager = NetworkReachabilityManager() else {
            return
        }
        reachabilityManager.startListening(onQueue: queue) { [weak self] status in
            if let self = self {
                let newStatus = self.formNetworkStatus(with: status)
                self.listener?.networkMonitor(self, didChangeNetworkStatus: NetworkStatusChange(newStatus, self.lastStatus))
                self.lastStatus = newStatus
            }
        }

        self.reachabilityManager = reachabilityManager
    }

    open func stop() {
        reachabilityManager?.stopListening()
        reachabilityManager = nil
    }
}

extension AlamofireNetworkMonitor {
    public func formNetworkStatus(with status: ReachabilityStatus) -> NetworkStatus {
        switch status {
        case .unknown:
            return .undetermined
        case .reachable(let connection):
            return .connected(formNetworkConnection(with: connection))
        case .notReachable:
            if case .connected(let connection) = lastStatus {
                return .disconnected(connection)
            }
            return .disconnected(.none)
        }
    }

    public func formNetworkConnection(with connection: ReachabilityConnection) -> NetworkConnection {
        switch connection {
        case .ethernetOrWiFi:
            return .wifi
        case .cellular:
            return .cellular
        }
    }
}
