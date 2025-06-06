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

//   StandardAccountInformationScreen.swift

import Foundation
import UIKit
import MacaroonUIKit
import MacaroonBottomSheet

final class StandardAccountInformationScreen:
    MacaroonUIKit.ScrollScreen,
    BottomSheetScrollPresentable {
    typealias EventHandler = (Event) -> Void
    var eventHandler: EventHandler?

    var modalHeight: ModalHeight {
        return .compressed
    }

    private lazy var contextView = UIView()
    private lazy var titleView = UILabel()
    private lazy var accountItemCanvasView = TripleShadowView()
    private lazy var accountItemView = AccountListItemWithActionView()
    private lazy var accountTypeInformationView = AccountTypeInformationView()
    private lazy var optionsView = AccountInformationOptionsView()

    private let account: Account
    private let copyToClipboardController: CopyToClipboardController

    private lazy var theme = StandardAccountInformationScreenTheme()

    init(
        account: Account,
        copyToClipboardController: CopyToClipboardController
    ) {
        self.account = account
        self.copyToClipboardController = copyToClipboardController
    }

    override func configureNavigationBar() {
        super.configureNavigationBar()

        navigationBarController.isNavigationBarHidden = true
    }

    override func prepareLayout() {
        super.prepareLayout()

        addContext()
    }
}

extension StandardAccountInformationScreen {
    private func addContext() {
        contentView.addSubview(contextView)

        contextView.snp.makeConstraints {
            $0.top == theme.contextEdgeInsets.top
            $0.leading == theme.contextEdgeInsets.leading
            $0.trailing == theme.contextEdgeInsets.trailing
            $0.bottom == theme.contextEdgeInsets.bottom
        }

        addTitle()
        addAccountItem()
        addAccountTypeInformation()
        addOptions()
    }

    private func addTitle() {
        contextView.addSubview(titleView)
        titleView.customizeAppearance(theme.title)

        titleView.fitToIntrinsicSize()
        titleView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.trailing == 0
        }

        bindTitle()
    }

    private func addAccountItem() {
        accountItemCanvasView.drawAppearance(shadow: theme.accountItemFirstShadow)
        accountItemCanvasView.drawAppearance(secondShadow: theme.accountItemSecondShadow)
        accountItemCanvasView.drawAppearance(thirdShadow: theme.accountItemThirdShadow)

        contextView.addSubview(accountItemCanvasView)
        accountItemCanvasView.snp.makeConstraints {
            $0.top == titleView.snp.bottom + theme.spacingBetweenTitleAndAccountItem
            $0.leading == 0
            $0.trailing == 0
        }

        accountItemView.customize(theme.accountItem)
        accountItemCanvasView.addSubview(accountItemView)
        accountItemView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
            $0.greaterThanHeight(theme.accountItemMinHeight)
        }

        accountItemView.startObserving(event: .performAction) { [weak self] in
            guard let self else { return }
            self.copyToClipboardController.copyAddress(self.account)
        }

        bindAccountItem()
    }

    private func addAccountTypeInformation() {
        accountTypeInformationView.customize(theme.accountTypeInformation)

        contextView.addSubview(accountTypeInformationView)
        accountTypeInformationView.snp.makeConstraints {
            $0.top == accountItemView.snp.bottom + theme.spacingBetweenAccountItemAndAccountTypeInformation
            $0.leading == 0
            $0.trailing == 0
        }

        accountTypeInformationView.startObserving(event: .performHyperlinkAction) { [weak self] in
            guard let self else { return }
            self.open(account.supportLink)
        }

        bindAccountTypeInformation()
    }

    private func addOptions() {
        optionsView.customize(theme.options)

        contextView.addSubview(optionsView)
        optionsView.snp.makeConstraints {
            $0.top == accountTypeInformationView.snp.bottom + theme.spacingBetweenAccountTypeInformationAndOptions
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }

        let options = [
            makeRekeyToLedgerAccountItem(),
            makeRekeyToStandardAccountItem(),
            makeRescanRekeyedAccountsItem()
        ]
        options.forEach(optionsView.addOption)
    }
}

extension StandardAccountInformationScreen {
    private func makeRekeyToLedgerAccountItem() -> AccountInformationOptionItem {
        return AccountInformationOptionItem(viewModel: .rekeyToLedger) { [weak self] in
            guard let self else { return }
            self.eventHandler?(.performRekeyToLedger)
        }
    }

    private func makeRekeyToStandardAccountItem() -> AccountInformationOptionItem {
        return AccountInformationOptionItem(viewModel: .rekeyToStandard) { [weak self] in
            guard let self else { return }
            self.eventHandler?(.performRekeyToStandard)
        }
    }
    
    private func makeRescanRekeyedAccountsItem() -> AccountInformationOptionItem {
        AccountInformationOptionItem(viewModel: .rescanRekeyedAccounts) { [weak self] in
            self?.eventHandler?(.performRescanRekeyedAccounts)
        }
    }
}

extension StandardAccountInformationScreen {
    private func bindTitle() {
        if account.isHDAccount {
            titleView.attributedText = String(
                localized: "wallet-address"
            ).titleSmallMedium(lineBreakMode: .byTruncatingTail)
            return
        }
        
        titleView.attributedText = String(
            localized: "title-standard-account-capitalized-sentence"
        ).titleSmallMedium(lineBreakMode: .byTruncatingTail)
    }

    private func bindAccountItem() {
        let viewModel = AccountInformationCopyAccountItemViewModel(account)
        accountItemView.bindData(viewModel)
    }

    private func bindAccountTypeInformation() {
        let viewModel = StandardAccountTypeInformationViewModel(isHDWallet: account.isHDAccount)
        accountTypeInformationView.bindData(viewModel)
    }
}

extension StandardAccountInformationScreen {
    enum Event {
        case performRekeyToLedger
        case performRekeyToStandard
        case performRescanRekeyedAccounts
    }
}
