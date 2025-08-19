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

//   SendPureCollectibleAssetBlockchainRequest.swift

import Foundation

public struct SendPureCollectibleAssetBlockchainRequest: BlockchainRequest {
    public let accountAddress: String
    public let assetID: AssetID
    public let assetName: String?
    public let assetUnitName: String?
    public let assetVerificationTier: AssetVerificationTier
    public let assetTitle: String?
    public let assetThumbnailImage: URL?
    public let assetCollectionName: String?

    public init(
        account: Account,
        asset: CollectibleAsset
    ) {
        self.accountAddress = account.address
        self.assetID = asset.id
        self.assetName = asset.naming.name
        self.assetUnitName = asset.naming.unitName
        self.assetVerificationTier = asset.verificationTier
        self.assetTitle = asset.title
        self.assetThumbnailImage = asset.thumbnailImage
        self.assetCollectionName = asset.collection?.name
    }
}
