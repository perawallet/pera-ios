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

struct AssetPreviewModel {
    let icon: AssetImage
    let verificationTier: AssetVerificationTier
    let title: String?
    let subtitle: String?
    let primaryAccessory: String?
    let secondaryAccessory: String?
    let currencyAmount: Decimal
    let asset: Asset?
}

/// <todo> Use new list item structure
struct AssetPreviewViewModel:
    BindableViewModel,
    Hashable {
    private(set) var assetID: AssetID?
    private(set) var assetImageViewModel: PrimaryImageViewModel?
    private(set) var verificationTierIcon: UIImage?
    private(set) var title: EditText?
    private(set) var subtitle: EditText?
    private(set) var primaryAccessory: EditText?
    private(set) var secondaryAccessory: EditText?

    init<T>(
        _ model: T
    ) {
        bind(model)
    }
}

extension AssetPreviewViewModel {
    mutating func bind<T>(
        _ model: T
    ) {
        if let preview = model as? AssetPreviewModel {
            let titleColor: Color =
            preview.verificationTier.isSuspicious
            ? Colors.Helpers.negative
            : Colors.Text.main

            bindTitle(
                preview.title,
                titleColor: titleColor
            )
            bindAssetImageView(preview.icon)
            bindVerificationTierIcon(preview.verificationTier)
            bindSubtitle(preview.subtitle)
            bindPrimaryAccessory(preview.primaryAccessory)
            bindSecondaryAccessory(preview.secondaryAccessory)
            return
        }

        /// <todo>
        /// We should think about the draft approach. (e.g Create container views for each case.)
        if let collectibleAssetSelectionDraft = model as? CollectibleAssetPreviewSelectionDraft {
            bindAssetID(collectibleAssetSelectionDraft)
            bindVerificationTierIcon(collectibleAssetSelectionDraft)
            bindTitle(collectibleAssetSelectionDraft)
            bindImage(collectibleAssetSelectionDraft)
            bindSubtitle(collectibleAssetSelectionDraft)
            bindPrimaryAccessory(collectibleAssetSelectionDraft)
            bindSecondaryAccessory(collectibleAssetSelectionDraft)
            return
        }
    }
}

extension AssetPreviewViewModel {
    private mutating func bindAssetImageView(
        _ image: AssetImage
    ) {
        assetImageViewModel = AssetImageLargeViewModel(
            image: image
        )
    }
    
    private mutating func bindVerificationTierIcon(
        _ verificationTier: AssetVerificationTier
    ) {
        self.verificationTierIcon = getVerificationTierIcon(verificationTier)
    }
    
    private mutating func bindTitle(
        _ title: String?,
        titleColor: Color
    ) {
        var attributes = Typography.bodyRegularAttributes(lineBreakMode: .byTruncatingTail)
        attributes.insert(.textColor(titleColor))

        let aTitle = title.isNilOrEmpty ? "title-unknown".localized : title!

        self.title = .attributedString(
            aTitle.attributed(attributes)
        )
    }
    
    private mutating func bindSubtitle(_ subtitle: String?) {
        guard let subtitle = subtitle else {
            return
        }

        self.subtitle = .attributedString(
            subtitle
                .footnoteRegular(
                    lineBreakMode: .byTruncatingTail
                )
        )
    }
    
    private mutating func bindPrimaryAccessory(
        _ accessory: String?
    ) {
        guard let accessory = accessory else {
            return
        }

        var attributes = Typography.bodyMonoRegularAttributes(
            alignment: .right,
            lineBreakMode: .byTruncatingTail
        )
        attributes.formUnion([ .textColor(Colors.Text.main) ])

        primaryAccessory = .attributedString(
            accessory
                .attributed(
                    attributes
                )
        )
    }

    private mutating func bindSecondaryAccessory(_ accessory: String?) {
        guard let accessory = accessory else {
            return
        }
        

        var attributes = Typography.footnoteMonoRegularAttributes(
            alignment: .right,
            lineBreakMode: .byTruncatingTail
        )
        attributes.formUnion([ .textColor(Colors.Text.grayLighter) ])
        
        secondaryAccessory = .attributedString(
            accessory
                .attributed(
                    attributes
                )
        )
    }
}

extension AssetPreviewViewModel {
    private mutating func bindAssetID(
        _ asset: CollectibleAsset
    ) {
        assetID = asset.id
    }

    private mutating func bindImage(
        _ asset: CollectibleAsset
    ) {
        bindAssetImageView(
            .url(asset.thumbnailImage, title: asset.name)
        )
    }

    private mutating func bindTitle(
        _ asset: CollectibleAsset
    ) {
        let titleColor: Color =
        asset.verificationTier.isSuspicious
        ? Colors.Helpers.negative
        : Colors.Text.main

        bindTitle(
            asset.name,
            titleColor: titleColor
        )
    }

    private mutating func bindSubtitle(
        _ asset: CollectibleAsset
    ) {
        bindSubtitle(asset.unitName)
    }

    private mutating func bindSecondAccessory(
        _ asset: CollectibleAsset
    ) {
        bindSecondaryAccessory(String(asset.id))
    }
}

extension AssetPreviewViewModel {
    private mutating func bindAssetID(
        _ draft: CollectibleAssetPreviewSelectionDraft
    ) {
        assetID = draft.asset.id
    }

    private mutating func bindVerificationTierIcon(
        _ draft: CollectibleAssetPreviewSelectionDraft
        
    ) {
        self.verificationTierIcon = getVerificationTierIcon(draft.asset.verificationTier)
    }

    private mutating func bindImage(
        _ draft: CollectibleAssetPreviewSelectionDraft
    ) {
        bindAssetImageView(
            .url(draft.asset.thumbnailImage, title: draft.asset.name)
        )
    }

    private mutating func bindTitle(
        _ draft: CollectibleAssetPreviewSelectionDraft
    ) {
        let asset = draft.asset

        let titleColor: Color =
        asset.verificationTier.isSuspicious
        ? Colors.Helpers.negative
        : Colors.Text.main

        bindTitle(
            asset.name,
            titleColor: titleColor
        )
    }

    private mutating func bindSubtitle(
        _ draft: CollectibleAssetPreviewSelectionDraft
    ) {
        bindSubtitle("ID \(draft.asset.id)")
    }

    private mutating func bindPrimaryAccessory(
        _ draft: CollectibleAssetPreviewSelectionDraft
    ) {
        let asset = draft.asset

        let formatter = draft.currencyFormatter
        formatter.formattingContext = draft.currencyFormattingContext ?? .listItem
        formatter.currency = nil

        let amount = formatter.format(asset.amountWithFraction)

        bindPrimaryAccessory(amount)
    }

    private mutating func bindSecondaryAccessory(
        _ draft: CollectibleAssetPreviewSelectionDraft
    ) {
        guard let currencyValue = draft.currency.primaryValue else {
            bindSecondaryAccessory(nil)
            return
        }

        let asset = draft.asset

        do {
            let rawCurrency = try currencyValue.unwrap()

            let exchanger = CurrencyExchanger(currency: rawCurrency)
            let amount = try exchanger.exchange(asset)

            let formatter = draft.currencyFormatter
            formatter.formattingContext = draft.currencyFormattingContext ?? .listItem
            formatter.currency = rawCurrency

            if amount > 0 {
                let value = formatter.format(amount)
                bindSecondaryAccessory(value)
            } else {
                bindSecondaryAccessory(nil)
            }
        } catch {
            bindSecondaryAccessory(nil)
        }
    }

    private func getVerificationTierIcon(
        _ verificationTier: AssetVerificationTier
    ) -> UIImage? {
        switch verificationTier {
        case .trusted: return "icon-trusted".uiImage
        case .verified: return "icon-verified".uiImage
        case .unverified: return nil
        case .suspicious: return "icon-suspicious".uiImage
        }
    }
}

extension AssetPreviewViewModel {
    func hash(
        into hasher: inout Hasher
    ) {
        hasher.combine(assetID)
        hasher.combine(assetImageViewModel?.image)
        hasher.combine(verificationTierIcon)
        hasher.combine(title)
        hasher.combine(subtitle)
        hasher.combine(primaryAccessory)
        hasher.combine(secondaryAccessory)
    }

    static func == (
        lhs: AssetPreviewViewModel,
        rhs: AssetPreviewViewModel
    ) -> Bool {
        return lhs.assetID == rhs.assetID &&
        lhs.assetImageViewModel?.image == rhs.assetImageViewModel?.image &&
        lhs.verificationTierIcon == rhs.verificationTierIcon &&
        lhs.title == rhs.title &&
        lhs.subtitle == rhs.subtitle &&
        lhs.primaryAccessory == rhs.primaryAccessory &&
        lhs.secondaryAccessory == rhs.secondaryAccessory
    }
}

struct CollectibleAssetPreviewSelectionDraft {
    let asset: CollectibleAsset
    let currency: CurrencyProvider
    let currencyFormatter: CurrencyFormatter
    let currencyFormattingContext: CurrencyFormattingContext?

    init(
        asset: CollectibleAsset,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter,
        currencyFormattingContext: CurrencyFormattingContext? = nil
    ) {
        self.asset = asset
        self.currency = currency
        self.currencyFormatter = currencyFormatter
        self.currencyFormattingContext = currencyFormattingContext
    }
}
