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

//
//  PassphraseVerifyViewModel.swift

import UIKit
import MacaroonUIKit

final class PassphraseVerifyViewModel: ViewModel {
    private(set) var firstCardMnemonics: [String]?
    private(set) var firstCardIndex: Int?
    private(set) var secondCardMnemonics: [String]?
    private(set) var secondCardIndex: Int?
    private(set) var thirdCardMnemonics: [String]?
    private(set) var thirdCardIndex: Int?
    private(set) var fourthCardMnemonics: [String]?
    private(set) var fourthCardIndex: Int?

    init(
        shownMnemonics: [Int: [String]],
        correctIndexes: [Int]
    ) {
        setCards(
            from: shownMnemonics,
            indexes: correctIndexes
        )
    }

    private func setCards(
        from shownMnemonics: [Int: [String]],
        indexes: [Int]
    ) {
        shownMnemonics.forEach {index, mnemonics in
            switch index {
            case 0:
                firstCardMnemonics = mnemonics
                firstCardIndex = indexes[index]
            case 1:
                secondCardMnemonics = mnemonics
                secondCardIndex = indexes[index]
            case 2:
                thirdCardMnemonics = mnemonics
                thirdCardIndex = indexes[index]
            case 3:
                fourthCardMnemonics = mnemonics
                fourthCardIndex = indexes[index]
            default:
                break
            }
        }
    }
}
