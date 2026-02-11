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

//   AddAccountCompatibilityController.swift

import pera_wallet_core
import UIKit

final class AddAccountCompatibilityController: SwiftUICompatibilityBaseViewController {

    // MARK: - Properties
    
    private let legacyFlow: AccountSetupFlow = .addNewAccount(mode: .none)
    
    private lazy var scanQRFlowCoordinator = ScanQRFlowCoordinator(
        analytics: analytics,
        api: api!,
        bannerController: bannerController!,
        loadingController: loadingController!,
        presentingScreen: self,
        session: session!,
        sharedDataController: sharedDataController,
        appLaunchController: configuration.launchController,
        hdWalletStorage: configuration.hdWalletStorage
    )
    
    // MARK: - View Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    // MARK: - Actions
    
    func moveTo(option: AddAccountView.LegacyNavigationOption) {
        switch option {
        case .addAccount:
            addAccount()
        case .importWallet:
            inportWallet()
        case .watchAccount:
            watchAccount()
        case .createUniversalWallet:
            createUniversalWallet()
        case .createAlgo25Wallet:
            createAlgo25Wallet()
        }
    }
    
    func dismiss() {
        dismiss(animated: true)
    }
    
    func learnMore() {
        guard let url = AlgorandWeb.jointAccount.link else { return }
        UIApplication.shared.open(url)
    }
    
    func learnMore() {
        // TODO: replace url for Joint Account Support page when it's available
        guard let url = AlgorandWeb.support.link else { return }
        UIApplication.shared.open(url)
    }
    
    func scanQR() {
        scanQRFlowCoordinator.launch()
    }
    
    private func addAccount() {
        open(.hdWalletSetup(flow: legacyFlow, mode: .addBip39Address(newAddress: nil)), by: .push)
    }
    
    private func inportWallet() {
        analytics.track(.registerAccount(registrationType: .recover))
        open(.recoverAccount(flow: legacyFlow), by: .push)
    }
    
    private func watchAccount() {
        analytics.track(.registerAccount(registrationType: .watch))
        open(.tutorial(flow: .addNewAccount(mode: .watch), tutorial: .watchAccount), by: .push)
    }
    
    private func createUniversalWallet() {
        
        analytics.track(.registerAccount(registrationType: .create))
        guard let account = createUniversalWalletAccount() else { return }
        
        let screen = open(.addressNameSetup(flow: legacyFlow, mode: .addBip39Wallet, account: account), by: .push) as? AddressNameSetupViewController
        screen?.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        screen?.hidesCloseBarButtonItem = true
    }
    
    private func createAlgo25Wallet() {
        
        guard let account = createAlgo25Account() else { return }
        let screen = open(.accountNameSetup(flow: .addNewAccount(mode: .addAlgo25Account), mode: .addAlgo25Account, accountAddress: account.address), by: .push) as? AccountNameSetupViewController
        
        screen?.onAccountCreated = { [weak self] in
            PeraUserDefaults.shouldShowNewAccountAnimation = true
            self?.dismiss()
        }
    }
    
    // MARK: - Helpers
    
    private func createUniversalWalletAccount() -> AccountInformation? {
        guard let session = configuration.session, let api = configuration.api else { return nil }
        let pushNotificationController = PushNotificationController(target: .current, session: session, api: api)
        return try? LegacyBridgeAccountManager.createUniversalWalletAccount(legacyConfiguration: configuration, pushNotificationController: pushNotificationController)
    }
    
    private func createAlgo25Account() -> AccountInformation? {
        guard let session = configuration.session, let api = configuration.api else { return nil }
        let pushNotificationController = PushNotificationController(target: .current, session: session, api: api)
        return LegacyBridgeAccountManager.createAlgo25Account(session: session, pushNotificationController: pushNotificationController)
    }
}
