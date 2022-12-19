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

import Foundation
import UIKit
import MacaroonUIKit
import MacaroonURLImage
import Prism

struct CollectibleListItemViewModel: ViewModel {
    private(set) var image: ImageSource?
    private(set) var overlay: UIImage?
    private(set) var title: EditText?
    private(set) var subtitle: EditText?
    private(set) var topLeftBadgeCanvas: UIImage?
    private(set) var topLeftBadge: UIImage?
    private(set) var bottomLeftBadgeCanvas: UIImage?
    private(set) var bottomLeftBadge: UIImage?
    private(set) var amountCanvas: UIImage?
    private(set) var amount: EditText?
    private(set) var pendingTitle: EditText?

    init<T>(
        imageSize: CGSize,
        model: T
    ) {
        bind(
            imageSize: imageSize,
            model: model
        )
    }
}

extension CollectibleListItemViewModel {
    mutating func bind<T>(
        imageSize: CGSize,
        model: T
    ) {
        if let item = model as? CollectibleAssetItem {
            bindImage(imageSize: imageSize, item: item)
            bindOverlay(item: item)
            bindAmount(item)
            bindTitle(item)
            bindSubtitle(item)
            bindTopLeftBadge(item)
            bindBottomLeftBadge(item)
            return
        }

        if let update = model as? OptInBlockchainUpdate {
            bindIcon(imageSize: imageSize, update: update)
            bindTitle(update)
            bindSubtitle(update)
            bindPendingTitle()
            return
        }

        if let update = model as? OptOutBlockchainUpdate {
            bindIcon(imageSize: imageSize, update: update)
            bindPrimaryTitle(update)
            bindSecondaryTitle(update)
            bindPendingTitle()
            return
        }
    }
}

extension CollectibleListItemViewModel {
    private mutating func bindAmount(
        _ item: CollectibleAssetItem
    ) {
        amount = getAmount(item)

        if amount != nil {
            amountCanvas = "badge-bg".uiImage
        }
    }

    private mutating func bindImage(
        imageSize: CGSize,
        item: CollectibleAssetItem
    ) {
        image = getImage(imageSize: imageSize, asset: item.asset)
    }

    private mutating func bindOverlay(
        item: CollectibleAssetItem
    ) {
        if !item.asset.isOwned {
            overlay = "overlay-bg".uiImage
        }
    }

    private mutating func bindTitle(
        _ item: CollectibleAssetItem
    ) {
        title = getTitle(item.asset)
    }

    private mutating func bindSubtitle(
        _ item: CollectibleAssetItem
    ) {
        subtitle = getSubtitle(item.asset)
    }

    private mutating func bindTopLeftBadge(
        _ item: CollectibleAssetItem
    ) {
        topLeftBadge = getTopLeftBadge(item.asset)

        if topLeftBadge != nil {
            topLeftBadgeCanvas = "badge-bg".uiImage
        }
    }

    private mutating func bindBottomLeftBadge(
        _ item: CollectibleAssetItem
    ) {
        let account = item.account
        let asset = item.asset

        if account.isWatchAccount() {
            bottomLeftBadge = "badge-eye".uiImage
            bottomLeftBadgeCanvas = "badge-bg".uiImage
            return
        }

        if !asset.mediaType.isSupported || !asset.isOwned {
            bottomLeftBadge = "badge-warning".templateImage
            bottomLeftBadgeCanvas = "badge-bg".uiImage
            return
        }
    }

    private mutating func bindPendingTitle() {
        pendingTitle = .attributedString(
            "collectible-list-item-pending-title"
                .localized
                .footnoteBold(lineBreakMode: .byTruncatingTail)
        )
    }
}

extension CollectibleListItemViewModel {
    func getImage(
        imageSize: CGSize,
        asset: CollectibleAsset
    ) -> ImageSource? {
        let placeholder = asset.title.fallback(asset.name.fallback(asset.id.stringWithHashtag))

        if let thumbnailImage = asset.thumbnailImage {
            let prismURL = PrismURL(baseURL: thumbnailImage)
                .setExpectedImageSize(imageSize)
                .build()

            return PNGImageSource(
                url: prismURL,
                shape: .rounded(4),
                placeholder: getPlaceholder(placeholder)
            )
        }

        let imageSource =
        PNGImageSource(
            url: nil,
            placeholder: getPlaceholder(placeholder)
        )

        return imageSource
    }

    func getTitle(
        _ asset: CollectibleAsset
    ) -> EditText? {
        guard let collectionName = asset.collection?.name,
              !collectionName.isEmptyOrBlank else {
            return nil
        }

        return .attributedString(
            collectionName
                .footnoteRegular(lineBreakMode: .byTruncatingTail)
        )
    }

    func getSubtitle(
        _ asset: CollectibleAsset
    ) -> EditText? {
        let subtitle = asset.title.fallback(asset.name.fallback(asset.id.stringWithHashtag))

        return .attributedString(
            subtitle
                .bodyRegular(lineBreakMode: .byTruncatingTail)
        )
    }

    func getTopLeftBadge(
        _ asset: CollectibleAsset
    ) -> UIImage? {
        switch asset.mediaType {
        case .video:
            return "badge-video".uiImage
        case .mixed:
            return "badge-mixed".uiImage
        case .unknown:
            return "badge-unknown".uiImage
        default:
            return nil
        }
    }

    private func getPlaceholder(
        _ aPlaceholder: String
    ) -> ImagePlaceholder {
        let placeholderImage = AssetImageSource(asset: "placeholder-bg".uiImage)
        let placeholderText: EditText = .attributedString(
            aPlaceholder
                .footnoteRegular(
                    alignment: .center
                )
        )

        return ImagePlaceholder(
            image: placeholderImage,
            text: placeholderText
        )
    }
}

extension CollectibleListItemViewModel {
    func getAmount(
        _ item: CollectibleAssetItem
    ) -> EditText? {
        let asset = item.asset

        let shouldShowAmount = !asset.isPure && asset.isOwned

        if !shouldShowAmount {
            return nil
        }

        let unformattedAmount = asset.decimalAmount

        let formatter = item.amountFormatter

        guard let formattedAmount = formatter.format(unformattedAmount) else {
            return nil
        }

        return .attributedString(
            "x\(formattedAmount)"
                .footnoteBold(lineBreakMode: .byTruncatingTail)
        )
    }
}

extension CollectibleListItemViewModel {
    mutating func bindIcon(imageSize: CGSize, update: OptInBlockchainUpdate) {
        let placeholder = update.collectibleAssetTitle ?? update.assetName ?? update.assetID.stringWithHashtag

        if let thumbnailImage = update.collectibleAssetThumbnailImage {
            let prismURL = PrismURL(baseURL: thumbnailImage)
                .setExpectedImageSize(imageSize)
                .build()

            image = PNGImageSource(
                url: prismURL,
                shape: .rounded(4),
                placeholder: getPlaceholder(placeholder)
            )
            return
        }

        let imageSource =
            PNGImageSource(
                url: nil,
                placeholder: getPlaceholder(placeholder)
            )

        image = imageSource
    }

    mutating func bindTitle(_ update: OptInBlockchainUpdate) {
        guard let collectionName = update.collectibleAssetCollectionName.unwrapNonEmptyString() else {
            return
        }

        title = .attributedString(
            collectionName
                .footnoteRegular(lineBreakMode: .byTruncatingTail)
        )
    }

    mutating func bindSubtitle(_ update: OptInBlockchainUpdate) {
        let subtitle = update.collectibleAssetTitle ?? update.assetName ?? update.assetID.stringWithHashtag

        self.subtitle = .attributedString(
            subtitle
                .bodyRegular(lineBreakMode: .byTruncatingTail)
        )
    }
}

extension CollectibleListItemViewModel {
    mutating func bindIcon(imageSize: CGSize, update: OptOutBlockchainUpdate) {
        let placeholder = update.collectibleAssetTitle ?? update.assetName ?? update.assetID.stringWithHashtag

        if let thumbnailImage = update.collectibleAssetThumbnailImage {
            let prismURL = PrismURL(baseURL: thumbnailImage)
                .setExpectedImageSize(imageSize)
                .build()

            image = PNGImageSource(
                url: prismURL,
                shape: .rounded(4),
                placeholder: getPlaceholder(placeholder)
            )
            return
        }

        let imageSource =
            PNGImageSource(
                url: nil,
                placeholder: getPlaceholder(placeholder)
            )

        image = imageSource
    }

    mutating func bindPrimaryTitle(_ update: OptOutBlockchainUpdate) {
        guard let collectionName = update.collectibleAssetCollectionName.unwrapNonEmptyString() else {
            return
        }

        title = .attributedString(
            collectionName
                .footnoteRegular(lineBreakMode: .byTruncatingTail)
        )
    }

    mutating func bindSecondaryTitle(_ update: OptOutBlockchainUpdate) {
        let subtitle = update.collectibleAssetTitle ?? update.assetName ?? update.assetID.stringWithHashtag

        self.subtitle = .attributedString(
            subtitle
                .bodyRegular(lineBreakMode: .byTruncatingTail)
        )
    }
}
