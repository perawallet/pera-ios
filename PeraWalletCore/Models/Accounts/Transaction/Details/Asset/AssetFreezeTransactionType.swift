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

//
//  AssetFreezeTransaction.swift

import Foundation
import MagpieCore
import MacaroonUtils

public final class AssetFreezeTransaction: ALGAPIModel {
    public let address: String?
    public let isFreeze: Bool?
    public let assetId: Int64?

    public init() {
        self.address = nil
        self.isFreeze = nil
        self.assetId = nil
    }
}

extension AssetFreezeTransaction {
    private enum CodingKeys:
        String,
        CodingKey {
        case address
        case isFreeze = "new-freeze-status"
        case assetId = "asset-id"
    }
}
