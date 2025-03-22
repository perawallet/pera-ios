// Copyright 2024 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   MnemonicTypeSelectionViewModel.swift

import Foundation
import Foundation
import MacaroonUIKit

struct MnemonicTypeSelectionViewModel: ViewModel {
    private(set) var bip39ViewModel: MnemonicTypeViewModel
    private(set) var algo25ViewModel: MnemonicTypeViewModel

    init(
        bip39ViewModel: MnemonicTypeViewModel,
        algo25ViewModel: MnemonicTypeViewModel
    ) {
        self.bip39ViewModel = bip39ViewModel
        self.algo25ViewModel = algo25ViewModel
    }
}
