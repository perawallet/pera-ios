// Copyright 2024 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   IncomingAsaAssetListItemViewModel.swift

import Foundation
import MacaroonUIKit
import MacaroonURLImage
import Prism
import UIKit

struct IncomingASAAssetListItemViewModel: IncomingASAListItemViewModel {
    private(set) var imageSource: ImageSource?
    private(set) var title: IncominASAListTitleViewModel?
    private(set) var primaryValue: TextProvider?
    private(set) var secondaryValue: TextProvider?

    init(
        item: AssetItem, 
        senders: Senders?,
        totalAmount: UInt64?,
        isCollectible: Bool
    ) {
        bindImageSource(item)
        bindTitle(
            item: item,
            senders: senders,
            isCollectible: isCollectible
        )
        bindPrimaryValue(
            item: item,
            totalAmount: totalAmount
        )
        bindSecondaryValue(
            item: item,
            totalAmount: totalAmount
        )
    }
}

extension IncomingASAAssetListItemViewModel {
    mutating func bindImageSource(
        _ item: AssetItem
    ) {
        let asset = item.asset

        if asset.isAlgo {
            imageSource = AssetImageSource(asset: "icon-algo-circle".uiImage)
            return
        }

        let iconURL: URL?
        let iconShape: ImageShape

        if let collectibleAsset = asset as? CollectibleAsset {
            iconURL = collectibleAsset.thumbnailImage
            iconShape = .rounded(4)
        } else {
            iconURL = asset.logoURL
            iconShape = .circle
        }

        let size = CGSize(width: 40, height: 40)
        let url = PrismURL(baseURL: iconURL)?
            .setExpectedImageSize(size)
            .setImageQuality(.normal)
            .build()

        let placeholder = getPlaceholder(asset)

        imageSource = DefaultURLImageSource(
            url: url,
            shape: iconShape,
            placeholder: placeholder
        )
    }

    mutating func bindTitle(
        item: AssetItem,
        senders: Senders?,
        isCollectible: Bool
    ) {
        title = IncomingASASenderViewModel(
            item.asset,
            senders: senders,
            isCollectible: isCollectible
        )
    }

    mutating func bindPrimaryValue(
        item: AssetItem,
        totalAmount: UInt64?
    ) {
        guard let totalAmount else { return }
        
        let asset = item.asset
        let decimalAmount = totalAmount.assetAmount(fromFraction: asset.decimals)

        let formatter = item.currencyFormatter
        formatter.formattingContext = item.currencyFormattingContext ?? .listItem
        formatter.currency = nil

        let amountText = formatter.format(decimalAmount)
        let unitText =
            asset.naming.unitName.unwrapNonEmptyString() ?? asset.naming.name.unwrapNonEmptyString()
        let text = [amountText, unitText].compound(" ")
        primaryValue = text.bodyMedium(
            alignment: .right,
            lineBreakMode: .byTruncatingTail
        )
    }

    mutating private func bindSecondaryValue(
        item: AssetItem,
        totalAmount: UInt64?
    ) {
        guard let totalAmount else { return }
        
        let asset = item.asset
        let decimalAmount = totalAmount.assetAmount(fromFraction: asset.decimals)

        let formatter = item.currencyFormatter
        formatter.formattingContext = item.currencyFormattingContext ?? .listItem

        do {
            guard let currencyValue = item.currency.primaryValue else {
                secondaryValue = nil
                return
            }

            let rawCurrency = try currencyValue.unwrap()
            let exchanger = CurrencyExchanger(currency: rawCurrency)
            let amount = try exchanger.exchange(
                asset,
                amount: decimalAmount
            )

            formatter.currency = rawCurrency

            let text = formatter.format(amount)
            secondaryValue = text?.footnoteRegular(
                alignment: .right,
                lineBreakMode: .byTruncatingTail
            )
        } catch {
            secondaryValue = nil
        }
    }
}

extension IncomingASAAssetListItemViewModel {
    func getPlaceholder(
        _ asset: Asset
    ) -> ImagePlaceholder? {
        let title = asset.naming.name.isNilOrEmpty
            ? String(localized: "title-unknown")
        : asset.naming.name

        let aPlaceholder = TextFormatter.assetShortName.format(title)

        guard let aPlaceholder = aPlaceholder else {
            return nil
        }

        let isCollectible = asset is CollectibleAsset
        let placeholderImage =
            isCollectible ?
            "placeholder-bg".uiImage :
            "asset-image-placeholder-border".uiImage
        let placeholderText: EditText = .attributedString(
            aPlaceholder
                .footnoteRegular(
                    alignment: .center
                )
        )
        return ImagePlaceholder(
            image: .init(asset: placeholderImage),
            text: placeholderText
        )
    }
}
