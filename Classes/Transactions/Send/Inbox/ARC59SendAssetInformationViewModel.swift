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

//   ARC59SendAssetInformationViewModel.swift

import Foundation
import MacaroonUIKit

struct ARC59SendAssetInformationViewModel: SecondaryListItemViewModel {
    var title: TextProvider?
    var accessory: SecondaryListItemValueViewModel?

    init(
        asset: Asset?,
        amount: Decimal?
    ) {
        bindTitle(asset)
        bindAccessory(
            asset: asset,
            amount: amount
        )
    }
}

extension ARC59SendAssetInformationViewModel {
    private mutating func bindTitle(_ asset: Asset?) {
        guard let asset else { return }
        
        var attributes = Typography.bodyRegularAttributes(lineBreakMode: .byTruncatingTail)
        attributes.insert(.textColor(Colors.Text.gray))

        title = (
            asset.naming.unitName.unwrapNonEmptyString() ?? "title-unknown".localized
        ).attributed(attributes)
    }

    private mutating func bindAccessory(
        asset: Asset?,
        amount: Decimal?
    ) {
        guard let asset,
              let amount else {
            return
        }
        
        accessory = ARC59SendAssetInformationItemValueViewModel(
            asset: asset,
            amount: amount
            
        )
    }
}

struct ARC59SendAssetInformationItemValueViewModel: SecondaryListItemValueViewModel {
    var icon: ImageStyle?
    var title: TextProvider?

    init(
        asset: Asset,
        amount: Decimal
    ) {
        bindTitle(
            asset: asset,
            amount: amount
        )
    }
}

extension ARC59SendAssetInformationItemValueViewModel {
    private mutating func bindTitle(
        asset: Asset,
        amount: Decimal
    ) {
        let formatter = CurrencyFormatter()
        formatter.formattingContext = .listItem
        formatter.currency = nil
        guard let amount = formatter.format(amount) else {
            return
        }
        
        let assetName = asset.naming.unitName.unwrapNonEmptyString() ?? "title-unknown".localized
        
        var attributes = Typography.bodyLargeMediumAttributes(
            lineBreakMode: .byTruncatingTail
        )

        attributes.insert(.textColor(Colors.Text.main))
        title = "\(amount) \(assetName)".attributed(attributes)
    }
}
