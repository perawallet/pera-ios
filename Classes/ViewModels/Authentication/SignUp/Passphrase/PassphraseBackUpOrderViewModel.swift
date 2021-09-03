// Copyright 2019 Algorand, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//  PassphraseBackUpOrderViewModel.swift

import Foundation

final class PassphraseBackUpOrderViewModel {
    private(set) var number: String?
    private(set) var phrase: String?

    init(mnemonics: [String]?, index: Int) {
        bindNumber(index)
        bindPhrase(mnemonics, at: index)
    }
}

extension PassphraseBackUpOrderViewModel {
    private func bindNumber(_ index: Int) {
        number = "\(index + 1)"
    }

    private func bindPhrase(_ mnemonics: [String]?, at index: Int) {
        phrase = mnemonics?[index]
    }
}
