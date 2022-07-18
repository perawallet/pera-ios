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

//   CurrencyFormattingStandaloneContextHandler.swift

import Foundation

struct CurrencyFormattingStandaloneContextHandler: CurrencyFormattingContextHandling {
    private let constraints: CurrencyFormattingContextRules?

    init(
        constraints: CurrencyFormattingContextRules?
    ) {
        self.constraints = constraints
    }

    func makeRules(
        _ rawNumber: NSDecimalNumber,
        for currency: LocalCurrency?
    ) -> CurrencyFormattingContextRules {
        var rules = CurrencyFormattingContextRules()
        rules.roundingMode = .down

        if let currency = currency {
            if currency.isAlgo {
                rules.minimumFractionDigits = 2
                rules.maximumFractionDigits = 6
            } else {
                rules.minimumFractionDigits = 2
                rules.maximumFractionDigits = 4
            }
        } else {
            rules.minimumFractionDigits = 2
            rules.maximumFractionDigits = Int(Int8.max)
        }

        applyConstraintsIfNeeded(&rules)

        return rules
    }

    func makeInput(
        _ rawNumber: NSDecimalNumber,
        for currency: LocalCurrency?
    ) -> CurrencyFormattingContextInput {
        return rawNumber
    }
}

extension CurrencyFormattingStandaloneContextHandler {
    private func applyConstraintsIfNeeded(
        _ rules: inout CurrencyFormattingContextRules
    ) {
        guard let constraints = constraints else {
            return
        }

        if let roundingMode = constraints.roundingMode {
            rules.roundingMode = roundingMode
        }

        if let minimumFractionDigits = constraints.minimumFractionDigits {
            rules.minimumFractionDigits = minimumFractionDigits
        }

        if let maximumFractionDigits = constraints.maximumFractionDigits {
            rules.maximumFractionDigits = maximumFractionDigits
        }
    }
}
