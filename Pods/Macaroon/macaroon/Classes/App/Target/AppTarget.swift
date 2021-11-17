// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

public protocol AppTarget: AnyObject, Decodable {
    var isProduction: Bool { get }
    var bundleIdentifier: String { get }
    var displayName: String { get }
    var version: AppVersion { get }
}

extension AppTarget {
    public static func getBundleIdentifier() -> String {
        return Bundle.main.bundleIdentifier.nonNil
    }

    public static func getDisplayName() -> String {
        let infoDictionary = Bundle.main.infoDictionary
        return ((infoDictionary?["CFBundleDisplayName"] ?? infoDictionary?["CFBundleName"]) as? String).nonNil
    }

    public static func getVersion() -> AppVersion {
        return AppVersion()
    }
}

extension AppTarget {
    /// <note>
    /// - Config file must be in JSON format, keys should be snake case.
    /// - Config file must be saved in the 'main' bundle.
    /// - It is highly recommended for each app target to have its own config file.
    public static func load(fromResource name: String = "AppTargetConfig", withExtension ext: String = "json") -> Self {
        guard let resourceUrl = Bundle.main.url(forResource: name, withExtension: ext) else {
            mc_crash(.appTargetNotFound)
        }
        do {
            let data = try Data(contentsOf: resourceUrl, options: Data.ReadingOptions.uncached)

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(Self.self, from: data)
        } catch let err {
            mc_crash(.appTargetCorrupted(reason: err))
        }
    }
}
