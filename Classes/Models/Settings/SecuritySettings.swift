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
//   SecuritySettings.swift

import UIKit

enum SecuritySettings {
    case pinCodeActivation
    case pinCodeChange
    case localAuthentication
    case rekeySupport
}
    
extension SecuritySettings: Settings {
    
    var image: UIImage? {
        switch self {
        case .pinCodeActivation:
            return img("icon-settings-security")
        case .pinCodeChange:
            return img("icon-settings-pinCode")
        case .localAuthentication:
            return img("icon-settings-localAuthentication")
        case .rekeySupport:
            return .iconSettingsRekey
        }
    }
    
    var name: String {
        switch self {
        case .pinCodeActivation:
            return String(localized: "security-settings-pinCode-activation")
        case .pinCodeChange:
            return String(localized: "security-settings-pinCode-change")
        case .localAuthentication:
            return String(localized: "security-settings-localAuthentication")
        case .rekeySupport:
            return String(localized: "security-settings-rekey-support")
        }
    }

    var subtitle: String? { nil }
}
