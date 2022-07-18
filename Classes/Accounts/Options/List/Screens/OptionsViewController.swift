// Copyright 2022 Pera Wallet, LDA

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
//  OptionsViewController.swift

import Foundation
import MacaroonBottomSheet
import MacaroonUIKit
import MagpieExceptions
import UIKit

final class OptionsViewController:
    BaseScrollViewController,
    BottomSheetPresentable {
    weak var delegate: OptionsViewControllerDelegate?

    override var shouldShowNavigationBar: Bool {
        return false
    }
    
    private lazy var primaryContextView = VStackView()
    private lazy var secondaryContextView = VStackView()
    
    private var muteNotificationsView: ListActionView?

    private let account: Account
    private let optionGroup: OptionGroup
    
    private let theme: OptionsViewControllerTheme
    
    init(
        account: Account,
        configuration: ViewControllerConfiguration,
        theme: OptionsViewControllerTheme = .init()
    ) {
        self.account = account
        self.optionGroup = OptionGroup.makeOptionGroup(for: account)
        self.theme = theme
        
        super.init(configuration: configuration)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        build()
    }
    
    private func build() {
        addBackground()
        addContext()
        addActions()
    }
}

extension OptionsViewController {
    private func addBackground() {
        view.customizeAppearance(theme.background)
    }

    private func addContext() {
        addPrimaryContext()
        addSecondaryContext()
    }

    private func addActions() {
        addActions(
            optionGroup.primaryOptions,
            to: primaryContextView
        )
        addActions(
            optionGroup.secondaryOptions,
            to: secondaryContextView
        )
    }
    
    private func addPrimaryContext() {
        contentView.addSubview(primaryContextView)
        primaryContextView.directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: theme.primaryContextPaddings.top,
            leading: theme.primaryContextPaddings.leading,
            bottom: theme.primaryContextPaddings.bottom,
            trailing: theme.primaryContextPaddings.trailing
        )
        primaryContextView.isLayoutMarginsRelativeArrangement = true
        primaryContextView.snp.makeConstraints {
            $0.setPaddings(
                (0, 0, .noMetric, 0)
            )
        }
    }

    private func addSecondaryContext() {
        let separator = contentView.attachSeparator(
            theme.separator,
            to: primaryContextView,
            margin: theme.verticalPadding
        )

        contentView.addSubview(secondaryContextView)
        secondaryContextView.directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: theme.secondaryContextPaddings.top,
            leading: theme.secondaryContextPaddings.leading,
            bottom: theme.secondaryContextPaddings.bottom,
            trailing: theme.secondaryContextPaddings.trailing
        )
        secondaryContextView.isLayoutMarginsRelativeArrangement = true
        secondaryContextView.snp.makeConstraints {
            $0.top == separator
            $0.setPaddings(
                (.noMetric, 0, 0, 0)
            )
        }
    }
    
    private func addActions(
        _ options: [Option],
        to stackView: UIStackView
    ) {
        options.forEach {
            switch $0 {
            case .copyAddress:
                addAction(
                    CopyAddressListActionViewModel(account),
                    #selector(copyAddress),
                    to: stackView
                )
            case .rekey:
                addAction(
                    RekeyAccountListActionViewModel(),
                    #selector(rekeyAccount),
                    to: stackView
                )
            case .rekeyInformation:
                addAction(
                    ShowQrCodeListActionViewModel(),
                    #selector(showQRCode),
                    to: stackView
                )
            case .viewPassphrase:
                addAction(
                    ViewPassphraseListActionViewModel(),
                    #selector(viewPassphrase),
                    to: stackView
                )
            case .muteNotifications:
                muteNotificationsView = addAction(
                    MuteNotificationsListActionViewModel(account),
                    #selector(muteNotifications),
                    to: stackView
                )
            case .renameAccount:
                addAction(
                    RenameAccountListActionViewModel(),
                    #selector(renameAccount),
                    to: stackView
                )
            case .removeAccount:
                addAction(
                    RemoveAccountListActionViewModel(),
                    #selector(removeAccount),
                    to: stackView
                )
            }
        }
    }
    
    @discardableResult
    private func addAction(
        _ viewModel: ListActionViewModel,
        _ selector: Selector,
        to stackView: UIStackView
    ) -> ListActionView {
        let actionView = ListActionView()
        
        actionView.customize(theme.action)
        actionView.bindData(viewModel)
        
        stackView.addArrangedSubview(actionView)
        
        actionView.addTouch(
            target: self,
            action: selector
        )
        
        return actionView
    }
}

extension OptionsViewController {
    @objc
    private func copyAddress() {
        dismissScreen()
        delegate?.optionsViewControllerDidCopyAddress(self)
    }
    
    @objc
    private func rekeyAccount() {
        closeScreen(by: .dismiss) {
            [weak self] in
            guard let self = self else { return }
            
            self.delegate?.optionsViewControllerDidOpenRekeying(self)
        }
    }
    
    @objc
    private func showQRCode() {
        closeScreen(by: .dismiss) {
            [weak self] in
            guard let self = self else { return }
            
            self.delegate?.optionsViewControllerDidViewRekeyInformation(self)
        }
    }
    
    @objc
    private func viewPassphrase() {
        closeScreen(by: .dismiss) {
            [weak self] in
            guard let self = self else { return }

            self.delegate?.optionsViewControllerDidViewPassphrase(self)
        }
    }
    
    @objc
    private func muteNotifications() {
        updateNotificationStatus()
    }
    
    @objc
    private func renameAccount() {
        closeScreen(by: .dismiss) {
            [weak self] in
            guard let self = self else { return }

            self.delegate?.optionsViewControllerDidRenameAccount(self)
        }
    }
    
    @objc
    private func removeAccount() {
        closeScreen(by: .dismiss) {
            [weak self] in
            guard let self = self else { return }
            
            self.delegate?.optionsViewControllerDidRemoveAccount(self)
        }
    }
}

extension OptionsViewController {
    private func updateNotificationStatus() {
        guard
            let network = api?.network,
            let deviceId = session?.authenticatedUser?.getDeviceId(on: network)
        else {
            return
        }

        loadingController?.startLoadingWithMessage("title-loading".localized)

        let draft = NotificationFilterDraft(
            deviceId: deviceId,
            accountAddress: account.address,
            receivesNotifications: !account.receivesNotification
        )

        api?.updateNotificationFilter(draft) {
            [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                self.didUpdateNotificationStatus(response)
            case .failure(_, let apiErrorDetail):
                self.didFailToUpdateNotificationStatus(apiErrorDetail)
            }
            
            self.loadingController?.stopLoading()
        }
    }

    private func didUpdateNotificationStatus(
        _ response: NotificationFilterResponse
    ) {
        account.receivesNotification = response.receivesNotification
        
        if let localAccount = session?.accountInformation(from: account.address) {
            localAccount.receivesNotification = response.receivesNotification
            session?.authenticatedUser?.updateAccount(localAccount)
        }

        muteNotificationsView?.bindData(MuteNotificationsListActionViewModel(account))
    }

    private func didFailToUpdateNotificationStatus(
        _ apiErrorDetail: HIPAPIError?
    ) {
        bannerController?.presentErrorBanner(
            title: "title-error".localized,
            message: apiErrorDetail?.fallbackMessage ?? "transaction-filter-error-title".localized
        )
    }
}

extension OptionsViewController {
    struct OptionGroup {
        let primaryOptions: [Option]
        let secondaryOptions: [Option]

        static func makeOptionGroup(
            for account: Account
        ) -> OptionGroup {
            return account.isWatchAccount()
            ? makeOptionGroup(forWatchAccount: account)
            : makeOptionGroup(forNonWatchAccount: account)
        }

        private static func makeOptionGroup(
            forWatchAccount account: Account
        ) -> OptionGroup {
            let primaryOptions: [Option] = [
                .copyAddress
            ]

            let secondaryOptions: [Option] = [
                .renameAccount,
                .muteNotifications,
                .removeAccount
            ]
            return OptionGroup(
                primaryOptions: primaryOptions,
                secondaryOptions: secondaryOptions
            )
        }

        private static func makeOptionGroup(
            forNonWatchAccount account: Account
        ) -> OptionGroup {
            var primaryOptions: [Option] = []

            primaryOptions.append(.copyAddress)

            if account.isRekeyed() {
                primaryOptions.append(.rekeyInformation)
            }

            if !account.requiresLedgerConnection() {
                primaryOptions.append(.viewPassphrase)
            }

            primaryOptions.append(.rekey)

            let secondaryOptions: [Option] = [
                .muteNotifications,
                .renameAccount,
                .removeAccount
            ]

            return OptionGroup(
                primaryOptions: primaryOptions,
                secondaryOptions: secondaryOptions
            )
        }
    }

    enum Option {
        case copyAddress
        case rekey
        case rekeyInformation
        case viewPassphrase
        case muteNotifications
        case renameAccount
        case removeAccount
    }
}

protocol OptionsViewControllerDelegate: AnyObject {
    func optionsViewControllerDidCopyAddress(
        _ optionsViewController: OptionsViewController
    )
    func optionsViewControllerDidOpenRekeying(
        _ optionsViewController: OptionsViewController
    )
    func optionsViewControllerDidViewPassphrase(
        _ optionsViewController: OptionsViewController
    )
    func optionsViewControllerDidViewRekeyInformation(
        _ optionsViewController: OptionsViewController
    )
    func optionsViewControllerDidRenameAccount(
        _ optionsViewController: OptionsViewController
    )
    func optionsViewControllerDidRemoveAccount(
        _ optionsViewController: OptionsViewController
    )
}
