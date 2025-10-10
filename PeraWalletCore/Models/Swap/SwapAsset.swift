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

//   SwapAsset.swift

import Foundation

public final class SwapAsset: ALGEntityModel, Codable {

    public let assetID: AssetID
    public let logo: String?
    public let name: String
    public let unitName: String
    public let total: String
    public let fractionDecimals: Int
    public let verificationTier: String
    public let usdValue: String?

    public init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.assetID = apiModel.assetID
        self.logo = apiModel.logo
        self.name = apiModel.name
        self.unitName = apiModel.unitName
        self.total = apiModel.total
        self.fractionDecimals = apiModel.fractionDecimals
        self.verificationTier = apiModel.verificationTier
        self.usdValue = apiModel.usdValue
    }

    public func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.assetID = assetID
        apiModel.logo = logo
        apiModel.name = name
        apiModel.unitName = unitName
        apiModel.total = total
        apiModel.fractionDecimals = fractionDecimals
        apiModel.verificationTier = verificationTier
        apiModel.usdValue = usdValue
        
        return apiModel
    }
}

extension SwapAsset {
    public struct APIModel: ALGAPIModel {
        var assetID: AssetID
        var logo: String?
        var name: String
        var unitName: String
        var total: String
        var fractionDecimals: Int
        var verificationTier: String
        var usdValue: String?

        public init() {
            self.assetID = 0
            self.logo = nil
            self.name = .empty
            self.unitName = .empty
            self.total = .empty
            self.fractionDecimals = 0
            self.verificationTier = .empty
            self.usdValue = nil
        }
    }
}

extension SwapAsset {
    enum CodingKeys: String, CodingKey {
        case assetID = "asset_id"
        case logo
        case name
        case unitName = "unit_name"
        case total
        case fractionDecimals = "fraction_decimals"
        case verificationTier = "verification_tier"
        case usdValue = "usd_value"
    }
}
