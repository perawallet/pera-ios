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
//   AssetPreviewViewModel.swift

import MacaroonUIKit
import UIKit

struct AssetPreviewModel: Hashable {
    let icon: UIImage?
    let verifiedIcon: UIImage?
    let title: String?
    let subtitle: String?
    let primaryAccessory: String?
    let secondaryAccessory: String?
}

struct AssetPreviewViewModel:
    PairedViewModel,
    Hashable {
    private(set) var assetImageViewModel: AssetImageViewModel?
    private(set) var verifiedIcon: UIImage?
    private(set) var title: EditText?
    private(set) var subtitle: EditText?
    private(set) var primaryAccessory: EditText?
    private(set) var secondaryAccessory: EditText?
    private(set) var assetAbbreviatedName: EditText?
    
    init(
        _ model: AssetPreviewModel
    ) {
        bindIcon(model.icon)
        bindVerifiedIcon(model.verifiedIcon)
        bindTitle(model.title)
        bindSubtitle(model.subtitle)
        bindPrimaryAccessory(model.primaryAccessory)
        bindSecondAccessory(model.secondaryAccessory)
        bindAssetAbbreviatedName()
    }
}

extension AssetPreviewViewModel {
    private mutating func bindAssetImageView(_ image: UIImage?) {
        let assetAbbreviationForImage = TextFormatter.assetShortName.format(assetPrimaryTitle?.string)
        
        assetImageViewModel = AssetImageViewModel(
            image: image,
            assetAbbreviationForImage: assetAbbreviationForImage
        )
    }
    
    private mutating func bindVerifiedIcon(_ image: UIImage?) {
        self.verifiedIcon = image
    }
    
    private mutating func bindTitle(_ title: String?) {
        let font = Fonts.DMSans.regular.make(15)
        let lineHeightMultiplier = 1.23
        
        self.title = .attributedString(
            (title.isNilOrEmpty ? "title-unknown".localized : title!)
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
    
    private mutating func bindSubtitle(_ subtitle: String?) {
        guard let subtitle = subtitle else {
            return
        }
        
        let font = Fonts.DMSans.regular.make(13)
        let lineHeightMultiplier = 1.18
        
        self.subtitle = .attributedString(
            subtitle
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
    
    private mutating func bindPrimaryAccessory(_ accessory: String?) {
        guard let accessory = accessory else {
            return
        }
        
        let font = Fonts.DMMono.regular.make(15)
        let lineHeightMultiplier = 1.23
        
        primaryAccessory = .attributedString(
            accessory
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

    private mutating func bindSecondAccessory(_ accessory: String?) {
        guard let accessory = accessory else {
            return
        }
        
        let font = Fonts.DMMono.regular.make(13)
        let lineHeightMultiplier = 1.18
        
        secondaryAccessory = .attributedString(
            accessory
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
        assetAbbreviatedName = .string(
            TextFormatter.assetShortName.format(title?.string)
        )
    }
}
