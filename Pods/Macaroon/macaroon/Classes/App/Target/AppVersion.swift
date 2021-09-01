// Copyright © 2019 hipolabs. All rights reserved.

import Foundation

public struct AppVersion: ExpressibleByStringLiteral {
    public var versionString: String {
        return "\(major).\(minor).\(patch)"
    }

    public let major: Int
    public let minor: Int
    public let patch: Int

    public init() {
        let versionString = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String).nonNil
        self.init(versionString: versionString)
    }

    public init(versionString: String) {
        let components = versionString.components(separatedBy: ".")
        self.major = components[safe: 0].unwrap(Int.init, or: 1)
        self.minor = components[safe: 1].unwrap(Int.init, or: 0)
        self.patch = components[safe: 2].unwrap(Int.init, or: 0)
    }

    public init(stringLiteral value: String) {
        self.init(versionString: value)
    }
}

extension AppVersion: Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        if lhs.major != rhs.major {
            return lhs.major < rhs.major
        }

        if lhs.minor != rhs.minor {
            return lhs.minor < rhs.minor
        }

        return lhs.patch < rhs.patch
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        return
            lhs.major == rhs.major &&
            lhs.minor == rhs.minor &&
            lhs.patch == rhs.patch
    }
}

extension AppVersion: CustomStringConvertible {
    public var description: String {
        return versionString
    }
}
