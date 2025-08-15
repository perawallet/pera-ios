// Copyright 2022-2025 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   OptOutBlockchainRequest.swift

import Foundation

public struct OptOutBlockchainRequest: BlockchainRequest {
    public let accountAddress: String
    public let assetID: AssetID
    public let assetName: String?
    public let assetUnitName: String?
    public let assetVerificationTier: AssetVerificationTier
    public let isAssetDestroyed: Bool
    public let isCollectibleAsset: Bool
    public let collectibleAssetTitle: String?
    public let collectibleAssetThumbnailImage: URL?
    public let collectibleAssetCollectionName: String?

    public init(
        account: Account,
        asset: AssetDecoration
    ) {
        self.accountAddress = account.address
        self.assetID = asset.id
        self.assetName = asset.name
        self.assetUnitName = asset.unitName
        self.assetVerificationTier = asset.verificationTier
        self.isAssetDestroyed = asset.isDestroyed
        self.isCollectibleAsset = asset.collectible != nil
        self.collectibleAssetTitle = asset.collectible?.title
        self.collectibleAssetThumbnailImage = asset.collectible?.thumbnailImage
        self.collectibleAssetCollectionName = asset.collectible?.collection?.name
    }

    public init(
        account: Account,
        asset: Asset
    ) {
        self.accountAddress = account.address
        self.assetID = asset.id
        self.assetName = asset.naming.name
        self.assetUnitName = asset.naming.unitName
        self.assetVerificationTier = asset.verificationTier
        self.isAssetDestroyed = asset.isDestroyed
        let collectibleAsset = asset as? CollectibleAsset
        self.isCollectibleAsset = collectibleAsset != nil
        self.collectibleAssetTitle = collectibleAsset?.title
        self.collectibleAssetThumbnailImage = collectibleAsset?.thumbnailImage
        self.collectibleAssetCollectionName = collectibleAsset?.collection?.name
    }
}
