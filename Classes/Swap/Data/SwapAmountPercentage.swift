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

//   AdjustSwapAmountDraft.swift

import Foundation

protocol SwapAmountPercentage {
    var value: Decimal { get }
    var title: String { get }
    var isPreset: Bool { get }
}

extension SwapAmountPercentage where Self == PresetSwapAmountPercentage {
    static func max() -> SwapAmountPercentage {
        return PresetSwapAmountPercentage(
            value: 100,
            customTitle: "swap-amount-percentage-max".localized
        )
    }
}

struct CustomSwapAmountPercentage: SwapAmountPercentage {
    let value: Decimal
    let title: String
    let isPreset: Bool

    init(
        value: Decimal,
        title: String? = nil
    ) {
        let percentValue = value / 100

        self.value = percentValue

        if let title = title.unwrapNonEmptyString() {
            self.title = title
        } else {
            self.title = value.number.stringValue
        }

        self.isPreset = false
    }
}

struct PresetSwapAmountPercentage: SwapAmountPercentage {
    let value: Decimal
    let title: String
    let isPreset: Bool

    init(
        value: Decimal,
        customTitle: String? = nil
    ) {
        let percentValue = value / 100

        self.value = percentValue

        if let customTitle = customTitle.unwrapNonEmptyString() {
            self.title = customTitle
        } else {
            let localizedTitle = percentValue.number.doubleValue.toPercentageWith(fractions: 2)
            self.title = localizedTitle ?? percentValue.number.stringValue
        }

        self.isPreset = true
    }
}
