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

//
//   WCSessionItemViewModel.swift

import UIKit
import MacaroonUIKit
import SwiftDate
import MacaroonURLImage

final class WCSessionItemViewModel: PairedViewModel {
    private(set) var image: ImageSource?
    private(set) var name: String?
    private(set) var description: String?
    private(set) var status: String?
    private(set) var date: String?

    init(_ session: WCSession) {
        bindImage(session)
        bindName(session)
        bindDescription(session)
        bindStatus(session)
        bindDate(session)
    }
}

extension WCSessionItemViewModel {
    private func bindImage(_ session: WCSession) {
        let placeholderImages: [Image] = [
            "icon-session-placeholder-1",
            "icon-session-placeholder-2",
            "icon-session-placeholder-3",
            "icon-session-placeholder-4"
        ]

        image = PNGImageSource(
            url: session.peerMeta.icons.first,
            color: nil,
            size: .resize(CGSize(width: 40, height: 40), .aspectFit),
            shape: .circle,
            placeholder: ImagePlaceholder(image: AssetImageSource(asset:  placeholderImages.randomElement()?.uiImage), text: nil),
            forceRefresh: false
        )
    }

    private func bindName(_ session: WCSession) {
        name = session.peerMeta.name
    }

    private func bindDescription(_ session: WCSession) {
        description = session.peerMeta.description
    }

    private func bindStatus(_ session: WCSession) {
        if let connectedAccount = session.walletMeta?.accounts?.first {
            status = "wallet-connect-session-connected-with-account".localized(params: connectedAccount.shortAddressDisplay())
            return
        }

        status = "wallet-connect-session-connected".localized
    }

    private func bindDate(_ session: WCSession) {
        date = session.date.toFormat("MMMM dd, yyyy - HH:mm")
    }
}
