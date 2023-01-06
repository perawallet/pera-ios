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

//   RecoverAccountView.swift

import UIKit
import MacaroonUIKit
import Foundation

final class RecoverAccountView:
    View,
    ViewModelBindable {
    weak var delegate: RecoverAccountViewDelegate?

    private lazy var titleLabel = UILabel()
    private lazy var stackView = UIStackView()
    private lazy var recoverWithPassphraseView = AccountTypeView()
    private lazy var recoverWithLedgerView = AccountTypeView()
    private lazy var importFromWebView = AccountTypeView()

    func customize(_ theme: RecoverAccountViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)

        addTitleLabel(theme)
        addStackView(theme)
    }

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func setListeners() {
        recoverWithPassphraseView.addTarget(
            self,
            action: #selector(notifyDelegateToRecoverWithPassphrase),
            for: .touchUpInside
        )

        recoverWithLedgerView.addTarget(
            self,
            action: #selector(notifyDelegateToRecoverWithLedger),
            for: .touchUpInside
        )

        importFromWebView.addTarget(
            self,
            action: #selector(notifyDelegateToImportFromWeb),
            for: .touchUpInside
        )
    }

    func bindData(_ viewModel: RecoverAccountViewModel?) {
        recoverWithPassphraseView.bindData(viewModel?.recoverWithPassphraseViewModel)
        recoverWithLedgerView.bindData(viewModel?.recoverWithLedgerViewModel)
        importFromWebView.bindData(viewModel?.importFromWebViewModel)
    }
}

extension RecoverAccountView {
    @objc
    private func notifyDelegateToRecoverWithPassphrase() {
        delegate?.recoverAccountView(self, didSelect: .passphrase)
    }

    @objc
    private func notifyDelegateToRecoverWithLedger() {
        delegate?.recoverAccountView(self, didSelect: .ledger)
    }

    @objc
    private func notifyDelegateToImportFromWeb() {
        delegate?.recoverAccountView(self, didSelect: .importFromWeb)
    }
}

extension RecoverAccountView {
    private func addTitleLabel(_ theme: RecoverAccountViewTheme) {
        titleLabel.customizeAppearance(theme.title)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(theme.horizontalInset)
            $0.trailing.equalToSuperview().inset(theme.horizontalInset)
            $0.top.equalToSuperview().inset(theme.topInset)
        }
    }

    private func addStackView(_ theme: RecoverAccountViewTheme) {
        stackView.axis = .vertical

        addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.greaterThanOrEqualTo(titleLabel.snp.bottom).offset(theme.verticalInset)
            $0.bottom.lessThanOrEqualToSuperview().inset(safeAreaBottom + theme.verticalInset)
            $0.centerY.equalToSuperview()
        }

        recoverWithPassphraseView.customize(theme.accountTypeViewTheme)
        stackView.addArrangedSubview(recoverWithPassphraseView)
        recoverWithLedgerView.customize(theme.accountTypeViewTheme)
        stackView.addArrangedSubview(recoverWithLedgerView)
        importFromWebView.customize(theme.accountTypeViewTheme)
        stackView.addArrangedSubview(importFromWebView)
    }
}

protocol RecoverAccountViewDelegate: AnyObject {
    func recoverAccountView(_ recoverAccountView: RecoverAccountView, didSelect type: RecoverType)
}
