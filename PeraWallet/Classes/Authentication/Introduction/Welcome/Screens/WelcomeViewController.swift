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
//  WelcomeViewController.swift

import UIKit

final class WelcomeViewController: BaseViewController {
    private lazy var welcomeView = WelcomeView()
    private lazy var peraWelcomeLogo = UIImageView()
    private lazy var theme = Theme()

    private let flow: AccountSetupFlow
    private let featureFlagService: FeatureFlagServicing
    private lazy var transitionToMnemonicTypeSelection = BottomSheetTransition(presentingViewController: self)

    init(flow: AccountSetupFlow, configuration: ViewControllerConfiguration) {
        self.flow = flow
        self.featureFlagService = configuration.featureFlagService
        super.init(configuration: configuration)
    }

    override func configureNavigationBarAppearance() {
        hidesCloseBarButtonItem = true
    }

    override func bindData() {
        welcomeView.bindData(WelcomeViewModel(with : flow))
    }

    override func linkInteractors() {
        welcomeView.delegate = self
        welcomeView.linkInteractors()
    }

    override func setListeners() {
        welcomeView.setListeners()
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
        welcomeView.customize(theme.welcomeViewTheme, configuration: configuration)

        prepareWholeScreenLayoutFor(welcomeView)
        
        addPeraWelcomeLogo(theme.welcomeViewTheme)
    }
    
    private func addPeraWelcomeLogo(_ theme: WelcomeViewTheme) {
        peraWelcomeLogo.customizeAppearance(theme.peraWelcomeLogo)
        view.addSubview(peraWelcomeLogo)
        
        peraWelcomeLogo.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(theme.peraWelcomeLogoTopInset)
            $0.trailing.equalToSuperview()
        }
    }
}

extension WelcomeViewController: WelcomeViewDelegate {
    func welcomeViewDidSelectCreateWallet(_ welcomeView: WelcomeView) {
        analytics.track(.createNewWallet())
        guard let account = createAccount() else { return }
        navigateToSetupAddressNameScreen(account)
    }
    
    func welcomeViewDidSelectImport(_ welcomeView: WelcomeView) {
        analytics.track(.importAccount())
        open(.recoverAccount(flow: flow), by: .push)
    }

    func welcomeView(_ welcomeView: WelcomeView, didOpen url: URL) {
        open(url)
    }
    
    private func navigateToSetupAddressNameScreen(_ account: AccountInformation) {
        let screen = open(
            .addressNameSetup(
                flow: flow,
                mode: .addBip39Wallet,
                account: account
            ),
            by: .push
        ) as? AddressNameSetupViewController
        screen?.hidesCloseBarButtonItem = true
        screen?.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    private func openTutorialScreen(walletFlowType: WalletFlowType) {
        analytics.track(.onboardWelcomeScreen(type: .create))
        switch walletFlowType {
        case .algo25:
            open(
                .tutorial(
                    flow: flow,
                    tutorial: .backUp(
                        flow: flow,
                        address: "temp"
                    ),
                    walletFlowType: walletFlowType
                ),
                by: .push
            )
        case .bip39:
            open(
                .tutorial(
                    flow: flow,
                    tutorial: .backUpBip39(
                        flow: flow,
                        address: "temp"
                    ),
                    walletFlowType: walletFlowType
                ),
                by: .push
            )
        }

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
        
        let user = User(accounts: [account])
        session?.authenticatedUser = user
        session?.authenticatedUser?.setWalletName(for: hdWalletAddressDetail.walletId)

        return account
    }
}
