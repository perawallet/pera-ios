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

enum DeveloperSettings: Settings {
    case nodeSettings
    case dispenser
    case createAlgo25Account
    
    var image: UIImage? {
        switch self {
        case .nodeSettings:
            return img("icon-settings-node")
        case .dispenser:
            return img("icon-settings-dispenser")
        case .createAlgo25Account:
            return img("icon-settings-create-algo25")
        }
    }
    
    var name: String {
        switch self {
        case .nodeSettings:
            return String(localized: "node-settings-title")
        case .dispenser:
            return String(localized: "settings-developer-dispenser")
        case .createAlgo25Account:
            return String(localized: "dev-settings-create-algo25-account")
        }
    }

    var subtitle: String? {
        return nil
    }
}
