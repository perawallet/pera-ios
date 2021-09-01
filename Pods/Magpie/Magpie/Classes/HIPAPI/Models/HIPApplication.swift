//
//  HIPApplication.swift
//  Pods
//
//  Created by Karasuluoglu on 2.11.2020.
//

import Foundation

open class HIPApplication {
    public let name: String
    public let packageName: String
    public let version: String

    public init() {
        let mainBundle = Bundle.main
        let infoDictionary = mainBundle.infoDictionary

        name = (infoDictionary?["CFBundleDisplayName"] ?? infoDictionary?["CFBundleName"]) as? String ?? ""
        packageName = mainBundle.bundleIdentifier ?? ""
        version = [
            infoDictionary?["CFBundleShortVersionString"] as? String,
            infoDictionary?["CFBundleVersion"] as? String
        ]
        .compactMap { $0 }
        .joined(separator: "-")
    }
}

extension HIPApplication: Printable {
    /// <mark> CustomDebugStringConvertible
    public var debugDescription: String {
        return "\(name) v\(version) (\(packageName))"
    }
}
