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

//   AddAccountViewController.swift

import UIKit
import pera_wallet_core

final class AddAccountViewController: BaseViewController {
    private lazy var addAccountView = AddAccountView()
    private lazy var peraWelcomeLogo = UIImageView()
    private lazy var theme = Theme()

    private let flow: AccountSetupFlow
    private let featureFlagService: FeatureFlagServicing
    private lazy var transitionToMnemonicTypeSelection = BottomSheetTransition(presentingViewController: self)
    
    private lazy var pushNotificationController = PushNotificationController(
        target: target,
        session: session!,
        api: api!
    )

    init(flow: AccountSetupFlow, configuration: ViewControllerConfiguration) {
        self.flow = flow
        self.featureFlagService = configuration.featureFlagService
        super.init(configuration: configuration)
    }

    override func bindData() {
        addAccountView.bindData(AddAccountViewModel(with: flow))
    }

    override func linkInteractors() {
        addAccountView.delegate = self
        addAccountView.linkInteractors()
    }

    override func setListeners() {
        addAccountView.setListeners()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .clear
        appearance.shadowColor = .clear

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let defaultAppearance = UINavigationBarAppearance()
        defaultAppearance.configureWithOpaqueBackground()
        defaultAppearance.backgroundColor = theme.backgroundColor.uiColor
        defaultAppearance.shadowColor = theme.backgroundColor.uiColor
        
        navigationController?.navigationBar.standardAppearance = defaultAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = defaultAppearance
    }
    
    override func configureAppearance() {
        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
    }

    override func prepareLayout() {
        addAccountView.customize(theme.addAccountViewTheme, configuration: configuration)

        prepareWholeScreenLayoutFor(addAccountView)
        
        addPeraWelcomeLogo(theme.addAccountViewTheme)
    }
    
    private func addPeraWelcomeLogo(_ theme: AddAccountViewTheme) {
        peraWelcomeLogo.customizeAppearance(theme.peraWelcomeLogo)
        view.addSubview(peraWelcomeLogo)
        
        peraWelcomeLogo.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(theme.peraWelcomeLogoTopInset)
            $0.trailing.equalToSuperview()
        }
    }
}

extension AddAccountViewController: AddAccountViewDelegate {
    func addAccountViewDidSelectCreateAddress(_ addAccountView: AddAccountView) {
        open(.hdWalletSetup(flow: flow, mode: .addBip39Address(newAddress: nil)), by: .push)
    }
    
    func addAccountViewDidSelectCreateWallet(_ addAccountView: AddAccountView) {
        analytics.track(.registerAccount(registrationType: .create))
        guard
            let account = createAccount() else {
            return
        }
        
        let screen = open(
            .addressNameSetup(
                flow: flow,
                mode: .addBip39Wallet,
                account: account
            ),
            by: .push
        ) as? AddressNameSetupViewController
        screen?.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        screen?.hidesCloseBarButtonItem = true
    }
    
    func addAccountViewDidSelectImport(_ addAccountView: AddAccountView) {
        analytics.track(.registerAccount(registrationType: .recover))
        open(.recoverAccount(flow: flow), by: .push)
    }
    
    func addAccountViewDidSelectWatch(_ addAccountView: AddAccountView) {
        analytics.track(.registerAccount(registrationType: .watch))

        open(
            .tutorial(flow: .addNewAccount(mode: .watch), tutorial: .watchAccount),
            by: .push
        )
    }

    func addAccountView(_ addAccountView: AddAccountView, didOpen url: URL) {
        open(url)
    }
    
    private func createAccount() -> AccountInformation? {

        let (hdWalletAddressDetail, address) = hdWalletService.saveHDWalletAndComposeHDWalletAddressDetail(
            session: session,
            storage: hdWalletStorage,
            entropy: nil
        )
        
        guard let hdWalletAddressDetail, let address else {
            assertionFailure("Could not create HD wallet")
            return nil
        }
        
        let account = AccountInformation(
            address: address,
            name: address.shortAddressDisplay,
            isWatchAccount: false,
            preferredOrder: sharedDataController.getPreferredOrderForNewAccount(),
            isBackedUp: false,
            hdWalletAddressDetail: hdWalletAddressDetail
        )
        
        if let authenticatedUser = session?.authenticatedUser {
            authenticatedUser.addAccount(account)
            pushNotificationController.sendDeviceDetails()
        } else {
            let user = User(accounts: [account])
            session?.authenticatedUser = user
        }
        session?.authenticatedUser?.setWalletName(for: hdWalletAddressDetail.walletId)

        return account
    }
}
