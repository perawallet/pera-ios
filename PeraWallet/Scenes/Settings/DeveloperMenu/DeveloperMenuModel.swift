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

//   DeveloperMenuModel.swift

import SwiftUI
import pera_wallet_core

final class DeveloperMenuModel: ObservableObject {
    private let featureFlagService: FeatureFlagServicing
    
    var settings: [SecretDeveloperSettings] = [.enableTestCards, .overrideRemoteConfig]
    var featureFlags = FeatureFlag.allCases.filter { !$0.title.isEmpty }
    @State var enableTestCards = PeraUserDefaults.enableTestCards ?? false
    
    init(featureFlagService: FeatureFlagServicing) {
        self.featureFlagService = featureFlagService
    }
    
    func remoteValueFor(flag: String) -> Bool {
        guard let featureFlag = FeatureFlag(rawValue: flag) else { return false }
        return featureFlagService.isEnabled(featureFlag)
    }
    
    func isOverriden(flag: String) -> Bool {
        RemoteConfigOverride.isEnabled(for: flag)
    }
    
    func overriddenValue(for flag: String) -> Bool {
        RemoteConfigOverride.value(for: flag) ?? false
    }
    
    func overrideValue(_ flag: String, with value: Bool) {
        RemoteConfigOverride.set(value, for: flag)
    }
}
