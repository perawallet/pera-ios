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

//   SlippageSelectorInputViewModel.swift

import Foundation

struct SlippageSelectorInputViewModel: SelectorInputViewModel {
    private(set) var selectorOptions: [SelectorOption]?
    private(set) var defaultSelectedIndex: Int?

    init(options: [Decimal]) {
        bindSelectedOptions(options)
        bindDefaultSelectedIndex()
    }
}

extension SlippageSelectorInputViewModel {
    private mutating func bindSelectedOptions(_ options: [Decimal]) {
        let firstOptionTitle = "swap-slippage-percentage-auto".localized
        let secondOptionTitle = options[1].doubleValue.toPercentageWith(fractions: 3).someString
        let thirdOptionTitle = options[2].doubleValue.toPercentageWith(fractions: 3).someString
        let fourthOptionTitle = options[3].doubleValue.toPercentageWith(fractions: 3).someString

        self.selectorOptions = [
            SelectorOption(title: firstOptionTitle),
            SelectorOption(title: secondOptionTitle),
            SelectorOption(title: thirdOptionTitle),
            SelectorOption(title: fourthOptionTitle)
        ]
    }

    private mutating func bindDefaultSelectedIndex() {
        self.defaultSelectedIndex = 2
    }
}
