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
//  TransactionHistoryContextView.swift

import UIKit
import MacaroonUIKit

class TransactionHistoryContextView: View {
    private(set) lazy var titleLabel = UILabel()
    private(set) lazy var subtitleLabel = UILabel()
    private(set) lazy var transactionAmountView = TransactionAmountView()

    func customize(_ theme: TransactionHistoryContextViewTheme) {
        addTitleLabel(theme)
        addSubtitleLabel(theme)
        addTransactionAmountView(theme)
    }

    func prepareLayout(_ layoutSheet: LayoutSheet) {}

    func customizeAppearance(_ styleSheet: ViewStyle) {}
}

extension TransactionHistoryContextView {
    private func addTitleLabel(_ theme: TransactionHistoryContextViewTheme) {
        titleLabel.customizeAppearance(theme.titleLabel)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(theme.horizontalInset)
            $0.top.equalToSuperview().inset(theme.verticalInset)
            $0.centerY.equalToSuperview().priority(.low)
        }
    }
    
    private func addSubtitleLabel(_ theme: TransactionHistoryContextViewTheme) {
        subtitleLabel.customizeAppearance(theme.subtitleLabel)

        addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints {
            $0.leading.equalTo(titleLabel.snp.leading)
            $0.top.equalTo(titleLabel.snp.bottom).offset(theme.subtitleTopInset)
            $0.bottom.equalToSuperview().inset(theme.verticalInset)
        }
    }

    private func addTransactionAmountView(_ theme: TransactionHistoryContextViewTheme) {
        transactionAmountView.customize(TransactionAmountViewSmallerTheme())

        addSubview(transactionAmountView)
        transactionAmountView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(theme.horizontalInset)
            $0.centerY.equalToSuperview()
            $0.leading.greaterThanOrEqualTo(titleLabel.snp.trailing).offset(theme.minimumHorizontalSpacing)
        }
    }
}

extension TransactionHistoryContextView: ViewModelBindable {
    func bindData(_ viewModel: TransactionHistoryContextViewModel?) {
        titleLabel.text = viewModel?.title

        if let subtitle = viewModel?.subtitle {
            subtitleLabel.text = subtitle
        } else {
            subtitleLabel.isHidden = true
        }

        if let transactionAmountViewModel = viewModel?.transactionAmountViewModel {
            transactionAmountView.bindData(transactionAmountViewModel)
        }
    }

    func prepareForReuse() {
        titleLabel.text = nil
        subtitleLabel.text = nil
        subtitleLabel.isHidden = false
        transactionAmountView.prepareForReuse()
    }
}
