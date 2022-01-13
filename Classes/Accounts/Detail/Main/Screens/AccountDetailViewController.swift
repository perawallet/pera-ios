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
//   AccountDetailViewController.swift

import Foundation
import UIKit

final class AccountDetailViewController: PageContainer {
    private lazy var theme = Theme()
    private lazy var modalTransition = BottomSheetTransition(presentingViewController: self)
    private lazy var assetListScreen = AccountAssetListViewController(account: account, configuration: configuration)
    private lazy var nftListScreen = AccountNFTListViewController(account: account, configuration: configuration)
    private lazy var transactionListScreen = AccountTransactionListViewController(
        draft: AccountTransactionListing(account: account),
        configuration: configuration
    )
    private lazy var localAuthenticator = LocalAuthenticator()

    private lazy var accountTitleView = ImageWithTitleView()

    private let account: Account

    init(account: Account, configuration: ViewControllerConfiguration) {
        self.account = account
        super.init(configuration: configuration)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setPageBarItems()
        addTitleView()
    }

    override func configureNavigationBarAppearance() {
        addOptionsBarButton()
    }

    override func configureAppearance() {
        super.configureAppearance()
        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
    }
}

extension AccountDetailViewController {
    private func addOptionsBarButton() {
        let optionsBarButtonItem = ALGBarButtonItem(kind: .options) { [weak self] in
            guard let self = self else {
                return
            }

            self.modalTransition.perform(.options(account: self.account, delegate: self))
        }

        rightBarButtonItems = [optionsBarButtonItem]
    }

    private func setPageBarItems() {
        items = [
            AssetListPageBarItem(screen: assetListScreen),
            NFTListPageBarItem(screen: nftListScreen),
            TransactionListPageBarItem(screen: transactionListScreen)
        ]
    }

    private func addTitleView() {
        accountTitleView.customize(AccountNameViewSmallTheme())
        accountTitleView.bindData(AccountNameViewModel(account: account))

        navigationItem.titleView = accountTitleView
    }
}

extension AccountDetailViewController: OptionsViewControllerDelegate {
    func optionsViewControllerDidCopyAddress(_ optionsViewController: OptionsViewController) {
        log(ReceiveCopyEvent(address: account.address))
        UIPasteboard.general.string = account.address
        bannerController?.presentInfoBanner("qr-creation-copied".localized)
    }

    func optionsViewControllerDidOpenRekeying(_ optionsViewController: OptionsViewController) {
        open(
            .rekeyInstruction(account: account),
            by: .customPresent(
                presentationStyle: .fullScreen,
                transitionStyle: nil,
                transitioningDelegate: nil
            )
        )
    }

    func optionsViewControllerDidRemoveAsset(_ optionsViewController: OptionsViewController) {
        let controller = open(.removeAsset(account: account), by: .present) as? ManageAssetsViewController
        controller?.delegate = self
    }

    func optionsViewControllerDidViewPassphrase(_ optionsViewController: OptionsViewController) {
        guard let session = session else {
            return
        }

        if !session.hasPassword() {
            presentPassphraseView()
            return
        }

        if localAuthenticator.localAuthenticationStatus != .allowed {
            let controller = open(
                .choosePassword(mode: .confirm("title-enter-pin-for-passphrase".localized), flow: nil, route: nil),
                by: .present
            ) as? ChoosePasswordViewController
            controller?.delegate = self
            return
        }

        localAuthenticator.authenticate { [weak self] error in
            guard let self = self,
                  error == nil else {
                return
            }

            self.presentPassphraseView()
        }
    }

    private func presentPassphraseView() {
        modalTransition.perform(.passphraseDisplay(address: account.address))
    }

    func optionsViewControllerDidViewRekeyInformation(_ optionsViewController: OptionsViewController) {
        guard let authAddress = account.authAddress else {
            return
        }

        let draft = QRCreationDraft(address: authAddress, mode: .address, title: account.name)
        open(.qrGenerator(title: "options-auth-account".localized, draft: draft, isTrackable: true), by: .present)
    }

    func optionsViewControllerDidRemoveAccount(_ optionsViewController: OptionsViewController) {
        displayRemoveAccountAlert()
    }

    private func displayRemoveAccountAlert() {
        let configurator = BottomWarningViewConfigurator(
            image: "icon-trash-red".uiImage,
            title: "options-remove-account".localized,
            description: "options-remove-alert-explanation".localized,
            primaryActionButtonTitle: "title-remove".localized,
            secondaryActionButtonTitle: "title-keep".localized,
            primaryAction: { [weak self] in
                self?.removeAccount()
            }
        )

        modalTransition.perform(.bottomWarning(configurator: configurator))
    }

    private func removeAccount() {
        guard let user = session?.authenticatedUser,
              let accountInformation = session?.accountInformation(from: account.address) else {
            return
        }

        session?.removeAccount(account)
        user.removeAccount(accountInformation)
        session?.authenticatedUser = user
        popScreen()
    }
}

extension AccountDetailViewController: ChoosePasswordViewControllerDelegate {
    func choosePasswordViewController(_ choosePasswordViewController: ChoosePasswordViewController, didConfirmPassword isConfirmed: Bool) {
        if isConfirmed {
            presentPassphraseView()
        } else {
            displaySimpleAlertWith(
                title: "password-verify-fail-title".localized,
                message: "options-view-passphrase-password-alert-message".localized
            )
        }
    }
}

extension AccountDetailViewController: ManageAssetsViewControllerDelegate {
    func manageAssetsViewController(
        _ assetRemovalViewController: ManageAssetsViewController,
        didRemove assetDetail: AssetDetail,
        from account: Account
    ) {
        assetListScreen.removeAsset(assetDetail)
    }
}

extension AccountDetailViewController {
    struct AssetListPageBarItem: PageBarItem {
        let id: String
        let barButtonItem: PageBarButtonItem
        let screen: UIViewController

        init(screen: UIViewController) {
            self.id = AccountDetailPageBarItemID.assets.rawValue
            self.barButtonItem = PrimaryPageBarButtonItem(title: "accounts-title-assets".localized)
            self.screen = screen
        }
    }

    struct NFTListPageBarItem: PageBarItem {
        let id: String
        let barButtonItem: PageBarButtonItem
        let screen: UIViewController

        init(screen: UIViewController) {
            self.id = AccountDetailPageBarItemID.nfts.rawValue
            self.barButtonItem = PrimaryPageBarButtonItem(title: "accounts-title-nfts".localized)
            self.screen = screen
        }
    }

    struct TransactionListPageBarItem: PageBarItem {
        let id: String
        let barButtonItem: PageBarButtonItem
        let screen: UIViewController

        init(screen: UIViewController) {
            self.id = AccountDetailPageBarItemID.transactions.rawValue
            self.barButtonItem = PrimaryPageBarButtonItem(title: "accounts-title-history".localized)
            self.screen = screen
        }
    }


    enum AccountDetailPageBarItemID: String {
        case assets
        case nfts
        case transactions
    }
}
