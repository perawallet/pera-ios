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

//   CollectibleListItemViewModel.swift

import UIKit
import MacaroonUIKit
import MacaroonURLImage
import Prism

protocol CollectibleListItemViewModel: ViewModel {
    var assetID: AssetID? { get }
    var image: ImageSource? { get }
    var title: EditText? { get }
    var subtitle: EditText? { get }
    var mediaType: MediaType? { get }
}

extension CollectibleListItemViewModel {
    func getAssetID(
        _ asset: CollectibleAsset
    ) -> AssetID? {
        return asset.id
    }

    func getImage(
        imageSize: CGSize,
        asset: CollectibleAsset
    ) -> ImageSource? {
        let placeholder = asset.title.fallback(asset.name.fallback(asset.id.stringWithHashtag))

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

            return PNGImageSource(
                url: prismURL,
                size: size,
                shape: .rounded(4),
                placeholder: ImagePlaceholder(
                    image: nil,
                    text: getPlaceholder(placeholder)
                )
            )
        }

        let imageSource =
        PNGImageSource(
            url: nil,
            placeholder: ImagePlaceholder(
                image: nil,
                text: getPlaceholder(placeholder)
            )
        )

        return imageSource
    }

    func getTitle(
        _ asset: CollectibleAsset
    ) -> EditText? {
        guard let collectionName = asset.collectionName,
              !collectionName.isEmptyOrBlank else {
                  return nil
              }

        let font = Fonts.DMSans.regular.make(13)
        let lineHeightMultiplier = 1.18

        return .attributedString(
            collectionName
                .attributed([
                    .font(font),
                    .lineHeightMultiplier(lineHeightMultiplier, font),
                    .paragraph([
                        .lineBreakMode(.byWordWrapping),
                        .lineHeightMultiple(lineHeightMultiplier),
                        .textAlignment(.left)
                    ])
                ])
        )
    }

    func getSubtitle(
        _ asset: CollectibleAsset
    ) -> EditText? {
        let subtitle = asset.title.fallback(asset.name.fallback(asset.id.stringWithHashtag))

        let font = Fonts.DMSans.regular.make(15)
        let lineHeightMultiplier = 1.23

        return .attributedString(
            subtitle
                .attributed([
                    .font(font),
                    .lineHeightMultiplier(lineHeightMultiplier, font),
                    .paragraph([
                        .lineBreakMode(.byWordWrapping),
                        .lineHeightMultiple(lineHeightMultiplier),
                        .textAlignment(.left)
                    ])
                ])
        )
    }

    func getMediaType(
        _ asset: CollectibleAsset
    ) -> MediaType? {
        return asset.mediaType
    }

    private func getPlaceholder(
        _ aPlaceholder: String
    ) -> EditText {
        let font = Fonts.DMSans.regular.make(13)
        let lineHeightMultiplier = 1.18

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

fileprivate extension Optional where Wrapped == String {
    func fallback(
        _ stringOrNilOrEmptyOrBlank: @autoclosure () -> Self
    ) -> Self {
        switch self {
        case .none:
            return stringOrNilOrEmptyOrBlank()
        case .some(let value):
            if !value.isEmptyOrBlank {
                return value
            }

            return stringOrNilOrEmptyOrBlank()
        }
    }

    func fallback(
        _ string: @autoclosure () -> Wrapped
    ) -> Wrapped {
        switch self {
        case .none:
            return string()
        case .some(let value):
            return value
        }
    }
}

fileprivate extension AssetID {
    var stringWithHashtag: String {
        "#".appending(String(self))
    }
}
