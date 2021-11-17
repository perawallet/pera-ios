//
//  Logger+API.swift
//  Pods
//
//  Created by Karasuluoglu on 9.10.2020.
//

import Foundation

extension Logger where Category == APILogCategory {
    func log(_ request: Request, _ logLevel: LogLevel) {
        if !allowedCategories.contains(.request) { return }
        log(Log(message: "\nSENDING...\n\(request.debugDescription)", category: .request, level: .debug))
    }

    func log(_ response: Response, _ logLevel: LogLevel) {
        if !allowedCategories.contains(.response) { return }
        log(Log(message: "\nRECEIVED...\n\(response.debugDescription)", category: .response, level: logLevel))
    }

    func log(_ networkMonitor: NetworkMonitor, _ logLevel: LogLevel) {
        if !allowedCategories.contains(.networkMonitoring) { return }
        log(Log(message: "Network is \(networkMonitor.currentStatus.description)", category: .networkMonitoring, level: logLevel))
    }
}

public enum APILogCategory: String, LogCategory, Printable {
    case request
    case response
    case networkMonitoring
    case uncategorized

    public var description: String {
        return rawValue
    }

    public static let `default`: APILogCategory = .uncategorized
}
