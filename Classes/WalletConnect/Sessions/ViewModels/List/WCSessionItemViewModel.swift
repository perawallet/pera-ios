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

import CoreGraphics
import MacaroonUIKit
import SwiftDate
import MacaroonURLImage
import Foundation

struct WCSessionItemViewModel: ViewModel {
    private(set) var image: ImageSource?
    private(set) var name: TextProvider?
    private(set) var wcV1Badge: TextProvider?
    private(set) var description: TextProvider?
    private(set) var status: TextStyle?

    init(
        peermeta: WCPeerMeta,
        sessionDate: Date
    ) {
        bindImage(peermeta)
        bindName(peermeta)
        bindWCv1Badge()
        bindDescription(sessionDate)
        bindStatus()
    }
}

extension WCSessionItemViewModel {
    private mutating func bindImage(_ peerMeta: WCPeerMeta) {
        let placeholderImages: [Image] = [
            "icon-session-placeholder-1",
            "icon-session-placeholder-2",
            "icon-session-placeholder-3",
            "icon-session-placeholder-4"
        ]
        let placeholderImage = placeholderImages.randomElement()!
        let placeholderAsset = AssetImageSource(asset: placeholderImage.uiImage)
        let placeholder = ImagePlaceholder(image: placeholderAsset, text: nil)

        let imageSize = CGSize(width: 40, height: 40)
        image = DefaultURLImageSource(
            url: peerMeta.icons.first,
            size: .resize(imageSize, .aspectFit),
            shape: .circle,
            placeholder: placeholder
        )
    }

    private mutating func bindName(_ peerMeta: WCPeerMeta) {
        name = peerMeta.name.bodyMedium(lineBreakMode: .byTruncatingTail)
    }

    private mutating func bindWCv1Badge() {
        /// <todo> For mocking purposes
        wcV1Badge = "WCV1".footnoteMedium(
            alignment: .center,
            lineBreakMode: .byTruncatingTail
        )
    }

    private mutating func bindDescription(_ sessionDate: Date) {
        /// <todo> For mocking purposes
        description = getDescriptionForWCv1()
    }

    private mutating func bindStatus() {
        /// <todo> For mocking purposes
       status = getConnectedStatus()
    }
}

extension WCSessionItemViewModel {
    private func getDescriptionForWCv1() -> TextProvider {
        /// <todo> For mocking purposes
        let formattedDate = Date().toFormat("MMMM dd, yyyy - HH:mm")
        return
            "wallet-connect-session-connected-on-date"
                .localized(formattedDate)
                .footnoteRegular(lineBreakMode: .byTruncatingTail)
    }

    private func getDescriptionForWCv2() -> TextProvider {
        /// <todo> For mocking purposes
        let formattedDate = Date().toFormat("MMMM dd, yyyy - HH:mm")
        return
            "wallet-connect-v2-session-expires-on-date"
                .localized(formattedDate)
                .footnoteRegular(lineBreakMode: .byTruncatingTail)
    }
}

extension WCSessionItemViewModel {
    private func getConnectedStatus() -> TextStyle {
        let text =
            "wallet-connect-session-connected"
                .localized
                .footnoteMedium(
                    alignment: .center,
                    lineBreakMode: .byTruncatingTail
                )
        return [
            .text(text),
            .textColor(Colors.Helpers.positive),
            .textAlignment(.center),
            .textOverflow(SingleLineText()),
            .backgroundColor(Colors.Helpers.positive.uiColor.withAlphaComponent(0.1))
        ]
    }

    private func getDisconnectedStatus() -> TextStyle {
        let text =
            "wallet-connect-session-disconnected"
                .localized
                .footnoteMedium(
                    alignment: .center,
                    lineBreakMode: .byTruncatingTail
                )
        return [
            .text(text),
            .textColor(Colors.Helpers.negative),
            .textAlignment(.center),
            .textOverflow(SingleLineText()),
            .backgroundColor(Colors.Helpers.negative.uiColor.withAlphaComponent(0.1))
        ]
    }
}
