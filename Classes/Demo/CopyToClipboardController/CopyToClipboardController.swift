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

//   CopyToClipboardActionController.swift

import Foundation
import MacaroonUIKit

protocol CopyToClipboardController {
    func copy(
        _ item: ClipboardItem
    )
}

extension CopyToClipboardController {
    func copy(
        _ account: Account
    ) {
        let copyText = account.address
        let feedbackTitle = "qr-creation-copied\n".localized
            .bodyMedium(
                alignment: .center
            )
        let feedbackBody = account.address
            .shortAddressDisplay
            .footnoteRegular(
                alignment: .center,
                lineBreakMode: .byTruncatingMiddle
            )
        let feedbackText = feedbackTitle + feedbackBody
        let item = ClipboardItem(copyText: copyText, feedbackText: feedbackText)

        copy(item)
    }
}

struct ClipboardItem {
    let copyText: String
    /// The message to give feedback to the user as the result of the copy action.
    let feedbackText: TextProvider?

    init(
        copyText: String,
        feedbackText: TextProvider? = nil
    ) {
        self.copyText = copyText
        self.feedbackText = feedbackText
    }
}
