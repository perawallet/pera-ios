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
    static func adapt(_ adaptee: (asset: Asset, currency: Currency?)) -> AssetPreviewModel {
        let assetViewModel = AssetViewModel(asset: adaptee.asset, currency: adaptee.currency)
        return AssetPreviewModel(
            image: nil,
            secondaryImage: adaptee.asset.presentation.isVerified ? img("icon-verified-shield") : nil,
            assetPrimaryTitle: adaptee.asset.presentation.name,
            assetSecondaryTitle: adaptee.asset.presentation.unitName,
            assetPrimaryValue: assetViewModel.amount,
            assetSecondaryValue: assetViewModel.currencyAmount
        )
    }

    static func adapt(_ adaptee: (account: Account, currency: Currency?)) -> AssetPreviewModel {
        let algoAssetViewModel = AlgoAssetViewModel(account: adaptee.account, currency: adaptee.currency)
        return AssetPreviewModel(
            image: img("icon-algo-circle-green"),
            secondaryImage: img("icon-verified-shield"),
            assetPrimaryTitle: "Algo",
            assetSecondaryTitle: "ALGO",
            assetPrimaryValue: algoAssetViewModel.amount,
            assetSecondaryValue: algoAssetViewModel.currencyAmount
        )
    }

    static func adapt(_ asset: Asset) -> AssetPreviewModel {
        return AssetPreviewModel(
            image: nil,
            secondaryImage: asset.presentation.isVerified ? img("icon-verified-shield") : nil,
            assetPrimaryTitle: asset.presentation.name,
            assetSecondaryTitle: asset.presentation.unitName,
            assetPrimaryValue: String(asset.id),
            assetSecondaryValue: nil
        )
    }

    static func adaptAssetSelection(_ adaptee: (asset: Asset, currency: Currency?)) -> AssetPreviewModel {
        let assetViewModel = AssetViewModel(asset: adaptee.asset, currency: adaptee.currency)
        return AssetPreviewModel(
            image: nil,
            secondaryImage: adaptee.asset.presentation.isVerified ? img("icon-verified-shield") : nil,
            assetPrimaryTitle: adaptee.asset.presentation.name,
            assetSecondaryTitle: "ID \(adaptee.asset.id)",
            assetPrimaryValue: assetViewModel.amount,
            assetSecondaryValue: assetViewModel.currencyAmount
        )
    }

    static func adaptPendingAsset(_ asset: StandardAsset) -> PendingAssetPreviewModel {
        let status: String
        switch asset.state {
        case let .pending(operation):
            switch operation {
            case .add:
                status = "asset-add-confirmation-title".localized
            case .remove:
                status = "asset-removing-status".localized
            }
        case .ready:
            status = ""
        }

        return PendingAssetPreviewModel(
            secondaryImage: asset.isVerified ? img("icon-verified-shield") : nil,
            assetPrimaryTitle: asset.name,
            assetSecondaryTitle: "ID \(asset.id)",
            assetStatus: status
        )
    }
}
