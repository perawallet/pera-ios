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
//   NewSendTransactionPreviewView.swift


import Foundation
import UIKit
import MacaroonUIKit

final class NewSendTransactionPreviewView: View {
    private lazy var verticalStackView = UIStackView()
    private(set) lazy var amountView = TransactionAmountInformationView()
    private(set) lazy var userView = TransactionTextInformationView()
    private(set) lazy var opponentView = TransactionContactInformationView()
    private(set) lazy var feeView = TransactionAmountInformationView()
    private(set) lazy var balanceView = TransactionAmountInformationView()
    private(set) lazy var noteView = TransactionTextInformationView()

    private let transactionDraft: SendTransactionDraft

    init(draft: SendTransactionDraft) {
        self.transactionDraft = draft
        super.init(frame: .zero)

        customize(TransactionDetailViewTheme())
    }

    func customize(_ theme: TransactionDetailViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        addVerticalStackView(theme)
        addAmountView(theme)
        addUserView(theme)
        addOpponentView(theme)
        addFeeView(theme)
        addBalanceView(theme)

        if transactionDraft.note != nil {
            addNoteView(theme)
        }
    }

    func prepareLayout(_ layoutSheet: LayoutSheet) {}

    func customizeAppearance(_ styleSheet: ViewStyle) {}
}

extension NewSendTransactionPreviewView {
    private func addVerticalStackView(_ theme: TransactionDetailViewTheme) {
        verticalStackView.axis = .vertical
        verticalStackView.spacing = theme.verticalStackViewSpacing
        addSubview(verticalStackView)

        verticalStackView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(theme.verticalStackViewTopPadding)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
            $0.bottom.lessThanOrEqualToSuperview()
        }
    }

    private func addAmountView(_ theme: TransactionDetailViewTheme) {
        amountView.customize(TransactionAmountInformationViewTheme(transactionAmountViewTheme: TransactionAmountViewBiggerTheme()))
        amountView.setTitle("transaction-detail-amount".localized)

        verticalStackView.addArrangedSubview(amountView)

    }

    private func addUserView(_ theme: TransactionDetailViewTheme) {
        userView.customize(theme.transactionTextInformationViewCommonTheme)

        verticalStackView.addArrangedSubview(userView)
        verticalStackView.setCustomSpacing(theme.bottomPaddingForSeparator, after: amountView)
        amountView.addSeparator(theme.separator, padding: theme.separatorTopPadding)
    }

    private func addOpponentView(_ theme: TransactionDetailViewTheme) {
        opponentView.customize(theme.transactionContactInformationViewTheme)
        opponentView.isUserInteractionEnabled = true

        verticalStackView.addArrangedSubview(opponentView)
    }

    private func addFeeView(_ theme: TransactionDetailViewTheme) {
        feeView.customize(theme.commonTransactionAmountInformationViewTheme)
        feeView.setTitle("transaction-detail-fee".localized)

        verticalStackView.addArrangedSubview(feeView)
    }

    private func addBalanceView(_ theme: TransactionDetailViewTheme) {
        balanceView.customize(theme.commonTransactionAmountInformationViewTheme)
        balanceView.setTitle("title-account-balance".localized)

        verticalStackView.addArrangedSubview(balanceView)

        if transactionDraft.note != nil {
            balanceView.addSeparator(theme.separator, padding: 16)
        }
    }

    private func addNoteView(_ theme: TransactionDetailViewTheme) {
        noteView.setTitle("transaction-detail-note".localized)
        noteView.isUserInteractionEnabled = true

        verticalStackView.addArrangedSubview(noteView)
        verticalStackView.setCustomSpacing(theme.bottomPaddingForSeparator, after: noteView)
    }
}
