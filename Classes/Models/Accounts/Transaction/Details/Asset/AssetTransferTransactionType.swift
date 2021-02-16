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
//  AssetTransferTransaction.swift

import Magpie

class AssetTransferTransaction: Model {
    let amount: Int64
    let closeAmount: Int64?
    let closeToAddress: String?
    let assetId: Int64
    let receiverAddress: String?
    let senderAddress: String?
}

extension AssetTransferTransaction {
    private enum CodingKeys: String, CodingKey {
        case amount = "amount"
        case closeAmount = "close-amount"
        case closeToAddress = "close-to"
        case assetId = "asset-id"
        case receiverAddress = "receiver"
        case senderAddress = "sender"
    }
}
