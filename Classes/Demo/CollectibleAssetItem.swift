// Copyright 2025 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   CollectibleAssetItem.swift

import Foundation

final class CollectibleAssetItem {
    let account: Account
    let asset: CollectibleAsset
    let amountFormatter: CollectibleAmountFormatter
    let showForIncomingASA: Bool?
    let totalAmount: UInt64?
    init(
        account: Account,
        asset: CollectibleAsset,
        amountFormatter: CollectibleAmountFormatter,
        showForIncomingASA: Bool? = nil,
        totalAmount: UInt64? = nil
    ) {
        self.account = account
        self.asset = asset
        self.amountFormatter = amountFormatter
        self.showForIncomingASA = showForIncomingASA
        self.totalAmount = totalAmount
    }
}
