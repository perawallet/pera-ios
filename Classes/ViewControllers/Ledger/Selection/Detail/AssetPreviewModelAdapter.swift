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

enum AssetPreviewModelAdapter {
    typealias OtherAssetsAdaptee = (assetDetail: AssetDetail, asset: Asset)

    static func adapt(_ adaptee: OtherAssetsAdaptee) -> AssetPreviewModel {
        let assetViewModel = AssetViewModel(assetDetail: adaptee.assetDetail, asset: adaptee.asset)
        return AssetPreviewModel(
            image: nil,
            secondaryImage: assetViewModel.assetDetail?.isVerified ?? false ? img("icon-verified-shield") : nil,
            assetName: assetViewModel.assetDetail?.assetName,
            assetShortName: assetViewModel.assetDetail?.unitName,
            assetValue: assetViewModel.amount,
            secondaryAssetValue: "$6.06"
        )
    }

    static func adapt(_ adaptee: Account) -> AssetPreviewModel {
        let algoAssetViewModel = AlgoAssetViewModel(account: adaptee)
        return AssetPreviewModel(
            image: img("icon-algo-circle-green"),
            secondaryImage: img("icon-verified-shield"),
            assetName: "asset-algos-title".localized,
            assetShortName: "ALGO",
            assetValue: algoAssetViewModel.amount,
            secondaryAssetValue: "$6.06"
        )
    }
}
