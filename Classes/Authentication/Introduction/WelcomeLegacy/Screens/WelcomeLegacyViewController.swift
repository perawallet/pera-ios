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

//   WelcomeLegacyViewController.swift

import UIKit

final class WelcomeLegacyViewController: BaseViewController {
    private lazy var welcomeView = WelcomeLegacyView()
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
        addBarButtons()
    }

    override func bindData() {
        welcomeView.bindData(WelcomeLegacyViewModel(with : flow))
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
    
    private func addPeraWelcomeLogo(_ theme: WelcomeLegacyViewTheme) {
        peraWelcomeLogo.customizeAppearance(theme.peraWelcomeLogo)
        view.addSubview(peraWelcomeLogo)
        
        peraWelcomeLogo.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(theme.peraWelcomeLogoTopInset)
            $0.trailing.equalToSuperview()
        }
    }
}

extension WelcomeLegacyViewController {
    private func addBarButtons() {
        switch flow {
        case .initializeAccount:
            hidesCloseBarButtonItem = true
            
        case .addNewAccount,
             .backUpAccount,
             .none:
            break
        }
    }
}

extension WelcomeLegacyViewController: WelcomeLegacyViewDelegate {
    
    func welcomeViewDidSelectCreateWallet(_ welcomeView: WelcomeLegacyView) {
        open(
            .tutorial(
                flow: flow,
                tutorial: .backUp(
                    flow: flow,
                    address: "temp"
                ),
                walletFlowType: .algo25
            ),
            by: .push
        )
    }
    
    func welcomeViewDidSelectImport(_ welcomeView: WelcomeLegacyView) {
        analytics.track(.onboardWelcomeScreen(type: .recover))
        open(.recoverAccount(flow: flow), by: .push)
    }
    
    func welcomeViewDidSelectWatch(_ welcomeView: WelcomeLegacyView) {
        analytics.track(.onboardWelcomeScreen(type: .watch))

        open(
            .tutorial(flow: .initializeAccount(mode: .watch), tutorial: .watchAccount),
            by: .push
        )
    }

    func welcomeView(_ welcomeView: WelcomeLegacyView, didOpen url: URL) {
        open(url)
    }
}
