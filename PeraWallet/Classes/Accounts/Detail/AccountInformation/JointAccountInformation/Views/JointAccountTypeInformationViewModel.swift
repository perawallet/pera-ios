// Copyright 2022-2026 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   JointAccountTypeInformationViewModel.swift

import Foundation
import MacaroonUIKit

struct JointAccountTypeInformationViewModel: AccountTypeInformationViewModel {
    private(set) var title: TextProvider?
    private(set) var typeIcon: Image?
    private(set) var typeTitle: TextProvider?
    private(set) var typeFootnote: TextProvider?
    private(set) var typeDescription: TypeDescriptionTextProvider?

    init(hasNoAuth: Bool) {
        bindTitle()
        bindTypeIcon(hasNoAuth)
        bindTypeTitle(hasNoAuth)
        bindTypeDescription(hasNoAuth)
    }
}

extension JointAccountTypeInformationViewModel {
    mutating func bindTitle() {
        title =
            String(localized: "title-account-type")
                .footnoteRegular(lineBreakMode: .byTruncatingTail)
    }

    mutating func bindTypeIcon(_ hasNoAuth: Bool) {
        if hasNoAuth {
            typeIcon = "icon-watch-account".uiImage
            return
        }
        typeIcon = "icon-joint-account".uiImage
    }

    mutating func bindTypeTitle(_ hasNoAuth: Bool) {
        if hasNoAuth {
            typeTitle =
                String(localized: "common-account-type-name-watch")
                    .bodyMedium(lineBreakMode: .byTruncatingTail)
            return
        }
        typeTitle =
            String(localized: "common-account-type-name-joint")
                .bodyMedium(lineBreakMode: .byTruncatingTail)
    }

    mutating func bindTypeDescription(_ hasNoAuth: Bool) {
        let descriptionText: NSAttributedString
        
        if hasNoAuth {
            descriptionText = String(localized: "watch-account-type-description").footnoteRegular()
        } else {
            descriptionText = String(localized: "standard-account-type-description").footnoteRegular()
        }

        var descriptionHighlightedTextAttributes = Typography.footnoteMediumAttributes(alignment: .center)
        descriptionHighlightedTextAttributes.insert(.textColor(Colors.Helpers.positive.uiColor))

        let descriptionHighlightedText = HighlightedText(
            text: String(localized: "title-learn-more"),
            attributes: descriptionHighlightedTextAttributes
        )

        typeDescription = TypeDescriptionTextProvider(
            text: descriptionText,
            highlightedText: descriptionHighlightedText
        )
    }
}
