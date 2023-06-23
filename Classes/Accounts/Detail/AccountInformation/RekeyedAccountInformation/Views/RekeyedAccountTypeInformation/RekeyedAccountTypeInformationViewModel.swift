// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   RekeyedAccountTypeInformationViewModel.swift

import Foundation
import MacaroonUIKit

struct RekeyedAccountTypeInformationViewModel: AccountTypeInformationViewModel {
    private(set) var title: TextProvider?
    private(set) var typeIcon: Image?
    private(set) var typeTitle: TextProvider?
    private(set) var typeFootnote: TextProvider?
    private(set) var typeDescription: TypeDescriptionTextProvider?

    init(sourceAccount: Account) {
        bindTitle(sourceAccount)
        bindTypeIcon(sourceAccount)
        bindTypeTitle(sourceAccount)
        bindTypeFootnote(sourceAccount)
        bindTypeDescription(sourceAccount)
    }
}

extension RekeyedAccountTypeInformationViewModel {
    private mutating func bindTitle(_ sourceAccount: Account) {
        title =
            "title-account-type"
                .localized
                .footnoteRegular(lineBreakMode: .byTruncatingTail)
    }

    private mutating func bindTypeIcon(_ sourceAccount: Account) {
        let icon: Image?

        switch sourceAccount.type {
        case .rekeyed:
            icon = makeLedgerAccountToLedgerAccountRekeyedAccountTypeIcon()
        default:
            icon = nil
        }

        self.typeIcon = icon
    }

    private mutating func bindTypeTitle(_ sourceAccount: Account) {
        let title: TextProvider?

        switch sourceAccount.type {
        case .rekeyed:
            title = makeLedgerAccountToLedgerAccountRekeyedAccountTypeTitle()
        default:
            title = nil
        }

        self.typeTitle = title
    }

    private mutating func bindTypeFootnote(_ sourceAccount: Account) {
        let footnote: TextProvider?

        switch sourceAccount.type {
        case .rekeyed:
            footnote = makeUnknownAccountToLedgerAccountRekeyedAccountTypeFootnote()
        default:
            footnote = nil
        }

        self.typeFootnote = footnote
    }

    private mutating func bindTypeDescription(_ sourceAccount: Account) {
        let description: TypeDescriptionTextProvider?

        switch sourceAccount.type {
        case .rekeyed:
            description = makeLedgerAccountToLedgerAccountRekeyedAccountTypeDescription()
        default:
            description = nil
        }

        self.typeDescription = description
    }
}

extension RekeyedAccountTypeInformationViewModel {
    private mutating func makeLedgerAccountToLedgerAccountRekeyedAccountTypeIcon() -> Image {
        return "icon-any-to-ledger-rekeyed-account".uiImage
    }

    private mutating func makeLedgerAccountToLedgerAccountRekeyedAccountTypeTitle() -> TextProvider {
        return makeTypeTitle(text: "title-ledger-to-ledger-rekeyed".localized)
    }

    private mutating func makeLedgerAccountToLedgerAccountRekeyedAccountTypeDescription() -> TypeDescriptionTextProvider {
        return makeTypeDescription(
            text:  "ledger-to-ledger-rekeyed-account-type-description".localized,
            highlightedText: "ledger-to-ledger-rekeyed-account-type-description-highlighted-text".localized
        )
    }
}

extension RekeyedAccountTypeInformationViewModel {
    private mutating func makeLedgerAccountToStandardAccountRekeyedAccountTypeIcon() -> Image {
        return "icon-any-to-standard-rekeyed-account".uiImage
    }

    private mutating func makeLedgerAccountToStandardAccountRekeyedAccountTypeTitle() -> TextProvider {
        return makeTypeTitle(text: "title-ledger-to-standard-rekeyed".localized)
    }

    private mutating func makeLedgerAccountToStandardAccountRekeyedAccountTypeDescription() -> TypeDescriptionTextProvider {
        return makeTypeDescription(
            text: "ledger-to-standard-rekeyed-account-type-description".localized,
            highlightedText: "ledger-to-standard-rekeyed-account-type-description-highlighted-text".localized
        )
    }
}

extension RekeyedAccountTypeInformationViewModel {
    private mutating func makeStandardAccountToLedgerAccountRekeyedAccountTypeIcon() -> Image {
        return "icon-any-to-ledger-rekeyed-account".uiImage
    }

    private mutating func makeStandardAccountToLedgerAccountRekeyedAccountTypeTitle() -> TextProvider {
        return makeTypeTitle(text: "title-standard-to-ledger-rekeyed".localized)
    }

    private mutating func makeStandardAccountToLedgerAccountRekeyedAccountTypeDescription() -> TypeDescriptionTextProvider {
        return makeTypeDescription(
            text: "standard-to-ledger-rekeyed-account-type-description".localized,
            highlightedText: "standard-to-ledger-rekeyed-account-type-description-highlighted-text".localized
        )
    }
}

extension RekeyedAccountTypeInformationViewModel {
    private mutating func makeStandardAccountToStandardAccountRekeyedAccountTypeIcon() -> Image {
        return "icon-any-to-standard-rekeyed-account".uiImage
    }

    private mutating func makeStandardAccountToStandardAccountRekeyedAccountTypeTitle() -> TextProvider {
        return makeTypeTitle(text: "title-standard-to-standard-rekeyed".localized)
    }

    private mutating func makeStandardAccountToStandardAccountRekeyedAccountTypeDescription() -> TypeDescriptionTextProvider {
        return makeTypeDescription(
            text: "standard-to-standard-rekeyed-account-type-description".localized,
            highlightedText: "standard-to-standard-rekeyed-account-type-description-highlighted-text".localized
        )
    }
}

extension RekeyedAccountTypeInformationViewModel {
    private mutating func makeUnknownAccountToStandardAccountRekeyedAccountTypeIcon() -> Image {
        return "icon-any-to-ledger-rekeyed-account".uiImage
    }

    private mutating func makeUnknownAccountToStandardAccountRekeyedAccountTypeTitle() -> TextProvider {
        return makeTypeTitle(text: "title-unknown-to-standard-rekeyed".localized)
    }

    private mutating func makeUnknownAccountToStandardAccountRekeyedAccountTypeFootnote() -> TextProvider {
        return makeTypeFootnote(text: "no-record-of-original-account-type-footnote".localized)
    }

    private mutating func makeUnknownAccountToStandardAccountRekeyedAccountTypeDescription() -> TypeDescriptionTextProvider {
        return makeTypeDescription(
            text: "standard-to-standard-rekeyed-account-type-description".localized,
            highlightedText: "standard-to-standard-rekeyed-account-type-description-highlighted-text".localized
        )
    }
}

extension RekeyedAccountTypeInformationViewModel {
    private mutating func makeUnknownAccountToLedgerAccountRekeyedAccountTypeIcon() -> Image {
        return "icon-any-to-ledger-rekeyed-account".uiImage
    }

    private mutating func makeUnknownAccountToLedgerAccountRekeyedAccountTypeTitle() -> TextProvider {
        return makeTypeTitle(text: "title-unknown-to-ledger-rekeyed".localized)
    }

    private mutating func makeUnknownAccountToLedgerAccountRekeyedAccountTypeFootnote() -> TextProvider {
        return makeTypeFootnote(text: "no-record-of-original-account-type-footnote".localized)
    }

    private mutating func makeUnknownAccountToLedgerAccountRekeyedAccountTypeDescription() -> TypeDescriptionTextProvider {
        return makeTypeDescription(
            text: "standard-to-ledger-rekeyed-account-type-description".localized,
            highlightedText: "standard-to-ledger-rekeyed-account-type-description-highlighted-text".localized
        )
    }
}

extension RekeyedAccountTypeInformationViewModel {
    private func makeTypeTitle(text: String) -> TextProvider {
        return text.bodyMedium(lineBreakMode: .byTruncatingTail)
    }

    private func makeTypeFootnote(text: String) -> TextProvider {
        return text.footnoteRegular(lineBreakMode: .byTruncatingTail)
    }

    private func makeTypeDescription(
        text: String,
        highlightedText: String
    ) -> TypeDescriptionTextProvider {
        let descriptionText = text.footnoteRegular()

        var descriptionHighlightedTextAttributes = Typography.footnoteMediumAttributes(alignment: .center)
        descriptionHighlightedTextAttributes.insert(.textColor(Colors.Helpers.positive.uiColor))

        let descriptionHighlightedText = HighlightedText(
            text: highlightedText,
            attributes: descriptionHighlightedTextAttributes
        )

        return TypeDescriptionTextProvider(
            text: descriptionText,
            highlightedText: descriptionHighlightedText
        )
    }
}
