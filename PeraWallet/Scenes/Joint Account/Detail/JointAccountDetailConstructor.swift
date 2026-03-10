// Copyright 2022-2026 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   JointAccountDetailConstructor.swift

import UIKit
import SwiftUI
import pera_wallet_core

enum JointAccountDetailConstructor {
    
    static func buildScene(account: Account, accountsService: AccountsServiceable, legacyBannerController: BannerController?) -> JointAccountDetail {
        let model = JointAccountDetailModel(account: account, accountsService: accountsService, legacyBannerController: legacyBannerController)
        return JointAccountDetail(model: model)
    }
    
    static func buildCompatibilityViewController(configuration: ViewControllerConfiguration, account: Account, accountsService: AccountsServiceable) -> UIViewController {
        let view = buildScene(account: account, accountsService: accountsService, legacyBannerController: configuration.bannerController)
        return JointAccountDetailController(rootView: view)
    }
}
