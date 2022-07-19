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

//   VerificationInfoViewModel.swift

import Foundation
import MacaroonUIKit

struct VerificationInfoViewModel: ViewModel {
    private(set) var title: EditText?
    private(set) var firstDescription: NSAttributedString?
    private(set) var secondDescription: NSAttributedString?
    private(set) var thirdDescription: NSAttributedString?

    init() {
        bindTitle()
        bindFirstDescription()
        bindSecondDescription()
        bindThirdDescription()
    }
}

extension VerificationInfoViewModel {
    private mutating func bindTitle() {
        self.title = .attributedString(
            "verification-info-title"
                .localized
                .title1Medium(hasMultilines: false)
        )
    }

    private mutating func bindFirstDescription() {
        let fullText = "verification-info-first-description".localized
        let highlightedText = "verification-info-first-description-highlight".localized

        self.firstDescription = highlight(
            highlightedText,
            in: fullText
        )
    }

    private mutating func bindSecondDescription() {
        let fullText = "verification-info-second-description".localized
        let highlightedText = "verification-info-second-description-highlight".localized

        self.secondDescription = highlight(
            highlightedText,
            in: fullText
        )
    }

    private mutating func bindThirdDescription() {
        let fullText = "verification-info-third-description".localized
        let highlightedText = "verification-info-third-description-highlight".localized

        self.thirdDescription = highlight(
            highlightedText,
            in: fullText
        )
    }

    private func highlight(
        _ highlightedText: String,
        in text: String
    ) -> NSMutableAttributedString {
        let attributedText = NSMutableAttributedString(
            attributedString: text.bodyRegular()
        )

        let range = (text as NSString).range(of: highlightedText)
        attributedText.addAttribute(
            NSAttributedString.Key.font,
            value: Fonts.DMSans.medium.make(15).uiFont,
            range: range
        )

        return attributedText
    }
}
