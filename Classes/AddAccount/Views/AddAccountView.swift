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

//   AddAccountView.swift

import UIKit
import MacaroonUIKit
import Foundation

final class AddAccountView:
    View,
    ViewModelBindable {
    weak var delegate: AddAccountViewDelegate?

    private lazy var titleLabel = UILabel()
    private lazy var stackView = UIStackView()
    private lazy var termsAndConditionsTextView = UITextView()
    private lazy var createAddressView = AccountTypeView()
    private lazy var createWalletView = AccountTypeView()
    private lazy var importWalletView = AccountTypeView()
    private lazy var watchAddressView = AccountTypeView()
    
    private var session: Session?
    private var featureFlagService: FeatureFlagServicing?

    func customize(_ theme: AddAccountViewTheme, configuration: ViewControllerConfiguration) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        session = configuration.session
        featureFlagService = configuration.featureFlagService

        addTitle(theme)
        addTermsAndConditionsTextView(theme)
        addStackView(theme)
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func setListeners() {
        createAddressView.addTarget(
            self,
            action: #selector(notifyDelegateToCreateAddress),
            for: .touchUpInside
        )
        
        createWalletView.addTarget(
            self,
            action: #selector(notifyDelegateToCreateWallet),
            for: .touchUpInside
        )

        importWalletView.addTarget(
            self,
            action: #selector(notifyDelegateToImportAccount),
            for: .touchUpInside
        )
        
        watchAddressView.addTarget(
            self,
            action: #selector(notifyDelegateToWatchAccount),
            for: .touchUpInside
        )
    }

    func linkInteractors() {
        termsAndConditionsTextView.delegate = self
    }

    func bindData(_ viewModel: AddAccountViewModel?) {
        titleLabel.text = viewModel?.title
        createAddressView.bindData(viewModel?.createAddressViewModel)
        createWalletView.bindData(viewModel?.createWalletViewModel)
        importWalletView.bindData(viewModel?.importWalletViewModel)
        watchAddressView.bindData(viewModel?.watchWalletViewModel)
    }
}

extension AddAccountView {
    @objc
    private func notifyDelegateToCreateAddress() {
        delegate?.addAccountViewDidSelectCreateAddress(self)
    }
    @objc
    private func notifyDelegateToCreateWallet() {
        delegate?.addAccountViewDidSelectCreateWallet(self)
    }

    @objc
    private func notifyDelegateToImportAccount() {
        delegate?.addAccountViewDidSelectImport(self)
    }
    
    @objc
    private func notifyDelegateToWatchAccount() {
        delegate?.addAccountViewDidSelectWatch(self)
    }
}

extension AddAccountView {
    private func addTitle(_ theme: AddAccountViewTheme) {
        titleLabel.customizeAppearance(theme.title)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalInset)
            $0.top.equalToSuperview().inset(theme.topInset)
        }
    }

    private func addTermsAndConditionsTextView(_ theme: AddAccountViewTheme) {
        termsAndConditionsTextView.isEditable = false
        termsAndConditionsTextView.isScrollEnabled = false
        termsAndConditionsTextView.dataDetectorTypes = .link
        termsAndConditionsTextView.textContainerInset = .zero
        termsAndConditionsTextView.backgroundColor = .clear
        termsAndConditionsTextView.linkTextAttributes = theme.termsOfConditionsLinkAttributes.asSystemAttributes()
        if featureFlagService?.isEnabled(.hdWalletEnabled) ?? false {
            termsAndConditionsTextView.bindHTML(
                "introduction-title-terms-and-services-wallet".localized(params: AlgorandWeb.termsAndServices.rawValue, AlgorandWeb.privacyPolicy.rawValue),
                attributes: theme.termsOfConditionsAttributes.asSystemAttributes()
            )
        } else {
            termsAndConditionsTextView.bindHTML(
                "introduction-title-terms-and-services".localized(params: AlgorandWeb.termsAndServices.rawValue, AlgorandWeb.privacyPolicy.rawValue),
                attributes: theme.termsOfConditionsAttributes.asSystemAttributes()
            )
        }


        addSubview(termsAndConditionsTextView)
        termsAndConditionsTextView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalInset)
            $0.bottom.equalToSuperview().inset(safeAreaBottom + theme.verticalInset)
            $0.centerX.equalToSuperview()
        }
    }

    private func addStackView(_ theme: AddAccountViewTheme) {
        stackView.axis = .vertical

        addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.leading.trailing.centerY.equalToSuperview()
            $0.top.greaterThanOrEqualTo(titleLabel.snp.bottom).offset(theme.verticalInset)
            $0.bottom.lessThanOrEqualTo(termsAndConditionsTextView.snp.top).offset(-theme.verticalInset)
        }
        if
            featureFlagService?.isEnabled(.hdWalletEnabled) ?? false,
            session?.authenticatedUser?.hasHDWalletsAccounts ?? false
        {
            createAddressView.customize(theme.accountTypeViewTheme)
            stackView.addArrangedSubview(createAddressView)
        }
        createWalletView.customize(theme.accountTypeViewTheme)
        stackView.addArrangedSubview(createWalletView)
        importWalletView.customize(theme.accountTypeViewTheme)
        stackView.addArrangedSubview(importWalletView)
        watchAddressView.customize(theme.accountTypeViewTheme)
        stackView.addArrangedSubview(watchAddressView)
    }
}

extension AddAccountView: UITextViewDelegate {
    func textView(
        _ textView: UITextView,
        shouldInteractWith URL: URL,
        in characterRange: NSRange,
        interaction: UITextItemInteraction
    ) -> Bool {
        delegate?.addAccountView(self, didOpen: URL)
        return false
    }
}

protocol AddAccountViewDelegate: AnyObject {
    func addAccountViewDidSelectCreateAddress(_ addAccountView: AddAccountView)
    func addAccountViewDidSelectCreateWallet(_ addAccountView: AddAccountView)
    func addAccountViewDidSelectImport(_ addAccountView: AddAccountView)
    func addAccountViewDidSelectWatch(_ addAccountView: AddAccountView)
    func addAccountView(_ addAccountView: AddAccountView, didOpen url: URL)
}
