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

import UIKit
import MagpieExceptions
import MacaroonBottomSheet
import MacaroonUIKit

final class OptionsViewController:
    BaseScrollViewController,
    BottomSheetPresentable {
    weak var delegate: OptionsViewControllerDelegate?

    override var shouldShowNavigationBar: Bool {
        return false
    }
    
    private lazy var theme = Theme()
    private lazy var contextView = VStackView()

    private let account: Account
    private var options: [Options]
    
    init(account: Account, configuration: ViewControllerConfiguration) {
        self.account = account
        
        if account.isThereAnyDifferentAsset {
            options = Options.allOptions
        } else {
            options = Options.optionsWithoutRemoveAsset
        }
        
        if account.requiresLedgerConnection() {
            _ = options.removeAll { option in
                option == .viewPassphrase
            }
        }
        
        if !account.isRekeyed() {
            _ = options.removeAll { option in
                option == .rekeyInformation
            }
        }
        
        if account.isWatchAccount() {
            options = Options.watchAccountOptions
        }
        
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
        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
    }
    
    private func addContext() {
        contentView.addSubview(contextView)
        contextView.directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: theme.contentPaddings.top,
            leading: theme.contentPaddings.leading,
            bottom: theme.contentPaddings.bottom,
            trailing: theme.contentPaddings.trailing
        )
        contextView.isLayoutMarginsRelativeArrangement = true
        contextView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }
    }
    
    private func addActions() {
        options.forEach {
            switch $0 {
            case .copyAddress:
                addAction(CopyAddressListActionViewModel(account), #selector(copyAddress))
            case .rekey:
                addAction(RekeyAccountListActionViewModel(), #selector(rekeyAccount))
            case .viewPassphrase:
                addAction(ViewPassphraseListActionViewModel(), #selector(viewPassphrase))
            case .muteNotifications:
                addAction(MuteNotificationsListActionViewModel(account), #selector(muteNotifications))
            case .rekeyInformation:
                addAction(ShowQrCodeListActionViewModel(), #selector(showQRCode))
            case .renameAccount:
                addAction(RenameAccountListActionViewModel(), #selector(renameAccount))
            case .removeAsset:
                addAction(ManageAssetsListActionViewModel(), #selector(manageAssets))
            case .removeAccount:
                addAction(RemoveAccountListActionViewModel(), #selector(removeAccount))
            }
        }
    }
    
    private func addAction(
        _ viewModel: ListActionViewModel,
        _ selector: Selector
    ) {
        let actionView = ListActionView()
        
        actionView.customize(theme.action)
        actionView.bindData(viewModel)
        
        contextView.addArrangedSubview(actionView)
        
        actionView.addTouch(
            target: self,
            action: selector
        )
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
        dismissScreen()
        delegate?.optionsViewControllerDidOpenRekeying(self)
    }
    
    @objc
    private func viewPassphrase() {
        closeScreen(by: .dismiss) { [weak self] in
            guard let self = self else {
                return
            }

            self.delegate?.optionsViewControllerDidViewPassphrase(self)
        }
    }
    
    @objc
    private func muteNotifications() {
        updateNotificationStatus()
    }
    
    @objc
    private func showQRCode() {
        dismissScreen()
        delegate?.optionsViewControllerDidViewRekeyInformation(self)
    }
    
    @objc
    private func renameAccount() {
        let controller = open(.editAccount(account: account), by: .push) as? EditAccountViewController
        controller?.delegate = self
    }
    
    @objc
    private func manageAssets() {
        dismissScreen()
        delegate?.optionsViewControllerDidRemoveAsset(self)
    }
    
    @objc
    private func removeAccount() {
        dismissScreen()
        delegate?.optionsViewControllerDidRemoveAccount(self)
    }
}

extension OptionsViewController {
    private func updateNotificationStatus() {
        guard let deviceId = api?.session.authenticatedUser?.deviceId else {
            return
        }

        loadingController?.startLoadingWithMessage("title-loading".localized)

        let draft = NotificationFilterDraft(
            deviceId: deviceId,
            accountAddress: account.address,
            receivesNotifications: !account.receivesNotification
        )

        api?.updateNotificationFilter(draft) { response in
            switch response {
            case let .success(result):
                self.updateNotificationFiltering(with: result)
            case let .failure(_, hipApiError):
                self.displayNotificationFilterError(hipApiError)
            }
        }
    }

    private func updateNotificationFiltering(with result: NotificationFilterResponse) {
        account.receivesNotification = result.receivesNotification
        loadingController?.stopLoading()
        updateAccountForNotificationFilters()
        updateNotificationFilterCell()
    }

    private func updateAccountForNotificationFilters() {
        guard let localAccount = api?.session.accountInformation(from: account.address) else {
            return
        }

        localAccount.receivesNotification = account.receivesNotification
        api?.session.authenticatedUser?.updateAccount(localAccount)
    }

    private func updateNotificationFilterCell() {
        if let index = options.firstIndex(of: .muteNotifications),
           let item = contextView.arrangedSubviews[safe: index] as? ListActionView {
            item.bindData(MuteNotificationsListActionViewModel(account))
        }
    }

    private func displayNotificationFilterError(_ error: HIPAPIError?) {
        loadingController?.stopLoading()
        bannerController?.presentErrorBanner(
            title: "title-error".localized, message: error?.fallbackMessage ?? "transaction-filter-error-title".localized
        )
    }
}

extension OptionsViewController: EditAccountViewControllerDelegate {
    func editAccountViewControllerDidTapDoneButton(_ viewController: EditAccountViewController) {
        delegate?.optionsViewControllerDidRenameAccount(self)
    }
}

extension OptionsViewController {
    enum Options: Int, CaseIterable {
        case copyAddress = 0
        case rekey = 1
        case viewPassphrase = 2
        case muteNotifications = 3
        case rekeyInformation = 4
        case renameAccount = 5
        case removeAsset = 6
        case removeAccount = 7

        static var optionsWithoutRemoveAsset: [Options] {
            return [.copyAddress, .rekey, .rekeyInformation, .viewPassphrase, .muteNotifications, .renameAccount, .removeAccount]
        }

        static var optionsWithoutPassphrase: [Options] {
            return [.copyAddress, .rekey, .rekeyInformation, .muteNotifications, .renameAccount, .removeAsset, .removeAccount]
        }
        
        static var optionsWithoutPassphraseAndRemoveAsset: [Options] {
            return [.copyAddress, .rekey, .rekeyInformation, .muteNotifications, .renameAccount, .removeAccount]
        }
        
        static var allOptions: [Options] {
            return allCases
        }
        
        static var watchAccountOptions: [Options] {
            return [.muteNotifications, .renameAccount, .removeAccount]
        }
    }
}

protocol OptionsViewControllerDelegate: AnyObject {
    func optionsViewControllerDidCopyAddress(_ optionsViewController: OptionsViewController)
    func optionsViewControllerDidOpenRekeying(_ optionsViewController: OptionsViewController)
    func optionsViewControllerDidRemoveAsset(_ optionsViewController: OptionsViewController)
    func optionsViewControllerDidViewPassphrase(_ optionsViewController: OptionsViewController)
    func optionsViewControllerDidViewRekeyInformation(_ optionsViewController: OptionsViewController)
    func optionsViewControllerDidRenameAccount(_ optionsViewController: OptionsViewController)
    func optionsViewControllerDidRemoveAccount(_ optionsViewController: OptionsViewController)
}
