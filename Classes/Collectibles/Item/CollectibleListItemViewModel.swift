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

struct CollectibleListItemViewModel:
    BindableViewModel,
    Hashable {
    private(set) var assetID: AssetID?
    private(set) var image: ImageSource?
    private(set) var title: EditText?
    private(set) var subtitle: EditText?
    private(set) var bottomLeftBadge: UIImage?

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
        lhs: CollectibleListItemViewModel,
        rhs: CollectibleListItemViewModel
    ) -> Bool {
        return lhs.assetID == rhs.assetID &&
        lhs.title == rhs.title &&
        lhs.subtitle == rhs.subtitle
    }
}

extension CollectibleListItemViewModel {
    mutating func bind<T>(
        _ model: T
    ) {
        if let asset = model as? CollectibleAsset {
            bindAssetID(asset)
            bindImage(asset)
            bindTitle(asset)
            bindSubtitle(asset)
            bindBottomLeftBadge(asset)
            return
        }
    }
}

extension CollectibleListItemViewModel {
    private mutating func bindAssetID(
        _ asset: CollectibleAsset
    ) {
        assetID = asset.id
    }

    private mutating func bindImage(
        _ asset: CollectibleAsset
    ) {
        let placeholder = asset.title.fallback(asset.name.fallback(asset.id.stringWithHashtag))

        if let primaryImage = asset.primaryImage {
            let prismURL = PrismURL(baseURL: primaryImage).build()

            image = PNGImageSource(
                url: prismURL,
                size: .original,
                shape: .rounded(4),
                placeholder: ImagePlaceholder(
                    image: nil,
                    text: getPlaceholder(placeholder)
                )
            )
            return
        }

        let imageSource =
            PNGImageSource(
                url: nil,
                placeholder: ImagePlaceholder(
                    image: nil,
                    text: getPlaceholder(placeholder)
                )
            )

        image = imageSource
    }

    private mutating func bindTitle(
        _ asset: CollectibleAsset
    ) {
        guard let collectionName = asset.collectionName,
              !collectionName.isEmptyOrBlank else {
                  return
              }

        let font = Fonts.DMSans.regular.make(13)
        let lineHeightMultiplier = 1.18
        
        title = .attributedString(
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

    private mutating func bindSubtitle(
        _ asset: CollectibleAsset
    ) {
        let subtitle = asset.title.fallback(asset.name.fallback(asset.id.stringWithHashtag))

        let font = Fonts.DMSans.regular.make(15)
        let lineHeightMultiplier = 1.23

        self.subtitle = .attributedString(
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

    private mutating func bindBottomLeftBadge(
        _ asset: CollectibleAsset
    ) {
        let isNotOwner = asset.amount == 0

        if isNotOwner { /// <note> Not owner of this asset but opted in for it.
            bottomLeftBadge = "badge-warning".uiImage
            return
        }
    }
}

extension CollectibleListItemViewModel {
    mutating func bindBottomLeftBadgeForError() {
        bottomLeftBadge = "badge-error".uiImage
    }
}

extension CollectibleListItemViewModel {
    func getPlaceholder(
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

fileprivate extension AssetID {
    var stringWithHashtag: String {
        "#".appending(String(self))
    }
}

extension Optional where Wrapped == String {
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
