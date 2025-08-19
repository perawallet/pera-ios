// Copyright 2022-2025 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   CollectibleAmountFormattingContextHandling.swift

import Foundation

public protocol CollectibleAmountFormattingContextHandling {
    func makeRules(
        _ rawNumber: NSDecimalNumber
    ) -> CollectibleAmountFormattingRules

    func makeInput(
        _ rawNumber: NSDecimalNumber
    ) -> CurrencyFormattingContextInput
}

public struct CollectibleAmountFormattingRules {
    public var roundingMode: RoundingMode?
    public var minimumFractionDigits: Int?
    public var maximumFractionDigits: Int?
}

extension CollectibleAmountFormattingRules {
    public typealias RoundingMode = NumberFormatter.RoundingMode
}
