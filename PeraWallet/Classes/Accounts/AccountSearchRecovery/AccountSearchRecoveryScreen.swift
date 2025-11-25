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

//   AccountSearchRecoveryScreen.swift

import UIKit
import SwiftUI

final class AccountSearchRecoveryScreen : SwiftUICompatibilityBaseViewController {
    init(configuration: ViewControllerConfiguration) {
        if let session = configuration.session,
           let api = configuration.api
        {
            let sharedDataController = configuration.sharedDataController
            let hdWalletStorage = configuration.hdWalletStorage
            let hdWalletService = configuration.hdWalletService
            
            let recoveryView: RecoveryToolView = RecoveryToolView(
                session: session,
                sharedDataController: sharedDataController,
                hdWalletStorage: hdWalletStorage,
                hdWalletService: hdWalletService,
                api: api)
            let hostingController = UIHostingController(rootView: recoveryView)
            super.init(configuration: configuration, hostingController: hostingController)
        } else {
            let hostingController = UIHostingController(rootView: Text("default-error-message"))
            super.init(configuration: configuration, hostingController: hostingController)
        }
    }
    
    override func configureAppearance() {
        view.backgroundColor = Colors.Defaults.background.uiColor
        navigationItem.title = String(localized: "dev-settings-recover-account").capitalized
    }
}
