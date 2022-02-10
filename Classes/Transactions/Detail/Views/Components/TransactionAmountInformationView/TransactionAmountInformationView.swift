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
//  TransactionAmountInformationView.swift

import UIKit
import MacaroonUIKit

final class TransactionAmountInformationView: View {
    private lazy var titleLabel = UILabel()
    private lazy var transactionAmountView = TransactionAmountView()

    func customize(_ theme: TransactionAmountInformationViewTheme) {
        addTitleLabel(theme)
        addTransactionAmountView(theme)
    }

    func prepareLayout(_ layoutSheet: LayoutSheet) {}

    func customizeAppearance(_ styleSheet: ViewStyle) {}
}

extension TransactionAmountInformationView {
    private func addTitleLabel(_ theme: TransactionAmountInformationViewTheme) {
        titleLabel.customizeAppearance(theme.title)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
        }
    }
    
    private func addTransactionAmountView(_ theme: TransactionAmountInformationViewTheme) {
        transactionAmountView.customize(theme.transactionAmountViewTheme)

        addSubview(transactionAmountView)
        transactionAmountView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(theme.amountLeadingPadding)
            $0.trailing.lessThanOrEqualToSuperview()
        }
    }
}

extension TransactionAmountInformationView: ViewModelBindable {
    func bindData(_ viewModel: TransactionAmountInformationViewModel?) {
        if let title = viewModel?.title {
            titleLabel.text = title
        }

        if let transactionViewModel = viewModel?.transactionViewModel {
            transactionAmountView.bindData(transactionViewModel)
        }
    }
}
