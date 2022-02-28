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

//   CollectibleAsset.swift

import Foundation

final class CollectibleAsset: Asset {
    let id: AssetID
    let amount: UInt64
    let isFrozen: Bool?
    let isDeleted: Bool?
    let creator: AssetCreator?
    let name: String?
    let unitName: String?
    let decimals: Int
    let usdValue: Decimal?
    let isVerified: Bool
    let mediaType: MediaType?
    let primaryImage: URL?
    let title: String?
    let collectionName: String?

    var isRemoved = false
    var isRecentlyAdded = false

    init(
        asset: ALGAsset,
        decoration: AssetDecoration
    ) {
        self.id = asset.id
        self.amount = asset.amount
        self.isFrozen = asset.isFrozen
        self.isDeleted = asset.isDeleted
        self.creator = decoration.creator
        self.name = decoration.name
        self.unitName = decoration.unitName
        self.decimals = decoration.decimals
        self.usdValue = decoration.usdValue
        self.isVerified = decoration.isVerified
        self.mediaType = decoration.collectible?.mediaType
        self.primaryImage = decoration.collectible?.primaryImage
        self.title = decoration.collectible?.title
        self.collectionName = decoration.collectible?.collectionName
    }
}

extension CollectibleAsset: Comparable {
    static func == (lhs: CollectibleAsset, rhs: CollectibleAsset) -> Bool {
        return lhs.id == rhs.id &&
            lhs.amount == rhs.amount &&
            lhs.isFrozen == rhs.isFrozen &&
            lhs.isDeleted == rhs.isDeleted &&
            lhs.name == rhs.name &&
            lhs.unitName == rhs.unitName &&
            lhs.decimals == rhs.decimals &&
            lhs.usdValue == rhs.usdValue &&
            lhs.isVerified == rhs.isVerified &&
            lhs.mediaType == rhs.mediaType &&
            lhs.primaryImage == rhs.primaryImage &&
            lhs.title == rhs.title &&
            lhs.collectionName == rhs.collectionName
    }

    static func < (lhs: CollectibleAsset, rhs: CollectibleAsset) -> Bool {
        return lhs.id < rhs.id
    }
}

extension CollectibleAsset {
    func getDisplayNames() -> (String, String?) {
        if let name = name,
           let code = unitName,
           !name.isEmptyOrBlank,
           !code.isEmptyOrBlank {
            return (name, "\(code.uppercased())")
        } else if let name = name,
                  !name.isEmptyOrBlank {
            return (name, nil)
        } else if let code = unitName,
                  !code.isEmptyOrBlank {
            return ("\(code.uppercased())", nil)
        } else {
            return ("title-unknown".localized, nil)
        }
    }
}
