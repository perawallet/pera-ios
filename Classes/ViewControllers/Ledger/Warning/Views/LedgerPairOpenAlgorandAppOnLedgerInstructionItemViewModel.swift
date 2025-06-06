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

//   LedgerPairOpenAlgorandAppOnLedgerInstructionItemViewModel.swift

import Foundation
import MacaroonUIKit

struct LedgerPairOpenAlgorandAppOnLedgerInstructionItemViewModel: InstructionItemViewModel {
    private(set) var order: TextProvider?
    private(set) var title: TextProvider?
    private(set) var subtitle: SubtitleTextProvider?

    init(order: Int) {
        bindOrder(order)
        bindTitle()
    }
}

extension LedgerPairOpenAlgorandAppOnLedgerInstructionItemViewModel {
    private mutating func bindOrder(_ order: Int) {
        self.order = "\(order)".bodyRegular(alignment: .center)
    }

    private mutating func bindTitle() {
        title =
            String(localized: "ledger-pairing-first-warning-message-fourth-instruction")
                .bodyRegular()
    }
}
