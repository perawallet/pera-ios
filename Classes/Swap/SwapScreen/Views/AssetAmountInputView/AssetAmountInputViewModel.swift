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

//   AssetAmountInputViewModel.swift

import Foundation
import MacaroonUIKit
import MacaroonURLImage
import Prism
import UIKit

struct AssetAmountInputViewModel: ViewModel {
    private(set) var imageSource: ImageSource?
    private(set) var inputValue: TextProvider?
    private(set) var isInputEditable = true
    private(set) var detail: TextProvider?

    init(
        asset: Asset,
        isInputEditable: Bool
    ) {
        bindIcon(asset)
        bindInputValue(asset)
        bindInputEditable(isInputEditable)
        bindDetail(asset)
    }
}

extension AssetAmountInputViewModel {
    mutating func bindIcon(
        _ asset: Asset
    ) {
        if asset.isAlgo {
            imageSource = AssetImageSource(
                asset: "icon-algo-circle-green".uiImage
            )
            return
        }

        let title = asset.naming.name.isNilOrEmpty
            ? "title-unknown".localized
            : asset.naming.name

        let imageSize = CGSize(width: 40, height: 40)
        let prismURL = PrismURL(baseURL: asset.logoURL)?
            .setExpectedImageSize(imageSize)
            .setImageQuality(.normal)
            .build()

        let placeholderText = TextFormatter.assetShortName.format(
            (title.isNilOrEmpty ? "title-unknown".localized : title!)
        )

        imageSource = PNGImageSource(
            url: prismURL,
            shape: .circle,
            placeholder: getPlaceholder(
                placeholderText,
                with: TextAttributes(
                    font: Fonts.DMSans.regular.make(13),
                    lineHeightMultiplier: 1.18
                )
            )
        )
    }

    mutating func bindInputValue(
        _ asset: Asset
    ) {
        /// <todo> This will be implemented while constructing the screen.
    }

    mutating func bindInputEditable(
        _ isInputEditable: Bool
    ) {
        self.isInputEditable = isInputEditable
    }

    mutating func bindDetail(
        _ asset: Asset
    ) {
        /// <todo> This will be implemented while constructing the screen.
    }
}

extension AssetAmountInputViewModel {
    private func getPlaceholder(
        _ aPlaceholder: String?,
        with attributes: TextAttributes
    ) -> ImagePlaceholder? {
        guard let aPlaceholder = aPlaceholder else {
            return nil
        }

        let font = attributes.font
        let lineHeightMultiplier = attributes.lineHeightMultiplier

        let placeholderText: EditText = .attributedString(
            aPlaceholder.attributed([
                .font(font),
                .lineHeightMultiplier(lineHeightMultiplier, font),
                .paragraph([
                    .textAlignment(.center),
                    .lineBreakMode(.byTruncatingTail),
                    .lineHeightMultiple(lineHeightMultiplier)
                ])
            ])
        )

        return ImagePlaceholder(
            image: AssetImageSource(
                asset: "asset-image-placeholder-border".uiImage
            ),
            text: placeholderText
        )
    }
}
