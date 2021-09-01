//
//  NetworkMonitor.swift
//  Magpie
//
//  Created by Salih Karasuluoglu on 18.04.2019.
//

import Foundation

public protocol NetworkMonitor: AnyObject, Printable {
    /// <warning> The instances must call listener for the changes on the network.
    var listener: NetworkListener? { get set }
    var currentStatus: NetworkStatus { get }

    func start(on queue: DispatchQueue)
    func stop()
}

extension NetworkMonitor {
    public var isConnected: Bool {
        if case .connected = currentStatus {
            return true
        }
        return false
    }
}

extension NetworkMonitor {
    /// <mark> CustomDebugStringConvertible
    public var debugDescription: String {
        return "Currently \(currentStatus.debugDescription) with \(listener == nil ? "no listener" : "a listener") attached"
    }
}

public protocol NetworkListener: AnyObject {
    func networkMonitor(_ networkMonitor: NetworkMonitor, didChangeNetworkStatus change: NetworkStatusChange)
}

public struct NetworkStatusChange {
    var new: NetworkStatus
    var old: NetworkStatus

    init(
        _ new: NetworkStatus,
        _ old: NetworkStatus
    ) {
        self.new = new
        self.old = old
    }
}

public enum NetworkStatus: Equatable {
    case unavailable
    case undetermined
    case connected(NetworkConnection)
    case disconnected(NetworkConnection)
    case suspended
}

extension NetworkStatus {
    public var connection: NetworkConnection {
        switch self {
        case .unavailable,
             .undetermined,
             .suspended:
            return .none
        case .connected(let connection),
             .disconnected(let connection):
            return connection
        }
    }
}

extension NetworkStatus: Printable {
    /// <mark> CustomDebugStringConvertible
    public var debugDescription: String {
        switch self {
        case .unavailable:
            return "<unavailable>"
        case .undetermined:
            return "<undetermined>"
        case .connected(let connection):
            return "connected via \(connection.debugDescription)"
        case .disconnected(let connection):
            return "disconnected from \(connection.debugDescription)"
        case .suspended:
            return "suspended on background"
        }
    }
}

public enum NetworkConnection: Equatable {
    case none
    case wifi
    case wiredEthernet
    case cellular
    case other
}

extension NetworkConnection: Printable {
    /// <mark> CustomDebugStringConvertible
    public var debugDescription: String {
        switch self {
        case .none:
            return "no connection"
        case .wifi:
            return "wifi"
        case .wiredEthernet:
            return "wired ethernet"
        case .cellular:
            return "cellular"
        case .other:
            return "unknown connection"
        }
    }
}
