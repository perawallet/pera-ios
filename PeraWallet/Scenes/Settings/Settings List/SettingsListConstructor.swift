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

//   SettingsListConstructor.swift

import Foundation
import pera_wallet_core

enum SettingsListConstructor {
    
    static func buildScene(legacyAppConfiguration: AppConfiguration) -> BaseViewController {
        
        let appVersion = Bundle.main.appVersion ?? ""
        let model = SettingsListModel(appVersion: appVersion)
        let controller = SettingsListViewController(model: model)
        let compatibilityController = SettingsListCompatibilityController(configuration: legacyAppConfiguration.all(), hostingController: controller)
        
        controller.onLegacyNavigationOptionSelected = { [weak compatibilityController] in
            compatibilityController?.moveTo(option: $0)
        }
        
        controller.onLogoutButtonTap = { [weak compatibilityController] in
            compatibilityController?.performLogoutAction()
        }
        
        controller.onClicksMissingToUnlock = { [weak compatibilityController] count in
            guard !(PeraUserDefaults.shouldShowDevMenu ?? false) else {
                compatibilityController?.bannerController?.presentInfoBanner(String(localized: "developer-options-already-enable-text"))
                return
            }
            compatibilityController?.bannerController?.presentInfoBanner(String(format: String(localized: "developer-options-clicks-left-unlock"), count))
        }
        
        controller.onDevMenuUnlocked = { [weak compatibilityController] in
            guard !(PeraUserDefaults.shouldShowDevMenu ?? false) else {
                compatibilityController?.bannerController?.presentInfoBanner(String(localized: "developer-options-already-enable-text"))
                return
            }
            PeraUserDefaults.shouldShowDevMenu = true
            compatibilityController?.bannerController?.presentSuccessBanner(title: String(localized: "developer-options-enabled-text"))
        }
        
        return compatibilityController
    }
}
