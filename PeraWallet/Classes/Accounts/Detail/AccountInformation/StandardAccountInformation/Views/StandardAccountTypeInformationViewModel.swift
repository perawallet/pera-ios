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

//   StandardAccountTypeInformationViewModel.swift

import Foundation
import MacaroonUIKit

struct StandardAccountTypeInformationViewModel: AccountTypeInformationViewModel {
    private(set) var title: TextProvider?
    private(set) var typeIcon: Image?
    private(set) var typeTitle: TextProvider?
    private(set) var typeFootnote: TextProvider?
    private(set) var typeDescription: TypeDescriptionTextProvider?

    init(isHDWallet: Bool) {
        bindTitle()
        bindTypeIcon(isHDWallet)
        bindTypeTitle(isHDWallet)
        bindTypeDescription(isHDWallet)
    }
}

extension StandardAccountTypeInformationViewModel {
    mutating func bindTitle() {
        title =
            String(localized: "title-account-type")
                .footnoteRegular(lineBreakMode: .byTruncatingTail)
    }

    mutating func bindTypeIcon(_ isHDWallet: Bool) {
        if isHDWallet {
            typeIcon = "icon-hd-account".uiImage
            return
        }
        
        typeIcon = "icon-standard-account".uiImage
    }

    mutating func bindTypeTitle(_ isHDWallet: Bool) {
        if isHDWallet {
            typeTitle =
                String(localized: "mnemonic-types-bip39-title")
                    .bodyMedium(lineBreakMode: .byTruncatingTail)
            return
        }
        
        typeTitle =
            String(localized: "title-standard")
                .bodyMedium(lineBreakMode: .byTruncatingTail)
    }

    mutating func bindTypeDescription(_ isHDWallet: Bool) {
        let descriptionText: NSAttributedString
        
        if isHDWallet {
            descriptionText = String(localized: "standard-account-hd-type-description").footnoteRegular()
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
