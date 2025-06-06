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

//   CollectiblePropertyViewModel.swift

import Foundation
import MacaroonUIKit

struct CollectiblePropertyViewModel:
    ViewModel,
    Hashable {
    private let id = UUID()
    private(set) var name: EditText?
    private(set) var value: EditText?

    init(
        _ property: CollectibleTrait
    ) {
        bindName(property)
        bindValue(property)
    }
}

extension CollectiblePropertyViewModel {
    private mutating func bindName(
        _ property: CollectibleTrait
    ) {
        guard let aName = property.displayName?.uppercased() else {
            return
        }

        name = .attributedString(
            aName
                .captionMedium(
                    lineBreakMode: .byTruncatingTail
                )
        )
    }

    private mutating func bindValue(
        _ property: CollectibleTrait
    ) {
        guard let aValue = property.displayValue else {
            return
        }

        value = .attributedString(
            aValue
                .footnoteRegular(
                    lineBreakMode: .byTruncatingTail
                )
        )
    }
}
