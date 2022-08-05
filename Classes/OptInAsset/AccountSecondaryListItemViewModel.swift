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

//   AccountSecondaryListItemViewModel.swift

import Foundation
import MacaroonUIKit
import CoreGraphics

struct AccountSecondaryListItemViewModel: SecondaryListItemViewModel {
    var title: TextProvider?
    var accessory: Accessory?

    init(
        account: Account
    ) {
        bindTitle()
        bindAccessory(account)
    }
}

extension AccountSecondaryListItemViewModel {
    private mutating func bindTitle() {
        title = getTitle(
            title: "title-account klsdlkf jslkdf jksdf jsdlkfjklsdfjfklsdjf klsjffsdnfhsfjhsdjkfh jshfjshd kfjhsdkjf hskjdfh jskdhf jkshfjkhssdfkjlslsdtitle-account klsdlkf jslkdf jksdf jsdlkfjklsdfjfklsdjf klsjffsdnfhsfjhsdjkfh jshfjshd kfjhsdkjf hskjdfh jskdhf jkshfjkhssdfkjlslsdtitle-account klsdlkf jslkdf jksdf jsdlkfjklsdfjfklsdjf klsjffsdnfhsfjhsdjkfh jshfjshd kfjhsdkjf hskjdfh jskdhf jkshfjkhssdfkjlslsdtitle-account klsdlkf jslkdf jksdf jsdlkfjklsdfjfklsdjf klsjffsdnfhsfjhsdjkfh jshfjshd kfjhsdkjf hskjdfh jskdhf jkshfjkhssdfkjlslsdtitle-account klsdlkf jslkdf jksdf jsdlkfjklsdfjfklsdjf klsjffsdnfhsfjhsdjkfh jshfjshd kfjhsdkjf hskjdfh jskdhf jkshfjkhssdfkjlslsdtitle-account klsdlkf jslkdf jksdf jsdlkfjklsdfjfklsdjf klsjffsdnfhsfjhsdjkfh jshfjshd kfjhsdkjf hskjdfh jskdhf jkshfjkhssdfkjlslsd"
                .localized
        )
    }

    private mutating func bindAccessory(
        _ account: Account
    ) {
        let imageSize = CGSize((24, 24))
        let resizedImage =
        account.typeImage
            .convert(to: imageSize)
            .unwrap(or: account.typeImage)

        accessory = getNonInteractableAccessory(
            icon: resizedImage,
            title: "p234892348sdjfjlkfjsdlkfjdsk jslkf jlksdfjsdfj",
            titleLineBreakMode: .byWordWrapping
        )
    }
}
