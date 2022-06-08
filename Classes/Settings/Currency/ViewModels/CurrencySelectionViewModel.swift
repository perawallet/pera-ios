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

//   CurrencySelectionViewModel.swift

import Foundation
import MacaroonUIKit

struct CurrencySelectionViewModel: ViewModel {
    private(set) var title: EditText?
    private(set) var description: NSAttributedString?

    init(
        currency: String
    ) {
        bindTitle()
        bindDescription(currency)
    }
}

extension CurrencySelectionViewModel {
    private mutating func bindTitle() {
        self.title = .attributedString(
            "settings-currency-title"
                .localized
                .bodyMedium(
                    hasMultilines: false
                )
        )
    }

    private mutating func bindDescription(
        _ currency: String
    ) {
        let secondaryCurrency = (currency == "ALGO")
        ? "USD"
        : "ALGO"

        let descriptionText = String(
            format: "settings-currency-description".localized,
            currency,
            secondaryCurrency
        )
        let attributedDescriptionText = NSMutableAttributedString(
            attributedString: descriptionText.footnoteRegular()
        )

        let mainCurrencyRange = (descriptionText as NSString).range(of: currency)
        attributedDescriptionText.addAttribute(
            NSAttributedString.Key.foregroundColor,
            value: AppColors.Components.Text.main,
            range: mainCurrencyRange
        )

        let secondaryCurrencyRange = (descriptionText as NSString).range(of: secondaryCurrency)
        attributedDescriptionText.addAttribute(
            NSAttributedString.Key.foregroundColor,
            value: AppColors.Components.Text.main,
            range: secondaryCurrencyRange
        )

        self.description = attributedDescriptionText
    }
}
