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
//   TransactionAmountViewModel.swift

import MacaroonUIKit
import UIKit

final class TransactionAmountViewModel: PairedViewModel {
    private(set) var signLabelIsHidden = false
    private(set) var signLabelText: String?
    private(set) var signLabelColor: Color?
    private(set) var amountLabelText: String?
    private(set) var amountLabelColor: Color?

    init(_ mode: TransactionAmountView.Mode) {
        bindMode(mode)
    }
}

extension TransactionAmountViewModel {
    private func bindMode(_ mode: TransactionAmountView.Mode) {
        switch mode {
        case let .normal(amount, isAlgos, assetFraction, assetSymbol):
            signLabelIsHidden = true
            bindAmount(amount, with: assetFraction, isAlgos: isAlgos, assetSymbol: assetSymbol)
            amountLabelColor = AppColors.Components.Text.main
        case let .positive(amount, isAlgos, assetFraction, assetSymbol):
            signLabelIsHidden = false
            signLabelText = "+"
            signLabelColor = AppColors.Shared.Helpers.positive
            bindAmount(amount, with: assetFraction, isAlgos: isAlgos, assetSymbol: assetSymbol)
            amountLabelColor = AppColors.Shared.Helpers.positive
        case let .negative(amount, isAlgos, assetFraction, assetSymbol):
            signLabelIsHidden = false
            signLabelText = "-"
            signLabelColor = AppColors.Shared.Helpers.negative
            bindAmount(amount, with: assetFraction, isAlgos: isAlgos, assetSymbol: assetSymbol)
            amountLabelColor = AppColors.Shared.Helpers.negative
        }
    }

    private func bindAmount(_ amount: Decimal, with assetFraction: Int?, isAlgos: Bool, assetSymbol: String? = nil) {
        if let fraction = assetFraction {
            amountLabelText = amount.toFractionStringForLabel(fraction: fraction)
        } else {
            amountLabelText = amount.toAlgosStringForLabel
        }

        if isAlgos {
            amountLabelText?.append(" ALGO")
        } else {
            if let assetSymbol = assetSymbol {
                amountLabelText?.append(" \(assetSymbol)")
            }
        }
    }
}
