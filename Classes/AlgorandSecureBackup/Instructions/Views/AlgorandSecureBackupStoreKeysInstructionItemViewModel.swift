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

//   AlgorandSecureBackupStoreKeysInstructionItemViewModel.swift

import Foundation
import MacaroonUIKit

struct AlgorandSecureBackupStoreKeysInstructionItemViewModel: AlgorandSecureBackupInstructionItemViewModel {
    var number: TextProvider
    var title: TextProvider
    var subtitle: SubtitleTextProvider

    init(number: Int) {
        self.number = Self.getNumber(number)
        self.title = Self.getTitle()
        self.subtitle = Self.getSubtitle()
    }
}

extension AlgorandSecureBackupStoreKeysInstructionItemViewModel {
    private static func getNumber(_ number: Int) -> TextProvider {
        return "\(number)".bodyRegular(alignment: .center)
    }

    private static  func getTitle() -> TextProvider {
        return "algorand-secure-backup-instruction-store-keys-instruction-title".localized.bodyMedium()
    }

    private static func getSubtitle() -> SubtitleTextProvider {
        let subtitleText = "algorand-secure-backup-instruction-store-keys-instruction-subtitle".localized.footnoteRegular()
        var subtitleHighlightedTextAttributes = Typography.footnoteMediumAttributes(
            alignment: .center
        )
        subtitleHighlightedTextAttributes.insert(.textColor(Colors.Helpers.positive.uiColor))
        let subtitleHighlightedText = HighlightedText(
            text: "algorand-secure-backup-instruction-store-keys-instruction-subtitle-highlighted-text".localized,
            attributes: subtitleHighlightedTextAttributes
        )

        return SubtitleTextProvider(text: subtitleText, highlightedText: subtitleHighlightedText)
    }
}
