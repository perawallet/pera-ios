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

//   SendCollectibleViewModel.swift

import Foundation
import UIKit
import MacaroonUIKit
import MacaroonURLImage
import Prism

struct SendCollectibleViewModel: ViewModel {
    private(set) var existingImage: UIImage?
    private(set) var image: ImageSource?
    private(set) var title: EditText?
    private(set) var subtitle: EditText?

    init<T>(
        imageSize: CGSize,
        draft: T
    ) {
        bind(imageSize: imageSize, draft: draft)
    }
}

extension SendCollectibleViewModel {
    mutating func bind<T>(
        imageSize: CGSize,
        draft: T
    ) {
        if let draft = draft as? SendCollectibleDraft {

            if let existingImage = draft.image {
                bindExistingImage(
                    existingImage
                )
            } else {
                bindImage(
                    imageSize: imageSize,
                    asset: draft.collectibleAsset
                )
            }

            bindTitle(draft.collectibleAsset)
            bindSubtitle(draft.collectibleAsset)

            return
        }
    }
}

extension SendCollectibleViewModel {
    private mutating func bindExistingImage(
        _ image: UIImage
    ) {
        self.existingImage = image
    }

    private mutating func bindImage(
        imageSize: CGSize,
        asset: CollectibleAsset
    ) {
        let placeholder = asset.title.fallback(asset.name.fallback("#\(String(asset.id))"))

        if let imageURL = asset.thumbnailImage {
            let prismURL = PrismURL(baseURL: imageURL)
                .setExpectedImageSize(imageSize)
                .setImageQuality(.normal)
                .build()

            image = PNGImageSource(
                url: prismURL,
                shape: .rounded(4),
                placeholder: getPlaceholder(placeholder)
            )
            return
        }

        image = PNGImageSource(
            url: nil,
            placeholder: getPlaceholder(placeholder)
        )
    }

    private mutating func bindTitle(
        _ asset: CollectibleAsset
    ) {
        title = getTitle(asset)
    }

    private mutating func bindSubtitle(
        _ asset: CollectibleAsset
    ) {
        subtitle = getSubtitle(asset)
    }
}

extension SendCollectibleViewModel {
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
                        .lineBreakMode(.byTruncatingTail),
                        .lineHeightMultiple(lineHeightMultiplier),
                        .textAlignment(.center)
                    ])
                ])
        )
    }
    
    func getSubtitle(
        _ asset: CollectibleAsset
    ) -> EditText? {
        let subtitle = asset.title.fallback(asset.name.fallback(("#\(String(asset.id))")))

        let font = Fonts.DMSans.medium.make(19)
        let lineHeightMultiplier = 1.13

        return .attributedString(
            subtitle
                .attributed([
                    .font(font),
                    .lineHeightMultiplier(lineHeightMultiplier, font),
                    .paragraph([
                        .lineBreakMode(.byWordWrapping),
                        .lineHeightMultiple(lineHeightMultiplier),
                        .textAlignment(.center)
                    ])
                ])
        )
    }

    private func getPlaceholder(
        _ aPlaceholder: String
    ) -> ImagePlaceholder {
        let font = Fonts.DMSans.regular.make(19)
        let lineHeightMultiplier = 1.13

        let placeholderText: EditText = .attributedString(
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

        return ImagePlaceholder(
            image: nil,
            text: placeholderText
        )
    }
}
