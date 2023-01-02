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

//   CollectibleDescriptionViewModel.swift

import Foundation
import MacaroonUIKit

struct CollectibleDescriptionViewModel {
    private(set) var description: TextProvider?
    private(set) var shouldShowToggleTruncationAction: Bool = false
    private(set) var isTruncating: Bool = true

    private(set) var fullDescriptionHeight: CGFloat = .zero
    private(set) var truncatedDescriptionHeight: CGFloat = .zero

    init(
        asset: Asset,
        fittingWidth: CGFloat,
        isTruncating: Bool
    ) {
        bindDescription(asset)
        bindShouldShowToggleTruncationAction(fittingWidth: fittingWidth)
        bindIsTruncating(isTruncating)
    }
}

extension CollectibleDescriptionViewModel {
    mutating func bindDescription(_ asset: Asset) {
        description = asset.description?.bodyRegular()
    }

    mutating func bindShouldShowToggleTruncationAction(fittingWidth: CGFloat) {
        let descriptionSingleLineSize = description?.boundingSize(
            multiline: false,
            fittingSize: CGSize((.greatestFiniteMagnitude, .greatestFiniteMagnitude))
        )
        let descriptionLineHeight = descriptionSingleLineSize?.height ?? .zero

        let numberOfLinesLimit = 4
        let truncatedDescriptionHeight = descriptionLineHeight * numberOfLinesLimit.cgFloat
        self.truncatedDescriptionHeight = truncatedDescriptionHeight

        let fullDescriptionHeight = description?.boundingSize(
            multiline: true,
            fittingSize: CGSize((fittingWidth, .greatestFiniteMagnitude))
        ).height ?? .zero
        self.fullDescriptionHeight = fullDescriptionHeight

        shouldShowToggleTruncationAction = fullDescriptionHeight > truncatedDescriptionHeight
    }

    mutating func bindIsTruncating(_ isTruncating: Bool) {
        self.isTruncating = isTruncating
    }
}
