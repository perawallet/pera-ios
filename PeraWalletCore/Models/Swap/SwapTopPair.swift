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

//   SwapTopPair.swift

import Foundation

public final class SwapTopPair: ALGEntityModel, Codable, Identifiable {
    public let assetA: SwapAsset
    public let assetB: SwapAsset
    public let volume24hUSD: String

    public init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.assetA = apiModel.assetA
        self.assetB = apiModel.assetB
        self.volume24hUSD = apiModel.volume24hUSD
    }

    public func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.assetA = assetA
        apiModel.assetB = assetB
        apiModel.volume24hUSD = volume24hUSD
        return apiModel
    }
    
}

extension SwapTopPair {
    public struct APIModel: ALGAPIModel, Codable {
        var assetA: SwapAsset
        var assetB: SwapAsset
        var volume24hUSD: String

        public init() {
            self.assetA = SwapAsset()
            self.assetB = SwapAsset()
            self.volume24hUSD = .empty
        }
        
        enum CodingKeys: String, CodingKey {
            case assetA = "asset_a"
            case assetB = "asset_b"
            case volume24hUSD = "volume_24h_usd"
        }
    }
}

extension SwapTopPair {
    public var title: String {
        String(format: NSLocalizedString("swap-top-pair-text", comment: ""), assetA.name, assetB.name)
    }
    
    public var volumeText: String {
        return "$" + Formatter.numberTextWithSuffix(from: Double(volume24hUSD) ?? 0)
    }
}
