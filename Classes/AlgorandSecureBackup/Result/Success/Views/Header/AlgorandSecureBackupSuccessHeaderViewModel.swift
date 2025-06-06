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

//   AlgorandSecureBackupSuccessHeaderViewModel.swift

import Foundation
import MacaroonUIKit

struct AlgorandSecureBackupSuccessHeaderViewModel: ResultWithHyperlinkViewModel {
    private(set) var icon: Image?
    private(set) var title: TextProvider?
    private(set) var body: BodyTextProvider?

    init() {
        bindIcon()
        bindTitle()
        bindBody()
    }
}

extension AlgorandSecureBackupSuccessHeaderViewModel {
    private mutating func bindIcon() {
        icon = "check"
    }

    private mutating func bindTitle() {
        title = String(localized: "algorand-secure-backup-success-header-title").titleMedium()
    }

    private mutating func bindBody() {
        let bodyText = String(localized: "algorand-secure-backup-success-header-body").bodyRegular()

        var bodyHighlightedTextAttributes = Typography.bodyMediumAttributes(alignment: .center)
        bodyHighlightedTextAttributes.insert(.textColor(Colors.Helpers.positive.uiColor))

        let bodyHighlightedText = HighlightedText(
            text: String(localized: "title-learn-more"),
            attributes: bodyHighlightedTextAttributes
        )
        body = BodyTextProvider(text: bodyText, highlightedText: bodyHighlightedText)
    }
}
