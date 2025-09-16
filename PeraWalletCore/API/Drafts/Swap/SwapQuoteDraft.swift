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

//   SwapQuoteDraft.swift

import Foundation
import MagpieCore

public struct SwapQuoteDraft: JSONObjectBody {
    public let providers: [SwapProvider]?
    public let providersV2: [SwapProviderV2]?
    public let swapperAddress: PublicKey
    public let type: SwapType
    public let deviceID: String
    public let assetInID: AssetID
    public let assetOutID: AssetID
    public let amount: UInt64
    public let slippage: Decimal?
    
    public init(providers: [SwapProvider]?, providersV2: [SwapProviderV2]?, swapperAddress: PublicKey, type: SwapType, deviceID: String, assetInID: AssetID, assetOutID: AssetID, amount: UInt64, slippage: Decimal?) {
        self.providers = providers
        self.providersV2 = providersV2
        self.swapperAddress = swapperAddress
        self.type = type
        self.deviceID = deviceID
        self.assetInID = assetInID
        self.assetOutID = assetOutID
        self.amount = amount
        self.slippage = slippage
    }

    public var bodyParams: [APIBodyParam] {
        var params: [APIBodyParam] = []
        if let providers {
            params.append(.init(.providers, providers.map { $0.rawValue }))
        }
        
        if let providersV2 {
            params.append(.init(.providers, providersV2.map { $0.name }))
        }
        
        params.append(.init(.swapperAddress, swapperAddress))
        params.append(.init(.swapType, type))
        params.append(.init(.device, deviceID))
        params.append(.init(.assetInID, assetInID))
        params.append(.init(.assetOutID, assetOutID))
        params.append(.init(.amount, amount))
        params.append(.init(.slippage, slippage, .setIfPresent))
        return params
    }
}
