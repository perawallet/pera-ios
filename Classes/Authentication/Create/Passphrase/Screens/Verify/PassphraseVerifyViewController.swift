// Copyright 2025 Pera Wallet, LDA

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
//  PassphraseVerifyViewController.swift

import UIKit
import AVFoundation

final class PassphraseVerifyViewController: BaseScrollViewController {
    private lazy var pushNotificationController = PushNotificationController(
        target: target,
        session: session!,
        api: api!
    )

    private lazy var contextView = PassphraseVerifyView()
        
    private lazy var theme = Theme()

    private lazy var dataSource: PassphraseVerifyDataSource = {
        return PassphraseVerifyDataSource(
            address: address,
            walletFlowType: walletFlowType,
            configuration: configuration
        )
    }()

    private let address: PublicKey
    private let walletFlowType: WalletFlowType
    private let flow: AccountSetupFlow

    init(
        address: PublicKey,
        walletFlowType: WalletFlowType,
        flow: AccountSetupFlow,
        configuration: ViewControllerConfiguration
    ) {
        self.address = address
        self.walletFlowType = walletFlowType
        self.flow = flow

        super.init(configuration: configuration)
    }
    
    override func linkInteractors() {
        super.linkInteractors()
        
        contextView.startObserving(event: .next) {
            [weak self] in
            guard let self = self else { return }
            
            if !self.dataSource.verifyPassphrase() {
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                self.bannerController?.presentErrorBanner(
                    title: String(localized: "title-error"),
                    message: String(localized: "passphrase-verify-wrong-message")
                )
                self.contextView.reset()
                self.dataSource.resetAndReloadData()
                return
            }
                    
            if flow.isBackUpAccount {
                let localAccount = session?.accountInformation(from: address)
                guard let localAccount else { return }

                self.open(
                    .tutorial(
                        flow: self.flow,
                        tutorial: .passphraseVerified(account: localAccount, walletFlowType: walletFlowType)
                    ),
                    by: .push
                )
                return
            }

            guard let account = self.createAccount() else {
                return
            }
            
            analytics.track(.onboardCreateAccountPassphrase(type: .verifyComplete))

            self.open(
                .tutorial(
                    flow: self.flow,
                    tutorial: .passphraseVerified(account: account, walletFlowType: walletFlowType)
                ),
                by: .push
            )
        }
    }
    
    override func setListeners() {
        super.setListeners()
        
        dataSource.delegate = self
        contextView.delegate = self
    }

    override func configureAppearance() {
        super.configureAppearance()
        customizeBackground()
    }

    private func customizeBackground() {
        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        scrollView.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        contentView.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
    }

    override func prepareLayout() {
        super.prepareLayout()
        addContextView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.loadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dataSource.cleanData()
    }
}

extension PassphraseVerifyViewController {
    private func addContextView() {
        contextView.customize(PassphraseVerifyViewTheme())
        
        contentView.addSubview(contextView)
        contextView.directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: 0,
            leading: 0,
            bottom: 0,
            trailing: 0
        )

        contextView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.lessThanOrEqualToSuperview()
        }
    }
}

extension PassphraseVerifyViewController: PassphraseVerifyDataSourceDelegate {
    func passphraseVerifyDataSourceDidLoadData(
        _ passphraseVerifyDataSource: PassphraseVerifyDataSource,
        shownMnemonics: [Int: [String]],
        correctIndexes: [Int]
    ) {
        contextView.reset()
        contextView.bindData(
            PassphraseVerifyViewModel(
                shownMnemonics: shownMnemonics,
                correctIndexes: correctIndexes
            )
        )
    }
    
    func passphraseVerifyDataSourceSelectAllItems() {
        contextView.setButtonInteraction()
    }
}

extension PassphraseVerifyViewController: PassphraseVerifyViewDelegate {
    func passphraseVerifyViewDidSelectMnemonic(
        _ passphraseVerifyView: PassphraseVerifyView,
        section: Int,
        item: Int
    ) {
        dataSource.selectMnemonic(section, item)
    }
}

extension PassphraseVerifyViewController {
    private func createAccount() -> AccountInformation? {
        analytics.track(.registerAccount(registrationType: .create))

        switch walletFlowType {
        case .bip39:
            let (hdWalletAddressDetail, address) = configuration.hdWalletService.saveHDWalletAndComposeHDWalletAddressDetail(
                session: session,
                storage: hdWalletStorage,
                entropy: session?.privateData(for: "temp")
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
                isBackedUp: true,
                hdWalletAddressDetail: hdWalletAddressDetail
            )
            
            session?.removePrivateData(for: "temp")
            
            if let authenticatedUser = session?.authenticatedUser {
                authenticatedUser.addAccount(account)
                pushNotificationController.sendDeviceDetails()
            } else {
                let user = User(accounts: [account])
                session?.authenticatedUser = user
            }
            session?.authenticatedUser?.setWalletName(for: hdWalletAddressDetail.walletId)

            return account
        case .algo25:
            guard let tempPrivateKey = session?.privateData(for: "temp"),
                let address = session?.address(for: "temp") else {
                    return nil
            }
            
            let account = AccountInformation(
                address: address,
                name: address.shortAddressDisplay,
                isWatchAccount: false,
                preferredOrder: sharedDataController.getPreferredOrderForNewAccount(),
                isBackedUp: true
            )
            session?.savePrivate(tempPrivateKey, for: address)
            session?.removePrivateData(for: "temp")
            
            if let authenticatedUser = session?.authenticatedUser {
                authenticatedUser.addAccount(account)
                pushNotificationController.sendDeviceDetails()
            } else {
                let user = User(accounts: [account])
                session?.authenticatedUser = user
            }

            return account
        }
    }
}
