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

//   SecretDeveloperSettings.swift
    
import pera_wallet_core
import UIKit

public enum SecretDeveloperSettings: Settings, Hashable {
    
public enum SecretDeveloperSettings: Settings, Hashable {
    case enableTestCards
    case overrideRemoteConfig
    
    var image: ImageResource {
        switch self {
        case .enableTestCards: .iconMenuCards
        case .overrideRemoteConfig: .Settings.Icon.developer
        }
    }
    
    var name: String {
        switch self {
        case .enableTestCards: String(localized: "secret-dev-settings-enable-test-cards")
        case .overrideRemoteConfig: String(localized: "override-firebase-title")
        }
    }

    public var subtitle: String? { nil }
}
