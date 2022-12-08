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

//   OptInBlockchainRequest.swift

import Foundation

struct OptInBlockchainRequest: BlockchainRequest {
    let accountAddress: String
    let assetID: AssetID
    let assetName: String?
    let assetUnitName: String?
    let assetVerificationTier: AssetVerificationTier
    let isCollectibleAsset: Bool
    let collectibleAssetTitle: String?

    init(
        account: Account,
        asset: AssetDecoration
    ) {
        self.accountAddress = account.address
        self.assetID = asset.id
        self.assetName = asset.name
        self.assetUnitName = asset.unitName
        self.assetVerificationTier = asset.verificationTier
        self.isCollectibleAsset = asset.collectible != nil
        self.collectibleAssetTitle = asset.collectible?.title
    }

    init(
        account: Account,
        asset: Asset
    ) {
        self.accountAddress = account.address
        self.assetID = asset.id
        self.assetName = asset.naming.name
        self.assetUnitName = asset.naming.unitName
        self.assetVerificationTier = asset.verificationTier
        let collectibleAsset = asset as? CollectibleAsset
        self.isCollectibleAsset = collectibleAsset != nil
        self.collectibleAssetTitle = collectibleAsset?.title
    }
}
