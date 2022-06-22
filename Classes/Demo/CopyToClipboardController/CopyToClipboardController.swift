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
    func copyAddress(
        _ account: Account
    ) {
        let addressCopy = account.address
        let interaction = AccountAddressClipboardInteraction(account)
        let item = ClipboardItem(copy: addressCopy, interaction: interaction)
        copy(item)
    }

    func copyID(
        _ asset: Asset
    ) {
        let idCopy = asset.id
        let interaction = AssetIDClipboardInteraction(asset)
        let item = ClipboardItem(copy: String(idCopy), interaction: interaction)
        return copy(item)
    }
}

struct ClipboardItem {
    let copy: String
    /// The message to interact with the user as the result of the copy action.
    let interaction: ClipboardInteraction?

    init(
        copy: String,
        interaction: ClipboardInteraction? = nil
    ) {
        self.copy = copy
        self.interaction = interaction
    }
}

protocol ClipboardInteraction: ToastViewModel {}

struct AccountAddressClipboardInteraction: ClipboardInteraction {
    private(set) var title: TextProvider?
    private(set) var body: TextProvider?

    init(
        _ account: Account
    ) {
        self.title = "qr-creation-copied"
            .localized
            .bodyMedium(alignment: .center)
        self.body = account.address
            .shortAddressDisplay
            .footnoteRegular(
                alignment: .center
            )
    }
}

struct AssetIDClipboardInteraction: ClipboardInteraction {
    private(set) var title: TextProvider?
    private(set) var body: TextProvider?

    init(
        _ asset: Asset
    ) {
        self.title = "asset-id-copied-title"
            .localized
            .bodyMedium(alignment: .center)
        self.body = asset.id
            .stringWithHashtag
            .footnoteRegular(
                alignment: .center
            )
    }
}
