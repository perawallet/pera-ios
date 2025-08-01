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

//   RecoverAccountViewController.swift

import UIKit

final class RecoverAccountViewController: BaseViewController {
    private lazy var addAccountView = RecoverAccountView()
    private lazy var theme = Theme()
    private lazy var transitionToMnemonicTypeSelection = BottomSheetTransition(presentingViewController: self)
    private lazy var accountImportCoordinator = AccountImportFlowCoordinator(
        presentingScreen: self
    )
    private lazy var secureBackupCoordinator = AlgorandSecureBackupImportFlowCoordinator(
        presentingScreen: self
    )
    private let flow: AccountSetupFlow
    private let featureFlagService: FeatureFlagServicing

    private var initializeAccount: Bool {
        switch flow {
        case .initializeAccount:
            return true
        default:
            return false
        }
    }

    init(flow: AccountSetupFlow, configuration: ViewControllerConfiguration) {
        self.flow = flow
        self.featureFlagService = configuration.featureFlagService
        super.init(configuration: configuration)
    }

    override func configureNavigationBarAppearance() {
        addBarButtons()
    }

    override func configureAppearance() {
        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
    }

    override func bindData() {
        addAccountView.bindData(RecoverAccountViewModel())
    }

    override func linkInteractors() {
        addAccountView.delegate = self
    }

    override func setListeners() {
        addAccountView.setListeners()
    }

    override func prepareLayout() {
        switch flow {
        case .initializeAccount:
            addAccountView.customize(theme.recoverWelcomeViewTheme, configuration: configuration)
        default:
            addAccountView.customize(theme.recoverAddAccountViewTheme, configuration: configuration)
        }

        prepareWholeScreenLayoutFor(addAccountView)
    }
}

extension RecoverAccountViewController {
    private func addBarButtons() {
        switch flow {
        case .initializeAccount:
            addSkipBarButtonItem()
        default:
            break
        }
    }

    private func addSkipBarButtonItem() {
        let skipBarButtonItem = ALGBarButtonItem(kind: .skip) { [unowned self] in
            self.session?.createUser()
            self.launchMain()
        }

        rightBarButtonItems = [skipBarButtonItem]
    }
}

extension RecoverAccountViewController: RecoverAccountViewDelegate {
    func recoverAccountView(_ recoverAccountView: RecoverAccountView, didSelect type: RecoverType) {
        switch type {
        case .passphrase:
            let eventHandler: MnemonicTypeSelectionScreen.EventHandler = {
                [unowned self] event in
                switch event {
                case .didSelectBip39:
                    analytics.track(.onboardCreateAccount(type: .recoverOneKey))
                    open(.tutorial(flow: flow, tutorial: .recoverWithPassphrase(walletFlowType: .bip39), walletFlowType: .bip39), by: .push)
                case .didSelectAlgo25:
                    analytics.track(.onboardCreateAccount(type: .recoverAlgo25))
                    open(.tutorial(flow: flow, tutorial: .recoverWithPassphrase(walletFlowType: .algo25), walletFlowType:
                            .algo25), by: .push)
                }
            }
            transitionToMnemonicTypeSelection.perform(.mnemonicTypeSelection(eventHandler: eventHandler), by: .present)
        case .importFromSecureBackup:
            secureBackupCoordinator.launch()
        case .ledger:
            open(.tutorial(flow: flow, tutorial: .recoverWithLedger), by: .push)
        case .importFromWeb:
            accountImportCoordinator.eventHandler = {
                [weak self] event in
                guard let self else {
                    return
                }

                switch event {
                case .didFinish:
                    if self.initializeAccount {
                        self.launchMain()
                    }
                }
            }
            accountImportCoordinator.launch(qrBackupParameters: nil)
        case .qr:
            openQRScanner()
        default:
            break
        }
    }
    
    private func openQRScanner() {
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            displaySimpleAlertWith(
                title: String(localized: "qr-scan-error-title"),
                message: String(localized: "qr-scan-error-message")
            )
            return
        }

        let controller = open(.qrScanner(canReadWCSession: false), by: .push) as? QRScannerViewController
        controller?.delegate = self
    }
}

extension RecoverAccountViewController: QRScannerViewControllerDelegate {
    func qrScannerViewController(
        _ controller: QRScannerViewController,
        didRead qrText: QRText,
        completionHandler: EmptyHandler?
    ) {
        guard qrText.mode == .mnemonic,
            let mnemonics = qrText.mnemonic else {
            displaySimpleAlertWith(
                title: String(localized: "title-error"),
                message: String(localized: "qr-scan-should-scan-mnemonics-message")
            ) { _ in
                completionHandler?()
            }

            return
        }

        open(
            .accountRecover(
                flow: flow,
                initialMnemonic: mnemonics
            ),
            by: .push
        )
    }
}
