//
//  NWNetworkMonitor.swift
//  Magpie
//
//  Created by Salih Karasuluoglu on 18.04.2019.
//

import Foundation
import Network

@available (iOS 12.0, *)
open class NWNetworkMonitor: NetworkMonitor {
    public var pathMonitor: NWPathMonitor?
    public var lastStatus: NetworkStatus = .unavailable

    public weak var listener: NetworkListener?

    public var currentStatus: NetworkStatus {
        if let currentPath = pathMonitor?.currentPath {
            return formNetworkStatus(with: currentPath)
        }
        return .unavailable
    }
    
    public init() { }

    deinit {
        stop()
    }

    open func start(on queue: DispatchQueue) {
        if pathMonitor != nil {
            return
        }
        let pathMonitor = NWPathMonitor()
        pathMonitor.pathUpdateHandler = { [weak self] path in
            if let self = self {
                let newStatus = self.formNetworkStatus(with: path)
                self.listener?.networkMonitor(self, didChangeNetworkStatus: NetworkStatusChange(newStatus, self.lastStatus))
                self.lastStatus = newStatus
            }
        }
        pathMonitor.start(queue: queue)

        self.pathMonitor = pathMonitor
    }

    open func stop() {
        pathMonitor?.cancel()
        pathMonitor = nil
    }
}

@available (iOS 12.0, *)
extension NWNetworkMonitor {
    public func formNetworkStatus(with path: NWPath) -> NetworkStatus {
        switch path.status {
        case .requiresConnection:
            return .undetermined
        case .satisfied:
            return .connected(formNetworkConnection(with: path))
        case .unsatisfied:
            if case .connected(let connection) = lastStatus {
                return .disconnected(connection)
            }
            return .disconnected(.none)
        @unknown default:
            return .undetermined
        }
    }

    public func formNetworkConnection(with path: NWPath) -> NetworkConnection {
        if path.status != .satisfied {
            return .none
        }
        if path.usesInterfaceType(.wifi) {
            return .wifi
        }
        if path.usesInterfaceType(.wiredEthernet) {
            return .wiredEthernet
        }
        if path.usesInterfaceType(.cellular) {
            return .cellular
        }
        return .other
    }
}
