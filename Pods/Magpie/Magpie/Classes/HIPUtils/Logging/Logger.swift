//
//  Logger.swift
//  Magpie
//
//  Created by Salih Karasuluoglu on 23.04.2019.
//

import Foundation
import os.log

public struct Logger<Category: LogCategory> {
    public var isEnabled = false

    public var allowedCategories = Category.allCases
    public var allowedLevels = LogLevel.allCases

    public let subsystem: String

    public init(subsystem: String) {
        self.subsystem = subsystem
    }

    public func log(_ instance: Log<Category>) {
        if !isEnabled { return }
        if !allowedLevels.contains(.debug) && !allowedLevels.contains(instance.level) { return }

        let tag = OSLog(subsystem: subsystem, category: instance.category.description)
        os_log("%{private}@", log: tag, type: instance.level.osLogType, instance.message)
    }
}

extension Logger: Printable {
    /// <mark> CustomDebugStringConvertible
    public var debugDescription: String {
        return """
        Subsystem: \(subsystem)
        Categories: \(allowedCategories.map(\.debugDescription).joined(separator: ","))
        Levels: \(allowedLevels.map(\.debugDescription).joined(separator: ","))
        """
    }
}

public struct Log<Category: LogCategory> {
    public let message: String
    public let category: Category
    public let level: LogLevel

    public init(
        message: String,
        category: Category = .default,
        level: LogLevel = .debug
    ) {
        self.message = message
        self.category = category
        self.level = level
    }
}

extension Log: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(message: value)
    }
}

extension Log: Printable {
    /// <mark> CustomDebugStringConvertible
    public var debugDescription: String {
        return "[\(category.debugDescription)][\(level.debugDescription)]\(message)"
    }
}

public protocol LogCategory: CaseIterable, Equatable, Printable {
    static var `default`: Self { get }
}

public enum LogLevel: CaseIterable {
    case info
    case warning
    case error
    case debug /// <note> debug = info + warning + error
}

extension LogLevel {
    var osLogType: OSLogType {
        switch self {
            case .info:
                return .info
            case .warning:
                return .fault
            case .error:
                return .error
            case .debug:
                return .debug
        }
    }
}

extension LogLevel: Printable {
    /// <mark> CustomDebugStringConvertible
    public var debugDescription: String {
        switch self {
            case .info:
                return "Info"
            case .warning:
                return "Warning"
            case .error:
                return "Error"
            case .debug:
                return "Debug"
        }
    }
}
