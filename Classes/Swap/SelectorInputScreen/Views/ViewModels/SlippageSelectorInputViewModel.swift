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

    init() {
        bindSelectedOptions()
        bindDefaultSelectedIndex()
    }
}

extension SlippageSelectorInputViewModel {
    private mutating func bindSelectedOptions() {
        self.selectorOptions = [
            SelectorOption(title: "swap-slippage-percentage-auto".localized),
            SelectorOption(title: "0.1%"),
            SelectorOption(title: "0.5%"),
            SelectorOption(title: "1%")
        ]
    }

    private mutating func bindDefaultSelectedIndex() {
        self.defaultSelectedIndex = 2
    }
}
