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

//   CollectibleMediaImagePreviewViewModel.swift

import Foundation
import UIKit
import MacaroonUIKit
import MacaroonURLImage
import Prism

struct CollectibleMediaImagePreviewViewModel: ViewModel {
    private(set) var image: ImageSource?
    private(set) var isOwned: Bool = true

    init(
        imageSize: CGSize,
        asset: CollectibleAsset,
        ownerAccount: Account?,
        url: URL?
    ) {
        bindImage(
            imageSize: imageSize,
            asset: asset,
            url: url
        )

        bindOwned(ownerAccount)
    }
}

extension CollectibleMediaImagePreviewViewModel {
    private mutating func bindImage(
        imageSize: CGSize,
        asset: CollectibleAsset,
        url: URL?
    ) {
        let placeholder = asset.title.fallback(asset.name.fallback("#\(String(asset.id))"))

        let size: ImageSize

        if imageSize.width <= 0 ||
            imageSize.height <= 0 {
            size = .original
        } else {
            size = .resize(imageSize, .aspectFit)
        }

        if let imageURL = url {
            let prismURL = PrismURL(baseURL: imageURL)
                .setExpectedImageSize(imageSize)
                .setResizeMode(.fit)
                .build()

            image = PNGImageSource(
                url: prismURL,
                size: size,
                shape: .rounded(4),
                placeholder: ImagePlaceholder(
                    image: nil,
                    text: getPlaceholder(placeholder)
                )
            )
            return
        }

        image = PNGImageSource(
            url: nil,
            placeholder: ImagePlaceholder(
                image: nil,
                text: getPlaceholder(placeholder)
            )
        )
    }

    private mutating func bindOwned(_ ownerAccount: Account?) {
        isOwned = ownerAccount != nil
    }
}

extension CollectibleMediaImagePreviewViewModel {
    private func getPlaceholder(
        _ aPlaceholder: String
    ) -> EditText {
        let font = Fonts.DMSans.regular.make(19)
        let lineHeightMultiplier = 1.13

        return .attributedString(
            aPlaceholder.attributed([
                .font(font),
                .lineHeightMultiplier(lineHeightMultiplier, font),
                .paragraph([
                    .textAlignment(.center),
                    .lineBreakMode(.byWordWrapping),
                    .lineHeightMultiple(lineHeightMultiplier)
                ])
            ])
        )
    }
}
