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

//
//  DeveloperSettings.swift

import UIKit

public enum DeveloperSettings: Settings {
    case nodeSettings
    case dispenser
    case createAlgo25Account
    case recoverAccount
    case developerMenu
    
    public var image: UIImage? {
        switch self {
        case .nodeSettings: img("icon-settings-node")
        case .dispenser: img("icon-settings-dispenser")
        case .createAlgo25Account: img("icon-settings-create-algo25")
        case .recoverAccount: img("icon-recover-passphrase")
        case .developerMenu: img("icon-asset-manage")?.withTintColor(.Text.main)
        }
    }
    
    public var name: String {
        switch self {
        case .nodeSettings: String(localized: "node-settings-title")
        case .dispenser: String(localized: "settings-developer-dispenser")
        case .createAlgo25Account: String(localized: "dev-settings-create-algo25-account")
        case .recoverAccount: String(localized: "dev-settings-recover-account")
        case .developerMenu: String(localized: "settings-secret-dev-menu")
        }
    }

    public var subtitle: String? { nil }
}
