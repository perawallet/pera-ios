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
//  TransactionAmountView.swift

import UIKit
import MacaroonUIKit

final class TransactionAmountView: View {
    private lazy var amountStackView = UIStackView()
    private lazy var signLabel = Label()
    private lazy var amountLabel = Label()

    func customize(_ theme: TransactionAmountViewTheme) {
        addAmountStackView(theme)
    }

    func customizeAppearance(_ styleSheet: StyleSheet) {}

    func prepareLayout(_ layoutSheet: LayoutSheet) {}
}

extension TransactionAmountView {
    private func addAmountStackView(_ theme: TransactionAmountViewTheme) {
        addSubview(amountStackView)
        amountStackView.distribution = .equalSpacing
        amountStackView.alignment = .center

        amountStackView.fitToIntrinsicSize()
        signLabel.fitToIntrinsicSize()
        amountLabel.fitToIntrinsicSize()
        
        amountStackView.pinToSuperview()

        signLabel.customizeAppearance(theme.signLabel)
        amountStackView.addArrangedSubview(signLabel)
        amountLabel.customizeAppearance(theme.amountLabel)
        amountStackView.addArrangedSubview(amountLabel)
    }
}

extension TransactionAmountView: ViewModelBindable {
    func bindData(_ viewModel: TransactionAmountViewModel?) {
        signLabel.editText = viewModel?.signLabelText
        signLabel.textColor = viewModel?.signLabelColor?.uiColor
        amountLabel.editText = viewModel?.amountLabelText
        amountLabel.textColor = viewModel?.amountLabelColor?.uiColor
    }

    func prepareForReuse() {
        signLabel.text = nil
        amountLabel.text = nil
    }
}

extension TransactionAmountView {
    enum Mode: Hashable {
        case normal(amount: Decimal, isAlgos: Bool = true, fraction: Int? = nil, assetSymbol: String? = nil)
        case positive(amount: Decimal, isAlgos: Bool = true, fraction: Int? = nil, assetSymbol: String? = nil)
        case negative(amount: Decimal, isAlgos: Bool = true, fraction: Int? = nil, assetSymbol: String? = nil)
    }
}
