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

<<<<<<<< HEAD:PeraWalletCore/LiquidAuth/Data/LiquidAuthRequest.swift
public struct LiquidAuthRequest {
    public let origin: String
    public let requestId: String
========
//   AssetInboxSendDraft.swift

import Foundation

public struct AssetInboxSendDraft {
    public let account: String
    public let assetID: AssetID
    
    public init(account: String, assetID: AssetID) {
        self.account = account
        self.assetID = assetID
    }
>>>>>>>> main:PeraWalletCore/API/Drafts/Account/Asset/AssetInboxSendDraft.swift
}
