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

//   RekeyedAccountTypeInformationViewModel.swift

import Foundation
import MacaroonUIKit
import pera_wallet_core

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
        title = String(localized: "title-account-type").footnoteRegular(lineBreakMode: .byTruncatingTail)
    }

    private mutating func bindTypeIcon(_ sourceAccount: Account) {
        let icon: Image?

        let authorization = sourceAccount.authorization

        if authorization.isLedgerToLedgerRekeyed {
            icon = makeLedgerAccountToLedgerAccountRekeyedAccountTypeIcon()
        } else if authorization.isLedgerToStandardRekeyed {
            icon = makeLedgerAccountToStandardAccountRekeyedAccountTypeIcon()
        } else if authorization.isStandardToLedgerRekeyed {
            icon = makeStandardAccountToLedgerAccountRekeyedAccountTypeIcon()
        } else if authorization.isStandardToStandardRekeyed {
            icon = makeStandardAccountToStandardAccountRekeyedAccountTypeIcon()
        } else if authorization.isUnknownToLedgerRekeyed {
            icon = makeUnknownAccountToLedgerAccountRekeyedAccountTypeIcon()
        } else if authorization.isUnknownToStandardRekeyed {
            icon = makeUnknownAccountToStandardAccountRekeyedAccountTypeIcon()
        } else if authorization.isJointAccountRekeyed {
            icon = makeJointAccountToJointAccountRekeyedAccountTypeIcon()
        } else {
            icon = nil
        }

        self.typeIcon = icon
    }

    private mutating func bindTypeTitle(_ sourceAccount: Account) {
        let title: TextProvider?

        let authorization = sourceAccount.authorization

        if authorization.isLedgerToLedgerRekeyed {
            title = makeLedgerAccountToLedgerAccountRekeyedAccountTypeTitle()
        } else if authorization.isLedgerToStandardRekeyed {
            title = makeLedgerAccountToStandardAccountRekeyedAccountTypeTitle()
        } else if authorization.isStandardToLedgerRekeyed {
            title = makeStandardAccountToLedgerAccountRekeyedAccountTypeTitle()
        } else if authorization.isStandardToStandardRekeyed {
            title = makeStandardAccountToStandardAccountRekeyedAccountTypeTitle()
        } else if authorization.isUnknownToLedgerRekeyed {
            title = makeUnknownAccountToLedgerAccountRekeyedAccountTypeTitle()
        } else if authorization.isUnknownToStandardRekeyed {
            title = makeUnknownAccountToStandardAccountRekeyedAccountTypeTitle()
        } else if authorization.isJointAccountRekeyed {
            title = makeJointAccountToJointAccountRekeyedAccountTypeTitle()
        } else {
            title = nil
        }

        self.typeTitle = title
    }

    private mutating func bindTypeFootnote(_ sourceAccount: Account) {
        let footnote: TextProvider?

        let authorization = sourceAccount.authorization

        if authorization.isUnknownToLedgerRekeyed {
            footnote = makeUnknownAccountToLedgerAccountRekeyedAccountTypeFootnote()
        } else if authorization.isUnknownToStandardRekeyed {
            footnote = makeUnknownAccountToStandardAccountRekeyedAccountTypeFootnote()
        } else {
            footnote = nil
        }

        self.typeFootnote = footnote
    }

    private mutating func bindTypeDescription(_ sourceAccount: Account) {
        let description: TypeDescriptionTextProvider?

        let authorization = sourceAccount.authorization

        if authorization.isLedgerToLedgerRekeyed {
            description = makeLedgerAccountToLedgerAccountRekeyedAccountTypeDescription()
        } else if authorization.isLedgerToStandardRekeyed {
            description = makeLedgerAccountToStandardAccountRekeyedAccountTypeDescription()
        } else if authorization.isStandardToLedgerRekeyed {
            description = makeStandardAccountToLedgerAccountRekeyedAccountTypeDescription()
        } else if authorization.isStandardToStandardRekeyed {
            description = makeStandardAccountToStandardAccountRekeyedAccountTypeDescription()
        } else if authorization.isUnknownToLedgerRekeyed {
            description = makeUnknownAccountToLedgerAccountRekeyedAccountTypeDescription()
        } else if authorization.isUnknownToStandardRekeyed {
            description = makeUnknownAccountToStandardAccountRekeyedAccountTypeDescription()
        } else if authorization.isJointAccountRekeyed {
            description = makeJointAccountToJointAccountRekeyedAccountTypeDescription()
        } else {
            description = nil
        }

        self.typeDescription = description
    }
}

extension RekeyedAccountTypeInformationViewModel {
    private mutating func makeLedgerAccountToLedgerAccountRekeyedAccountTypeIcon() -> Image { "icon-any-to-ledger-rekeyed-account".uiImage }
    private mutating func makeLedgerAccountToLedgerAccountRekeyedAccountTypeTitle() -> TextProvider { makeTypeTitle(text: String(localized: "title-ledger-to-ledger-rekeyed")) }
    private mutating func makeLedgerAccountToLedgerAccountRekeyedAccountTypeDescription() -> TypeDescriptionTextProvider {
        makeTypeDescription(
            text:  String(localized: "ledger-to-ledger-rekeyed-account-type-description"),
            highlightedText: String(localized: "title-learn-more")
        )
    }
}

extension RekeyedAccountTypeInformationViewModel {
    private mutating func makeLedgerAccountToStandardAccountRekeyedAccountTypeIcon() -> Image { "icon-any-to-standard-rekeyed-account".uiImage }
    private mutating func makeLedgerAccountToStandardAccountRekeyedAccountTypeTitle() -> TextProvider { makeTypeTitle(text: String(localized: "title-ledger-to-standard-rekeyed")) }
    private mutating func makeLedgerAccountToStandardAccountRekeyedAccountTypeDescription() -> TypeDescriptionTextProvider {
        makeTypeDescription(
            text: String(localized: "ledger-to-standard-rekeyed-account-type-description"),
            highlightedText: String(localized: "title-learn-more")
        )
    }
}

extension RekeyedAccountTypeInformationViewModel {
    private mutating func makeStandardAccountToLedgerAccountRekeyedAccountTypeIcon() -> Image { "icon-any-to-ledger-rekeyed-account".uiImage }
    private mutating func makeStandardAccountToLedgerAccountRekeyedAccountTypeTitle() -> TextProvider { makeTypeTitle(text: String(localized: "title-standard-to-ledger-rekeyed")) }
    private mutating func makeStandardAccountToLedgerAccountRekeyedAccountTypeDescription() -> TypeDescriptionTextProvider {
        makeTypeDescription(
            text: String(localized: "standard-to-ledger-rekeyed-account-type-description"),
            highlightedText: String(localized: "title-learn-more")
        )
    }
}

extension RekeyedAccountTypeInformationViewModel {
    private mutating func makeStandardAccountToStandardAccountRekeyedAccountTypeIcon() -> Image { "icon-any-to-standard-rekeyed-account".uiImage }
    private mutating func makeStandardAccountToStandardAccountRekeyedAccountTypeTitle() -> TextProvider { makeTypeTitle(text: String(localized: "title-standard-to-standard-rekeyed")) }
    private mutating func makeStandardAccountToStandardAccountRekeyedAccountTypeDescription() -> TypeDescriptionTextProvider {
        makeTypeDescription(
            text: String(localized: "standard-to-standard-rekeyed-account-type-description"),
            highlightedText: String(localized: "title-learn-more")
        )
    }
}

extension RekeyedAccountTypeInformationViewModel {
    private mutating func makeUnknownAccountToStandardAccountRekeyedAccountTypeIcon() -> Image { "icon-any-to-standard-rekeyed-account".uiImage }
    private mutating func makeUnknownAccountToStandardAccountRekeyedAccountTypeTitle() -> TextProvider { makeTypeTitle(text: String(localized: "title-unknown-to-standard-rekeyed")) }
    private mutating func makeUnknownAccountToStandardAccountRekeyedAccountTypeFootnote() -> TextProvider { makeTypeFootnote(text: String(localized: "no-record-of-original-account-type-footnote")) }
    private mutating func makeUnknownAccountToStandardAccountRekeyedAccountTypeDescription() -> TypeDescriptionTextProvider {
        makeTypeDescription(
            text: String(localized: "standard-to-standard-rekeyed-account-type-description"),
            highlightedText: String(localized: "title-learn-more")
        )
    }
}

extension RekeyedAccountTypeInformationViewModel {
    private mutating func makeUnknownAccountToLedgerAccountRekeyedAccountTypeIcon() -> Image { "icon-any-to-ledger-rekeyed-account".uiImage }
    private mutating func makeUnknownAccountToLedgerAccountRekeyedAccountTypeTitle() -> TextProvider { makeTypeTitle(text: String(localized: "title-unknown-to-ledger-rekeyed")) }
    private mutating func makeUnknownAccountToLedgerAccountRekeyedAccountTypeFootnote() -> TextProvider { makeTypeFootnote(text: String(localized: "no-record-of-original-account-type-footnote")) }
    private mutating func makeUnknownAccountToLedgerAccountRekeyedAccountTypeDescription() -> TypeDescriptionTextProvider {
        makeTypeDescription(
            text: String(localized: "standard-to-ledger-rekeyed-account-type-description"),
            highlightedText: String(localized: "title-learn-more")
        )
    }
}

extension RekeyedAccountTypeInformationViewModel{
    private mutating func makeJointAccountToJointAccountRekeyedAccountTypeIcon() -> Image { "icon-any-to-standard-rekeyed-account".uiImage }
    private mutating func makeJointAccountToJointAccountRekeyedAccountTypeTitle() -> TextProvider { makeTypeTitle(text: String(localized: "rekeyed-account-type-joint-to-joint-title")) }
    private mutating func makeJointAccountToJointAccountRekeyedAccountTypeDescription() -> TypeDescriptionTextProvider {
        makeTypeDescription(
            text: String(localized: "rekeyed-account-type-joint-to-joint-description"),
            highlightedText: String(localized: "title-learn-more")
        )
    }
    private mutating func makeJointAccountRekeyedAccountTypeIcon() -> Image { "icon-joint-to-joint-account-rekeyed-account".uiImage }
    private mutating func makeJointAccountRekeyedAccountTypeTitle() -> TextProvider { makeTypeTitle(text: String(localized: "title-joint-account-to-joint-account-rekeyed")) }
}

extension RekeyedAccountTypeInformationViewModel {
    private func makeTypeTitle(text: String) -> TextProvider { text.bodyMedium(lineBreakMode: .byTruncatingTail) }
    private func makeTypeFootnote(text: String) -> TextProvider { text.footnoteRegular(lineBreakMode: .byTruncatingTail) }
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
