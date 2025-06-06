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

//
//  WelcomeView.swift

import UIKit
import MacaroonUIKit
import Foundation

final class WelcomeView:
    View,
    ViewModelBindable {
    weak var delegate: WelcomeViewDelegate?

    private lazy var titleLabel = UILabel()
    private lazy var stackView = UIStackView()
    private lazy var termsAndConditionsTextView = UITextView()
    private lazy var createWalletView = WelcomeTypeView()
    private lazy var importWalletView = WelcomeTypeView()
    
    private var session: Session?

    func customize(_ theme: WelcomeViewTheme, configuration: ViewControllerConfiguration) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        session = configuration.session

        addTitle(theme)
        addTermsAndConditionsTextView(theme)
        addStackView(theme)
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func setListeners() {
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
    }

    func linkInteractors() {
        termsAndConditionsTextView.delegate = self
    }

    func bindData(_ viewModel: WelcomeViewModel?) {
        titleLabel.text = viewModel?.title
        createWalletView.bindData(viewModel?.createWalletViewModel)
        importWalletView.bindData(viewModel?.importWalletViewModel)
    }
}

extension WelcomeView {
    @objc
    private func notifyDelegateToCreateWallet() {
        delegate?.welcomeViewDidSelectCreateWallet(self)
    }

    @objc
    private func notifyDelegateToImportAccount() {
        delegate?.welcomeViewDidSelectImport(self)
    }
    
}

extension WelcomeView {
    private func addTitle(_ theme: WelcomeViewTheme) {
        titleLabel.customizeAppearance(theme.title)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalInset)
            $0.top.equalToSuperview().inset(theme.topInset)
        }
    }

    private func addTermsAndConditionsTextView(_ theme: WelcomeViewTheme) {
        termsAndConditionsTextView.isEditable = false
        termsAndConditionsTextView.isScrollEnabled = false
        termsAndConditionsTextView.dataDetectorTypes = .link
        termsAndConditionsTextView.textContainerInset = .zero
        termsAndConditionsTextView.backgroundColor = .clear
        termsAndConditionsTextView.linkTextAttributes = theme.termsOfConditionsLinkAttributes.asSystemAttributes()
        termsAndConditionsTextView.bindHTML(
            String(format: String(localized: "introduction-title-terms-and-services"), AlgorandWeb.termsAndServices.rawValue, AlgorandWeb.privacyPolicy.rawValue),
            attributes: theme.termsOfConditionsAttributes.asSystemAttributes()
        )

        addSubview(termsAndConditionsTextView)
        termsAndConditionsTextView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalInset)
            $0.bottom.equalToSuperview().inset(safeAreaBottom + theme.verticalInset)
            $0.centerX.equalToSuperview()
        }
    }

    private func addStackView(_ theme: WelcomeViewTheme) {
        stackView.axis = .vertical
        stackView.spacing = 40

        addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.leading.trailing.centerY.equalToSuperview()
            $0.top.greaterThanOrEqualTo(titleLabel.snp.bottom).offset(theme.verticalInset)
            $0.bottom.lessThanOrEqualTo(termsAndConditionsTextView.snp.top).offset(-theme.verticalInset)
        }
        createWalletView.customize(theme.welcomeTypeViewTheme)
        stackView.addArrangedSubview(createWalletView)
        importWalletView.customize(theme.welcomeTypeViewTheme)
        stackView.addArrangedSubview(importWalletView)
    }
}

extension WelcomeView: UITextViewDelegate {
    func textView(
        _ textView: UITextView,
        shouldInteractWith URL: URL,
        in characterRange: NSRange,
        interaction: UITextItemInteraction
    ) -> Bool {
        delegate?.welcomeView(self, didOpen: URL)
        return false
    }
}

protocol WelcomeViewDelegate: AnyObject {
    func welcomeViewDidSelectCreateWallet(_ welcomeView: WelcomeView)
    func welcomeViewDidSelectImport(_ welcomeView: WelcomeView)
    func welcomeView(_ welcomeView: WelcomeView, didOpen url: URL)
}
