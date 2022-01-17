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
    private(set) lazy var opponentView = TransactionTextInformationView()
    private(set) lazy var feeView = TransactionAmountInformationView()
    private(set) lazy var balanceView = TransactionAmountInformationView()
    private(set) lazy var noteView = TransactionTextInformationView()

    private lazy var theme = TransactionDetailViewTheme()

    init() {
        super.init(frame: .zero)

        customize(theme)
    }

    func customize(_ theme: TransactionDetailViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        addVerticalStackView(theme)
        addAmountView(theme)
        addUserView(theme)
        addOpponentView(theme)
        addFeeView(theme)
        addBalanceView(theme)
        addNoteView(theme)
    }

    func prepareLayout(_ layoutSheet: LayoutSheet) {}

    func customizeAppearance(_ styleSheet: ViewStyle) {}

    func setNoteViewVisible(_ isVisible: Bool) {
        if isVisible {
            balanceView.addSeparator(theme.separator, padding: theme.separatorTopPadding)
            verticalStackView.setCustomSpacing(theme.bottomPaddingForSeparator, after: balanceView)
        }
        noteView.isHidden = !isVisible
    }
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
        amountView.bindData(
            TransactionAmountInformationViewModel(
                title: "transaction-detail-amount".localized
            )
        )

        verticalStackView.addArrangedSubview(amountView)

    }

    private func addUserView(_ theme: TransactionDetailViewTheme) {
        userView.customize(theme.transactionTextInformationViewCommonTheme)
        userView.bindData(
            TransactionTextInformationViewModel(
                title: "title-account".localized
            )
        )

        verticalStackView.addArrangedSubview(userView)
        verticalStackView.setCustomSpacing(theme.bottomPaddingForSeparator, after: amountView)
        amountView.addSeparator(theme.separator, padding: theme.separatorTopPadding)
    }

    private func addOpponentView(_ theme: TransactionDetailViewTheme) {
        opponentView.customize(theme.transactionTextInformationViewCommonTheme)
        opponentView.bindData(
            TransactionTextInformationViewModel(
                title: "transaction-detail-to".localized
            )
        )

        verticalStackView.addArrangedSubview(opponentView)
    }

    private func addFeeView(_ theme: TransactionDetailViewTheme) {
        feeView.customize(theme.commonTransactionAmountInformationViewTheme)
        feeView.bindData(
            TransactionAmountInformationViewModel(
                title: "transaction-detail-fee".localized
            )
        )

        verticalStackView.addArrangedSubview(feeView)
        feeView.addSeparator(theme.separator, padding: theme.separatorTopPadding)
        verticalStackView.setCustomSpacing(theme.bottomPaddingForSeparator, after: feeView)
    }

    private func addBalanceView(_ theme: TransactionDetailViewTheme) {
        balanceView.customize(theme.commonTransactionAmountInformationViewTheme)
        balanceView.bindData(
            TransactionAmountInformationViewModel(
                title: "title-account-balance".localized
            )
        )

        verticalStackView.addArrangedSubview(balanceView)
    }

    private func addNoteView(_ theme: TransactionDetailViewTheme) {
        noteView.customize(theme.transactionTextInformationViewCommonTheme)
        noteView.bindData(
            TransactionTextInformationViewModel(
                title: "transaction-detail-note".localized
            )
        )

        verticalStackView.addArrangedSubview(noteView)
    }
}

extension NewSendTransactionPreviewView: ViewModelBindable {
    func bindData(_ viewModel: SendTransactionPreviewViewModel?) {
        if let amountViewMode = viewModel?.amountViewMode {
            amountView.bindData(
                TransactionAmountInformationViewModel(
                    transactionViewModel: TransactionAmountViewModel(amountViewMode)
                )
            )

            /// <todo> Add currency conversion for amount
        }

        userView.bindData(
            TransactionTextInformationViewModel(detail: viewModel?.userViewDetail)
        )

        opponentView.bindData(
            TransactionTextInformationViewModel(detail: viewModel?.opponentViewAddress)
        )

        if let feeViewMode = viewModel?.feeViewMode {
            feeView.bindData(
                TransactionAmountInformationViewModel(
                    transactionViewModel: TransactionAmountViewModel(feeViewMode)
                )
            )
        }

        if let balanceViewMode = viewModel?.balanceViewMode {
            balanceView.bindData(
                TransactionAmountInformationViewModel(
                    transactionViewModel: TransactionAmountViewModel(balanceViewMode)
                )
            )

            /// <todo> Add currency conversion for balance
        }

        noteView.bindData(
            TransactionTextInformationViewModel(detail: viewModel?.noteViewDetail)
        )

        setNoteViewVisible(!(viewModel?.noteViewDetail.isNilOrEmpty ?? true))
    }
}
