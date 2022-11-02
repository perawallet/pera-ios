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

//   DiscoveryASASearchNameListViewModel.swift

import Foundation
import MacaroonUIKit
import MacaroonUtils
import UIKit

struct DiscoveryASASearchNameListViewModel: PrimaryTitleViewModel {
    private(set) var primaryTitle: TextProvider?
    private(set) var primaryTitleAccessory: Image?
    private(set) var secondaryTitle: TextProvider?
    private(set) var accessoryText: TextProvider?

    init(asset: DiscoveryASA) {
        bindPrimaryTitle(asset: asset)
        bindPrimaryTitleAccessory(asset: asset)
        bindSecondaryTitle(asset: asset)
        bindAccessoryText(asset: asset)
    }
}

extension DiscoveryASASearchNameListViewModel {
    mutating func bindPrimaryTitle(asset: DiscoveryASA) {
        let title = asset.name

        var attributes = Typography.bodyRegularAttributes(lineBreakMode: .byTruncatingTail)
        if asset.verificationTier.isSuspicious {
            attributes.insert(.textColor(Colors.Helpers.negative))
        } else {
            attributes.insert(.textColor(Colors.Text.main))
        }

        primaryTitle = title.attributed(attributes)
    }

    mutating func bindPrimaryTitleAccessory(asset: DiscoveryASA) {
        switch asset.verificationTier {
        case .trusted: primaryTitleAccessory = "icon-trusted"
        case .verified: primaryTitleAccessory = "icon-verified"
        case .unverified: primaryTitleAccessory = nil
        case .suspicious: primaryTitleAccessory = "icon-suspicious"
        }
    }

    mutating func bindSecondaryTitle(asset: DiscoveryASA) {
        let title = [
            asset.unitName,
            String(asset.id)
        ].compound(" • ")
        secondaryTitle = title.footnoteRegular(lineBreakMode: .byTruncatingTail)
    }

    mutating func bindAccessoryText(asset: DiscoveryASA) {
        accessoryText = asset.usdValue?.footnoteRegular(lineBreakMode: .byTruncatingTail)
    }
}
