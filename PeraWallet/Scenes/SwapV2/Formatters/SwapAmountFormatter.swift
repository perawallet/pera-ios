// Copyright 2022-2026 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   SwapAmountFormatter.swift

import Foundation

final class SwapAmountFormatter {
    
    func string(
        from value: Decimal,
        maxFractionDigits: Int = 8
    ) -> String? {
        Formatter.decimalFormatter(
            minimumFractionDigits: 0,
            maximumFractionDigits: maxFractionDigits
        )
        .string(for: value)
    }
    
    func percentage(
        from value: Decimal,
        fractionDigits: Int = 10
    ) -> String {
        Formatter.percentageWith(fraction: fractionDigits)
            .string(from: NSDecimalNumber(decimal: value))
        ?? Formatter.percentageFormatter.string(from: 0)!
    }
    
    func numericValue(from text: String) -> Double {
        text.numericValue()
    }
}
