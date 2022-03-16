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

//   CollectibleMediaPreviewViewModel.swift

import Foundation
import UIKit
import MacaroonUIKit
import MacaroonURLImage
import Prism

struct CollectibleMediaPreviewViewModel: ViewModel {
    private(set) var image: ImageSource?

    init(
        imageSize: CGSize,
        model: CollectibleAsset
    ) {
        bindImage(
            imageSize: imageSize,
            asset: model
        )
    }
}

extension CollectibleMediaPreviewViewModel {
    private mutating func bindImage(
        imageSize: CGSize,
        asset: CollectibleAsset
    ) {
        let placeholder = asset.title.fallback(asset.name.fallback("#\(String(asset.id))"))

        let size: ImageSize

        if imageSize.width <= 0 ||
            imageSize.height <= 0 {
            size = .original
        } else {
            size = .resize(imageSize, .aspectFit)
        }

        if let primaryImage = asset.primaryImage {
            let prismURL = PrismURL(baseURL: primaryImage)
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
        }

        image = PNGImageSource(
            url: nil,
            placeholder: ImagePlaceholder(
                image: nil,
                text: getPlaceholder(placeholder)
            )
        )
    }

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
