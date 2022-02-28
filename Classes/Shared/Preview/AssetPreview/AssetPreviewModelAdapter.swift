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
//   AssetPreviewModelAdapter.swift

import Foundation
import UIKit

enum AssetPreviewModelAdapter {
    static func adapt(_ adaptee: (assetDetail: AssetInformation, asset: Asset, currency: Currency?)) -> AssetPreviewModel {
        let assetViewModel = AssetViewModel(assetDetail: adaptee.assetDetail, asset: adaptee.asset, currency: adaptee.currency)
        return AssetPreviewModel(
            icon: nil,
            verifiedIcon: assetViewModel.assetDetail?.isVerified ?? false ? img("icon-verified-shield") : nil,
            title: assetViewModel.assetDetail?.name,
            subtitle: assetViewModel.assetDetail?.unitName,
            primaryAccessory: assetViewModel.amount,
            secondaryAccessory: assetViewModel.currencyAmount
        )
    }

    static func adapt(_ adaptee: (account: Account, currency: Currency?)) -> AssetPreviewModel {
        let algoAssetViewModel = AlgoAssetViewModel(account: adaptee.account, currency: adaptee.currency)
        return AssetPreviewModel(
            icon: img("icon-algo-circle-green"),
            verifiedIcon: img("icon-verified-shield"),
            title: "Algo",
            subtitle: "ALGO",
            primaryAccessory: algoAssetViewModel.amount,
            secondaryAccessory: algoAssetViewModel.currencyAmount
        )
    }

    static func adapt(_ adaptee: AssetInformation) -> AssetPreviewModel {
        return AssetPreviewModel(
            icon: nil,
            verifiedIcon: adaptee.isVerified ? img("icon-verified-shield") : nil,
            title: adaptee.name,
            subtitle: adaptee.unitName,
            primaryAccessory: nil,
            secondaryAccessory: String(adaptee.id)
        )
    }

    static func adaptAssetSelection(_ adaptee: (assetDetail: AssetInformation, asset: Asset, currency: Currency?)) -> AssetPreviewModel {
        let assetViewModel = AssetViewModel(assetDetail: adaptee.assetDetail, asset: adaptee.asset, currency: adaptee.currency)
        let assetId = assetViewModel.assetDetail?.id ?? 0
        return AssetPreviewModel(
            icon: nil,
            verifiedIcon: assetViewModel.assetDetail?.isVerified ?? false ? img("icon-verified-shield") : nil,
            title: assetViewModel.assetDetail?.name,
            subtitle: "ID \(assetId)",
            primaryAccessory: assetViewModel.amount,
            secondaryAccessory: assetViewModel.currencyAmount
        )
    }

    static func adaptPendingAsset(_ adaptee: AssetInformation) -> PendingAssetPreviewModel {
        let status = adaptee.isRecentlyAdded ? "asset-add-confirmation-title".localized : "asset-removing-status".localized
        return PendingAssetPreviewModel(
            secondaryImage: adaptee.isVerified ? img("icon-verified-shield") : nil,
            assetPrimaryTitle: adaptee.name,
            assetSecondaryTitle: "ID \(adaptee.id)",
            assetStatus: status
        )
    }
}
