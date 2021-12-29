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
    var mode: Mode = .normal(amount: 0.00) {
        didSet {
            updateAmountView()
        }
    }
    
    private lazy var amountStackView = UIStackView()
    private(set) lazy var signLabel = UILabel()
    private(set) lazy var amountLabel = UILabel()

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

        amountLabel.setContentHuggingPriority(.required, for: .horizontal)
        amountLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        amountStackView.pinToSuperview()

        signLabel.customizeAppearance(theme.signLabel)
        amountStackView.addArrangedSubview(signLabel)
        amountLabel.customizeAppearance(theme.amountLabel)
        amountStackView.addArrangedSubview(amountLabel)
    }
}

extension TransactionAmountView {
    private func updateAmountView() {
        switch mode {
        case let .normal(amount, isAlgos, assetFraction, assetSymbol):
            signLabel.isHidden = true
            
            setAmount(amount, with: assetFraction, isAlgos: isAlgos, assetSymbol: assetSymbol)
            amountLabel.textColor = AppColors.Components.Text.main.uiColor
        case let .positive(amount, isAlgos, assetFraction):
            signLabel.isHidden = false
            signLabel.text = "+"
            signLabel.textColor = AppColors.Shared.Helpers.positive.uiColor
            
            setAmount(amount, with: assetFraction, isAlgos: isAlgos, assetSymbol: nil)
            amountLabel.textColor = AppColors.Shared.Helpers.positive.uiColor
        case let .negative(amount, isAlgos, assetFraction):
            signLabel.isHidden = false
            signLabel.text = "-"
            signLabel.textColor = AppColors.Shared.Helpers.negative.uiColor
            
            setAmount(amount, with: assetFraction, isAlgos: isAlgos, assetSymbol: nil)
            amountLabel.textColor = AppColors.Shared.Helpers.negative.uiColor
        }
    }
    
    private func setAmount(_ amount: Decimal, with assetFraction: Int?, isAlgos: Bool, assetSymbol: String?) {
        if let fraction = assetFraction {
            amountLabel.text = amount.toFractionStringForLabel(fraction: fraction)
        } else {
            amountLabel.text = amount.toAlgosStringForLabel
        }

        if isAlgos {
            amountLabel.text?.append(" ALGO")
        } else {
            if let assetSymbol = assetSymbol {
                amountLabel.text?.append(" \(assetSymbol)")

            }
        }
    }
}

extension TransactionAmountView {
    enum Mode {
        case normal(amount: Decimal, isAlgos: Bool = true, fraction: Int? = nil, assetSymbol: String? = nil)
        case positive(amount: Decimal, isAlgos: Bool = true, fraction: Int? = nil)
        case negative(amount: Decimal, isAlgos: Bool = true, fraction: Int? = nil)
    }
}
