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

//   OptOutBlockchainUpdate.swift

import Foundation

public struct OptOutBlockchainUpdate: BlockchainUpdate {
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
    public var status: Status
    public let notificationMessage: String

    public init(request: OptOutBlockchainRequest) {
        self.accountAddress = request.accountAddress
        self.assetID = request.assetID
        self.assetName = request.assetName
        self.assetUnitName = request.assetUnitName
        self.assetVerificationTier = request.assetVerificationTier
        self.isAssetDestroyed = request.isAssetDestroyed
        self.isCollectibleAsset = request.isCollectibleAsset
        self.collectibleAssetTitle = request.collectibleAssetTitle
        self.collectibleAssetThumbnailImage = request.collectibleAssetThumbnailImage
        self.collectibleAssetCollectionName = request.collectibleAssetCollectionName
        self.status = .pending

        let name: String
        if request.isCollectibleAsset {
            name = request.collectibleAssetTitle ?? request.assetName ?? String(request.assetID)
        } else {
            name = request.assetName ?? request.assetUnitName ?? String(request.assetID)
        }
        self.notificationMessage = String(format: String(localized: "asset-opt-out-successful-message"), name)
    }

    public init(
        update: OptOutBlockchainUpdate,
        status: Status
    ) {
        self.accountAddress = update.accountAddress
        self.assetID = update.assetID
        self.assetName = update.assetName
        self.assetUnitName = update.assetUnitName
        self.assetVerificationTier = update.assetVerificationTier
        self.isAssetDestroyed = update.isAssetDestroyed
        self.isCollectibleAsset = update.isCollectibleAsset
        self.collectibleAssetTitle = update.collectibleAssetTitle
        self.collectibleAssetThumbnailImage = update.collectibleAssetThumbnailImage
        self.collectibleAssetCollectionName = update.collectibleAssetCollectionName
        self.status = status
        self.notificationMessage = update.notificationMessage
    }
}

extension OptOutBlockchainUpdate {
    public enum Status {
        case pending
        case waitingForNotification
        case completed
    }
}
