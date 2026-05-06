// Copyright 2022-2026 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   RekeyedJointAccountInformationScreen.swift

import UIKit
import MacaroonUIKit
import MacaroonBottomSheet
import pera_wallet_core

final class RekeyedJointAccountInformationScreen: MacaroonUIKit.ScrollScreen, BottomSheetScrollPresentable {
    
    // MARK: - Properties
    
    var onUndoRekeyAction: (() -> Void)?
    var onRekeyToJointAccountAction: (() -> Void)?
    var onRescanRekeyedAccountsAction: (() -> Void)?
    
    private let sourceAccount: Account
    private let authAccount: Account
    private let copyToClipboardController: CopyToClipboardController
    
    // MARK: - Properties - BottomSheetScrollPresentable
    
    var modalHeight: MacaroonUIKit.ModalHeight = .compressed
    
    // MARK: - Subviews
    
    private let contextView = UIView()

    private let titleView: UILabel = {
        let view = UILabel()
        view.textColor = Colors.Text.main.uiColor
        view.attributedText = String(localized: "title-rekeyed-account").titleSmallMedium(lineBreakMode: .byTruncatingTail)
        return view
    }()
    
    private let accountItemCanvasView: TripleShadowView = {
        let view = TripleShadowView()
        view.drawAppearance(shadow: Shadow(color: .Shadows.Cards.shadow3.uiColor, fillColor: .Defaults.bg, opacity: 1.0, offset: (0.0, 0.0), radius: 0.0, spread: 1.0, cornerRadii: (20.0, 20.0), corners: .allCorners))
        view.drawAppearance(shadow: Shadow(color: .Shadows.Cards.shadow2.uiColor, fillColor: .Defaults.bg, opacity: 1.0, offset: (0.0, 2.0), radius: 4.0, spread: 0.0, cornerRadii: (20.0, 20.0), corners: .allCorners))
        view.drawAppearance(shadow: Shadow(color: .Shadows.Cards.shadow1.uiColor, fillColor: .Defaults.bg, opacity: 1.0, offset: (0.0, 2.0), radius: 4.0, spread: -1.0, cornerRadii: (20.0, 20.0), corners: .allCorners))
        return view
    }()
    
    private let accountItemView: RekeyedAccountInformationAccountItemView = {
        let view = RekeyedAccountInformationAccountItemView()
        view.customize(RekeyedAccountInformationAccountItemViewTheme())
        return view
    }()
    
    private let accountTypeInformationView: AccountTypeInformationView = {
        let view = AccountTypeInformationView()
        view.customize(AccountTypeInformationViewTheme(.current))
        return view
    }()
    
    private let optionsView: AccountInformationOptionsView = {
        let view = AccountInformationOptionsView()
        view.customize(AccountInformationOptionsViewTheme())
        return view
    }()
    
    // MARK: - Initialisers
    
    init(sourceAccount: Account, authAccount: Account, copyToClipboardController: CopyToClipboardController) {
        self.sourceAccount = sourceAccount
        self.authAccount = authAccount
        self.copyToClipboardController = copyToClipboardController
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        setupAccountItemView(sourceAccount: sourceAccount, authAccount: authAccount)
        setupAccountTypeInformation(sourceAccount: sourceAccount)
        setupOptionsView()
        setupCallbacks()
    }
    
    // MARK: - Setups
    
    override func configureNavigationBar() {
        super.configureNavigationBar()
        navigationBarController.isNavigationBarHidden = true
    }
    
    private func setupConstraints() {
        
        contextView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(contextView)
        
        accountItemView.translatesAutoresizingMaskIntoConstraints = false
        accountItemCanvasView.addSubview(accountItemView)
        
        [titleView, accountItemCanvasView, accountTypeInformationView, optionsView]
            .forEach {
                $0.translatesAutoresizingMaskIntoConstraints = false
                contextView.addSubview($0)
        }
        
        let constraints = [
            contextView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20.0),
            contextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24.0),
            contextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24.0),
            contextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16.0),
            titleView.topAnchor.constraint(equalTo: contextView.topAnchor),
            titleView.leadingAnchor.constraint(equalTo: contextView.leadingAnchor),
            titleView.trailingAnchor.constraint(equalTo: contextView.trailingAnchor),
            accountItemCanvasView.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: 28.0),
            accountItemCanvasView.leadingAnchor.constraint(equalTo: contextView.leadingAnchor),
            accountItemCanvasView.trailingAnchor.constraint(equalTo: contextView.trailingAnchor),
            accountItemView.topAnchor.constraint(equalTo: accountItemCanvasView.topAnchor),
            accountItemView.leadingAnchor.constraint(equalTo: accountItemCanvasView.leadingAnchor),
            accountItemView.trailingAnchor.constraint(equalTo: accountItemCanvasView.trailingAnchor),
            accountItemView.bottomAnchor.constraint(equalTo: accountItemCanvasView.bottomAnchor),
            accountTypeInformationView.topAnchor.constraint(equalTo: accountItemCanvasView.bottomAnchor, constant: 28.0),
            accountTypeInformationView.leadingAnchor.constraint(equalTo: contextView.leadingAnchor),
            accountTypeInformationView.trailingAnchor.constraint(equalTo: contextView.trailingAnchor),
            optionsView.topAnchor.constraint(equalTo: accountTypeInformationView.bottomAnchor, constant: 16.0),
            optionsView.leadingAnchor.constraint(equalTo: contextView.leadingAnchor),
            optionsView.trailingAnchor.constraint(equalTo: contextView.trailingAnchor),
            optionsView.bottomAnchor.constraint(equalTo: contextView.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func setupAccountItemView(sourceAccount: Account, authAccount: Account) {
        let viewModel = RekeyedAccountInformationAccountItemViewModel(sourceAccount: sourceAccount, authAccount: authAccount)
        accountItemView.bindData(viewModel)
    }
    
    private func setupAccountTypeInformation(sourceAccount: Account) {
        let viewModel = RekeyedAccountTypeInformationViewModel(sourceAccount: sourceAccount)
        accountTypeInformationView.bindData(viewModel)
    }
    
    private func setupOptionsView() {
        optionsView.addOption(makeRekeyToJointAccountItem())
        optionsView.addOption(makeRescanRekeyedAccountsItem())
    }
    
    private func setupCallbacks() {
        
        accountItemView.startObserving(event: .performSourceAccountAction) { [weak self] in
            guard let self else { return }
            copyToClipboardController.copyAddress(sourceAccount)
        }

        accountItemView.startObserving(event: .performAuthAccountAction) { [weak self] in
            self?.onUndoRekeyAction?()
        }
        
        accountTypeInformationView.startObserving(event: .performHyperlinkAction) { [weak self] in
            self?.open(AlgorandWeb.rekey.link)
        }
    }
    
    // MARK: - Helpers
    
    private func makeRescanRekeyedAccountsItem() -> AccountInformationOptionItem {
        AccountInformationOptionItem(viewModel: .rescanRekeyedAccounts) { [weak self] in
            self?.onRescanRekeyedAccountsAction?()
        }
    }
    
    private func makeRekeyToJointAccountItem() -> AccountInformationOptionItem {
        AccountInformationOptionItem(viewModel: .rekeyToJointAccount) { [weak self] in
            self?.onRekeyToJointAccountAction?()
        }
    }
}
