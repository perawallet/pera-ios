// Copyright 2019 Algorand, Inc.

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
//  TutorialViewController.swift

import UIKit

final class TutorialViewController: BaseScrollViewController {
    override var hidesCloseBarButtonItem: Bool {
        return tutorial == .localAuthentication
    }

    lazy var uiHandlers = TutorialViewControllerUIHandlers()

    private lazy var tutorialView = TutorialView()
    private lazy var theme = Theme()

    private let flow: AccountSetupFlow
    private let tutorial: Tutorial
    private let localAuthenticator = LocalAuthenticator()

    init(flow: AccountSetupFlow, tutorial: Tutorial, configuration: ViewControllerConfiguration) {
        self.flow = flow
        self.tutorial = tutorial
        super.init(configuration: configuration)
    }

    override func configureNavigationBarAppearance() {
        addBarButtons()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setPopGestureEnabledInLocalAuthenticationTutorial(false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        setPopGestureEnabledInLocalAuthenticationTutorial(true)
    }

    override func configureAppearance() {
        super.configureAppearance()
        setNavigationBarTertiaryBackgroundColor()
        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        scrollView.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        contentView.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
    }

    override func bindData() {
        tutorialView.bindData(TutorialViewModel(tutorial))
    }

    override func setListeners() {
        super.setListeners()
        tutorialView.delegate = self
        tutorialView.setListeners()
    }

    override func prepareLayout() {
        super.prepareLayout()
        tutorialView.customize(theme.tutorialViewTheme)

        contentView.addSubview(tutorialView)
        tutorialView.pinToSuperview()
    }
}

extension TutorialViewController {
    private func addBarButtons() {
        switch tutorial {
        case .recover,
             .backUp,
             .watchAccount:
            addInfoBarButton()
        case .passcode:
            addDontAskAgainBarButton()
        default:
            break
        }
    }

    private func addInfoBarButton() {
        let infoBarButtonItem = ALGBarButtonItem(kind: .info) { [weak self] in
            self?.openWalletSupport()
        }

        rightBarButtonItems = [infoBarButtonItem]
    }

    private func addDontAskAgainBarButton() {
        let dontAskAgainBarButtonItem = ALGBarButtonItem(kind: .dontAskAgain) { [weak self] in
            guard let self = self else {
                return
            }

            self.uiHandlers.didTapDontAskAgain?(self)
        }

        rightBarButtonItems = [dontAskAgainBarButtonItem]
    }

    private func openWalletSupport() {
        switch tutorial {
        case .backUp:
            open(AlgorandWeb.backUpSupport.link)
        case .recover:
            open(AlgorandWeb.recoverSupport.link)
        case .watchAccount:
            open(AlgorandWeb.watchAccountSupport.link)
        default:
            break
        }
    }
}

extension TutorialViewController: TutorialViewDelegate {
    func tutorialViewDidTapPrimaryActionButton(_ tutorialView: TutorialView) {
        switch tutorial {
        case .backUp:
            open(.tutorial(flow: flow, tutorial: .writePassphrase), by: .push)
        case .writePassphrase:
            open(.passphraseView(address: "temp"), by: .push)
        case .watchAccount:
            open(.watchAccountAddition(flow: flow), by: .push)
        case .recover:
            open(.accountRecover(flow: flow), by: .push)
        case .passcode:
            open(.choosePassword(mode: .setup, flow: flow, route: nil), by: .push)
        case .localAuthentication:
            askLocalAuthentication()
        case .biometricAuthenticationEnabled:
            dismissScreen()
        case .passphraseVerified:
            open(.accountNameSetup, by: .push)
        case .accountVerified, .ledgerSuccessfullyConnected:
            uiHandlers.didTapButtonPrimaryActionButton?(self)
        case .ledgerSuccessfullyConnected:
            uiHandlers.didTapButtonPrimaryActionButton?(self)
        case .ledger:
            open(.ledgerDeviceList(flow: flow), by: .push)
        case .accountSuccessfullyRekeyed:
            uiHandlers.didTapButtonPrimaryActionButton?(self)
        }
    }

    func tutorialViewDidTapSecondaryActionButton(_ tutorialView: TutorialView) {
        switch tutorial {
        case .passcode:
            dismissScreen()
        case .localAuthentication:
            dismissScreen()
        case .ledger:
            open(.ledgerTutorial(flow: .addNewAccount(mode: .add(type: .pair))), by: .push)
        default:
            break
        }
    }
}

extension TutorialViewController {
    private func setPopGestureEnabledInLocalAuthenticationTutorial(_ isEnabled: Bool) {
        if tutorial == .localAuthentication {
            navigationController?.interactivePopGestureRecognizer?.isEnabled = isEnabled
        }
    }

    private func askLocalAuthentication() {
        if localAuthenticator.isLocalAuthenticationAvailable {
            localAuthenticator.authenticate { error in
                guard error == nil else {
                    return
                }
                self.localAuthenticator.localAuthenticationStatus = .allowed
                self.openModalWhenAuthenticationUpdatesCompleted()
            }
            return
        }

        presentDisabledLocalAuthenticationAlert()
    }

    private func presentDisabledLocalAuthenticationAlert() {
        let alertController = UIAlertController(
            title: "local-authentication-go-settings-title".localized,
            message: "local-authentication-go-settings-text".localized,
            preferredStyle: .alert
        )

        let settingsAction = UIAlertAction(title: "title-go-to-settings".localized, style: .default) { _ in
            UIApplication.shared.openAppSettings()
        }

        let cancelAction = UIAlertAction(title: "title-cancel".localized, style: .cancel, handler: nil)

        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

    private func openModalWhenAuthenticationUpdatesCompleted() {
        open(
            .tutorial(flow: .none, tutorial: .biometricAuthenticationEnabled),
            by: .customPresent(presentationStyle: .fullScreen, transitionStyle: nil, transitioningDelegate: nil)
        )
    }
}

struct TutorialViewControllerUIHandlers {
    var didTapDontAskAgain: ((TutorialViewController) -> Void)?
    var didTapButtonPrimaryActionButton: ((TutorialViewController) -> Void)?
}

enum Tutorial: Equatable {
    case backUp
    case writePassphrase
    case watchAccount
    case recover
    case passcode
    case localAuthentication
    case biometricAuthenticationEnabled
    case passphraseVerified
    case accountVerified
    case ledger
    case ledgerSuccessfullyConnected
    case accountSuccessfullyRekeyed(accountName: String)
}
