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

//   SetSlippageToleranceDraft.swift

import Foundation
import MacaroonUIKit
import MacaroonForm

struct SetSlippageToleranceDraft {
    let optionValues: [Decimal] = [
        0.005,
        0.001,
        0.005,
        0.01
    ]

    let slippageToleranceValidator = SlippageToleranceValidator {
        error in

        switch error {
        case .required:
            return .attributedString(
                "swap-slippage-error-required"
                    .localized
                    .footnoteMedium()
            )
        case .invalid:
            return .attributedString(
                "swap-slippage-error-value"
                    .localized
                    .footnoteMedium()
            )
        }
    }

    func validateSlippageTolerance(_ slippage: String?) -> Validation {
        return slippageToleranceValidator.validate(slippage)
    }
}
