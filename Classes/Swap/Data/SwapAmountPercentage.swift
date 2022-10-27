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
    var title: String { get }
    var value: Decimal { get }
    var isPreset: Bool { get }
}

struct CustomSwapAmountPercentage: SwapAmountPercentage {
    let title: String
    let value: Decimal
    let isPreset: Bool

    init(value: Decimal) {
        self.title = value.number.stringValue
        self.value = value
        self.isPreset = false
    }
}

struct PresetSwapAmountPercentage: SwapAmountPercentage {
    let title: String
    let value: Decimal
    let isPreset: Bool

    init(
        value: Decimal,
        customTitle: String? = nil
    ) {
        if let customTitle = customTitle {
            self.title = customTitle
        } else {
            self.title = value.doubleValue.toPercentageWith(fractions: 2) ?? value.number.stringValue
        }

        self.value = value
        self.isPreset = true
    }
}
