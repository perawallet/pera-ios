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

//   StandardAsset.swift

import Foundation

final class StandardAsset: Asset {
    let id: AssetID
    let amount: UInt64
    let isFrozen: Bool?
    let isDeleted: Bool?
    let name: String?
    let unitName: String?
    let decimals: Int
    let usdValue: Decimal?
    let isVerified: Bool
    let creator: AssetCreator?

    init(asset: ALGAsset, decoration: AssetDecoration) {
        self.id = asset.id
        self.amount = asset.amount
        self.isFrozen = asset.isFrozen
        self.isDeleted = asset.isDeleted
        self.name = decoration.name
        self.unitName = decoration.unitName
        self.decimals = decoration.decimals
        self.usdValue = decoration.usdValue
        self.isVerified = decoration.isVerified
        self.creator = decoration.creator
    }
}
