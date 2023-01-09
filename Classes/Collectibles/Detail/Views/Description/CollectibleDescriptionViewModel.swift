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
    private(set) var isTruncatable: Bool = false
    private(set) var isTruncated: Bool = true

    private let characterThreshold = 180

    init(
        asset: Asset,
        isTruncated: Bool
    ) {
        self.isTruncated = isTruncated

        bindIsTruncatable(asset: asset)
        bindDescription(asset)
    }
}

extension CollectibleDescriptionViewModel {
    mutating func bindIsTruncatable(asset: Asset) {
        guard let description = asset.description else {
            isTruncatable = false
            return
        }

        let descriptionCharacterCount = description.count

        isTruncatable = descriptionCharacterCount > characterThreshold
    }

    mutating func bindDescription(_ asset: Asset) {
        guard let description = asset.description else {
            self.description = nil
            return
        }

        if isTruncated && isTruncatable {
            var truncatedDescription = String(description.prefix(characterThreshold))

            let lastTruncatedWordStartIndex = truncatedDescription.rangeOfCharacter(
                from: .whitespacesAndNewlines,
                options: .backwards
            )?.upperBound ?? truncatedDescription.startIndex

            let textAfterTruncatedDescription = description[truncatedDescription.endIndex..<description.endIndex]
            let lastTruncatedWordEndIndex = textAfterTruncatedDescription.rangeOfCharacter(
                from: .whitespacesAndNewlines
            )?.lowerBound ?? description.endIndex

            let lastTruncatedWord = String(description[lastTruncatedWordStartIndex..<lastTruncatedWordEndIndex])

            if lastTruncatedWord.isValidURL {
                let isLastWord = lastTruncatedWordEndIndex == description.endIndex
                if isLastWord {
                    truncatedDescription = description
                    isTruncated = false
                    isTruncatable = false
                } else {
                    truncatedDescription = String(description[description.startIndex..<lastTruncatedWordEndIndex]) + "..."
                }
            } else {
                truncatedDescription += "..."
            }

            self.description = truncatedDescription.bodyRegular()
        } else {
            self.description = description.bodyRegular()
        }
    }
}

fileprivate extension String {
    /// <note>
    /// Valid URL check that matches with `ActiveLabel`'s URL pattern.
    var isValidURL: Bool {
        get {
            let pattern = "(^|[\\s.:;?\\-\\]<\\(])" +
            "((https?://|www\\.|pic\\.)[-\\w;/?:@&=+$\\|\\_.!~*\\|'()\\[\\]%#,☺]+[\\w/#](\\(\\))?)" +
            "(?=$|[\\s',\\|\\(\\).:;?\\-\\[\\]>\\)])"
            let predicate = NSPredicate(format: "SELF MATCHES %@", argumentArray: [pattern])
            return predicate.evaluate(with: self)
        }
    }
}
