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
//  AssetAlertDraft.swift

import Foundation

public struct AssetAlertDraft {
    public let account: Account?
    public let assetId: Int64
    public var asset: AssetDecoration?
    public let transactionFee: UInt64?
    public let title: String?
    public let detail: String?
    public let actionTitle: String?
    public let cancelTitle: String?
    
    public init(
        account: Account?,
        assetId: Int64,
        asset: AssetDecoration?,
        transactionFee: UInt64? = nil,
        title: String? = nil,
        detail: String? = nil,
        actionTitle: String? = nil,
        cancelTitle: String? = nil
    ) {
        self.account = account
        self.assetId = assetId
        self.asset = asset
        self.transactionFee = transactionFee
        self.title = title
        self.detail = detail
        self.actionTitle = actionTitle
        self.cancelTitle = cancelTitle
    }
    
    public var hasValidAsset: Bool {
        return asset != nil
    }
}
