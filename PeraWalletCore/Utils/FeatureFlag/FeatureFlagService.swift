// Copyright 2022-2025 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   FeatureFlagService.swift

import Combine
import FirebaseRemoteConfig
import Foundation

public protocol FeatureFlagServicing {
    /// Fetches and activates remote config values
    func fetchAndActivate() async throws
    
    /// Checks if a feature flag is enabled
    /// - Parameter flag: The feature flag to check
    /// - Returns: Boolean indicating if the flag is enabled
    func isEnabled(_ flag: FeatureFlag) -> Bool
    
    /// Checks if a feature flag has a double value
    /// - Parameter flag: The feature flag to check
    /// - Returns: Double if it gets the value, nil if not
    func double(for flag: FeatureFlag) -> Double?
}

public final class FeatureFlagService: ObservableObject, FeatureFlagServicing {
    private let remoteConfig: RemoteConfig
    
    public init() {
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 3600
        let remoteConfig = RemoteConfig.remoteConfig()
        remoteConfig.configSettings = settings
        self.remoteConfig = remoteConfig
        
        setupDefaults()
    }
    
    private func setupDefaults() {
        let defaults: [String: NSObject] = Dictionary(
            uniqueKeysWithValues: FeatureFlag.allCases.map {
                ($0.rawValue, $0.defaultValue.asNSObject)
            }
        )
        remoteConfig.setDefaults(defaults)
    }
    
    public func fetchAndActivate() async throws {
        try await remoteConfig.fetch()
        try await remoteConfig.activate()
    }
    
    public func isEnabled(_ flag: FeatureFlag) -> Bool {
        let value = remoteConfig.configValue(forKey: flag.rawValue)
        return value.boolValue
    }
    
    public func double(for flag: FeatureFlag) -> Double? {
        let value = remoteConfig.configValue(forKey: flag.rawValue).numberValue.doubleValue
        return value < 0 ? nil : value
    }
}
