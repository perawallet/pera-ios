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

//   CollectiblePreviewViewModel.swift

import MacaroonUIKit
import UIKit
import Prism
import MacaroonURLImage

struct CollectiblePreviewViewModel:
    BindableViewModel,
    AssetImagePlaceholderViewModel,
    Hashable {
    private(set) var assetID: AssetID?
    private(set) var image: ImageSource?
    private(set) var title: EditText?
    private(set) var subtitle: EditText?
    private(set) var accessory: EditText?
    private(set) var assetAbbreviatedName: EditText?
    private(set) var mediaType: MediaType?

    init<T>(
        _ model: T
    ) {
        bind(model)
    }

    func hash(
        into hasher: inout Hasher
    ) {
        hasher.combine(assetID)
        hasher.combine(title)
        hasher.combine(subtitle)
    }

    static func == (
        lhs: CollectiblePreviewViewModel,
        rhs: CollectiblePreviewViewModel
    ) -> Bool {
        return lhs.assetID == rhs.assetID &&
        lhs.title == rhs.title &&
        lhs.subtitle == rhs.subtitle
    }
}

extension CollectiblePreviewViewModel {
    mutating func bind<T>(
        _ model: T
    ) {
        if let asset = model as? CollectibleAsset {
            bindAssetID(asset)
            bindImage(asset)
            bindTitle(asset)
            bindSubtitle(asset)
            bindAccessory(asset)
            bindAssetAbbreviatedName()
            bindMediaType(asset)
            return
        }
    }
}

extension CollectiblePreviewViewModel {
    private mutating func bindAssetID(
        _ asset: CollectibleAsset
    ) {
        assetID = asset.id
    }

    private mutating func bindImage(
        _ asset: CollectibleAsset
    ) {
        if let thumbnailImage = asset.thumbnailImage {
            let imageSize = CGSize(width: 40, height: 40)
            let prismURL = PrismURL(baseURL: thumbnailImage).setExpectedImageSize(imageSize).setResizeMode(.fit).build()

            image = PNGImageSource(
                url: prismURL,
                size: .resize(imageSize, .aspectFit),
                shape: .rounded(4),
                placeholder: nil
            )
            return
        }
    }

    private mutating func bindTitle(
        _ asset: CollectibleAsset
    ) {
        let name = asset.name

        let font = Fonts.DMSans.regular.make(15)
        let lineHeightMultiplier = 1.23

        self.title = .attributedString(
            (name.isNilOrEmpty ? "title-unknown".localized : name!)
                .attributed([
                    .font(font),
                    .lineHeightMultiplier(lineHeightMultiplier, font),
                    .paragraph([
                        .lineBreakMode(.byTruncatingTail),
                        .lineHeightMultiple(lineHeightMultiplier),
                        .textAlignment(.left)
                    ])
                ])
        )
    }

    private mutating func bindSubtitle(
        _ asset: CollectibleAsset
    ) {
        guard let unitName = asset.unitName else {
            return
        }

        let font = Fonts.DMSans.regular.make(13)
        let lineHeightMultiplier = 1.18

        self.subtitle = .attributedString(
            unitName
                .attributed([
                    .font(font),
                    .lineHeightMultiplier(lineHeightMultiplier, font),
                    .paragraph([
                        .lineBreakMode(.byTruncatingTail),
                        .lineHeightMultiple(lineHeightMultiplier),
                        .textAlignment(.left)
                    ])
                ])
        )
    }

    private mutating func bindAccessory(
        _ asset: CollectibleAsset
    ) {
        let font = Fonts.DMMono.regular.make(13)
        let lineHeightMultiplier = 1.18

        accessory = .attributedString(
            String(asset.id)
                .attributed([
                    .font(font),
                    .lineHeightMultiplier(lineHeightMultiplier, font),
                    .paragraph([
                        .lineBreakMode(.byTruncatingTail),
                        .lineHeightMultiple(lineHeightMultiplier),
                        .textAlignment(.right)
                    ])
                ])
        )
    }

    private mutating func bindAssetAbbreviatedName() {
        assetAbbreviatedName = getAssetAbbreviatedName(
            name: TextFormatter.assetShortName.format(title?.string),
            with: TextAttributes(
                font: Fonts.DMSans.regular.make(13),
                lineHeightMultiplier: 1.18
            )
        )
    }

    private mutating func bindMediaType(
        _ asset: CollectibleAsset
    ) {
        mediaType = asset.mediaType
    }
}
