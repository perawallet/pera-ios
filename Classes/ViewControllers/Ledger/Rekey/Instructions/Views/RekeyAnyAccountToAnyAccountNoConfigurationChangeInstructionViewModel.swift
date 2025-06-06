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

//   RekeyAnyAccountToAnyAccountNoConfigurationChangeInstructionViewModel.swift

import Foundation
import MacaroonUIKit

struct RekeyAnyAccountToAnyAccountNoConfigurationChangeInstructionViewModel: InstructionItemViewModel {
    private(set) var order: TextProvider?
    private(set) var title: TextProvider?
    private(set) var subtitle: SubtitleTextProvider?

    init(order: Int) {
        self.order = "\(order)".bodyRegular(alignment: .center)
        self.title = String(localized: "rekey-instruction-third").bodyRegular()
    }
}
