// Copyright 2019 Algorand, Inc.

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
    static func adapt(_ adaptee: (assetDetail: AssetDetail, asset: Asset)) -> AssetPreviewModel {
        let assetViewModel = AssetViewModel(assetDetail: adaptee.assetDetail, asset: adaptee.asset)
        return AssetPreviewModel(
            image: nil,
            secondaryImage: assetViewModel.assetDetail?.isVerified ?? false ? img("icon-verified-shield") : nil,
            assetPrimaryTitle: assetViewModel.assetDetail?.assetName,
            assetSecondaryTitle: assetViewModel.assetDetail?.unitName,
            assetPrimaryValue: assetViewModel.amount,
            assetSecondaryValue: nil
        )
    }

    static func adapt(_ adaptee: Account) -> AssetPreviewModel {
        let algoAssetViewModel = AlgoAssetViewModel(account: adaptee)
        return AssetPreviewModel(
            image: img("icon-algo-circle-green"),
            secondaryImage: img("icon-verified-shield"),
            assetPrimaryTitle: "asset-algos-title".localized,
            assetSecondaryTitle: "Algorand",
            assetPrimaryValue: algoAssetViewModel.amount,
            assetSecondaryValue: nil
        )
    }

    static func adapt(_ adaptee: AssetDetail) -> AssetPreviewModel {
        return AssetPreviewModel(
            image: nil,
            secondaryImage: adaptee.isVerified ? img("icon-verified-shield") : nil,
            assetPrimaryTitle: adaptee.assetName,
            assetSecondaryTitle: adaptee.unitName,
            assetPrimaryValue: String(adaptee.id),
            assetSecondaryValue: nil
        )
    }

    static func adaptAssetSelection(_ adaptee: (assetDetail: AssetDetail, asset: Asset)) -> AssetPreviewModel {
        let assetViewModel = AssetViewModel(assetDetail: adaptee.assetDetail, asset: adaptee.asset)
        let assetId = assetViewModel.assetDetail?.id ?? 0
        return AssetPreviewModel(
            image: nil,
            secondaryImage: assetViewModel.assetDetail?.isVerified ?? false ? img("icon-verified-shield") : nil,
            assetPrimaryTitle: assetViewModel.assetDetail?.assetName,
            assetSecondaryTitle: "ID \(assetId)",
            assetPrimaryValue: assetViewModel.amount,
            assetSecondaryValue: nil
        )
    }
}
