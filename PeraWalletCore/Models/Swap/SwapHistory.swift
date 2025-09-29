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

//   SwapHistory.swift

import Foundation

public final class SwapHistory: ALGEntityModel, Codable {
    public let historyId: Int
    public let proviverId: String
    public let status: String
    public let assetIn: SwapAsset
    public let assetOut: SwapAsset
    public let amountIn: String
    public let amountOut: String
    public let amountInUSDValue: String
    public let amountOutUSDValue: String

    public init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.historyId = apiModel.historyId
        self.proviverId = apiModel.proviverId
        self.status = apiModel.status
        self.assetIn = apiModel.assetIn
        self.assetOut = apiModel.assetOut
        self.amountIn = apiModel.amountIn
        self.amountOut = apiModel.amountOut
        self.amountInUSDValue = apiModel.amountInUSDValue
        self.amountOutUSDValue = apiModel.amountOutUSDValue
    }

    public func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.historyId = historyId
        apiModel.proviverId = proviverId
        apiModel.status = status
        apiModel.assetIn = assetIn
        apiModel.assetOut = assetOut
        apiModel.amountIn = amountIn
        apiModel.amountOut = amountOut
        apiModel.amountInUSDValue = amountInUSDValue
        apiModel.amountOutUSDValue = amountOutUSDValue
        return apiModel
    }
}

extension SwapHistory {
    public struct APIModel: ALGAPIModel {
        var historyId: Int
        var proviverId: String
        var status: String
        var assetIn: SwapAsset
        var assetOut: SwapAsset
        var amountIn: String
        var amountOut: String
        var amountInUSDValue: String
        var amountOutUSDValue: String

        public init() {
            self.historyId = 0
            self.proviverId = .empty
            self.status = .empty
            self.assetIn = SwapAsset()
            self.assetOut = SwapAsset()
            self.amountIn = .empty
            self.amountOut = .empty
            self.amountInUSDValue = .empty
            self.amountOutUSDValue = .empty
        }

        private enum CodingKeys:
            String,
            CodingKey {
            case historyId = "id"
            case proviverId = "provider"
            case status
            case assetIn = "asset_in"
            case assetOut = "asset_out"
            case amountIn = "amount_in"
            case amountOut = "amount_out"
            case amountInUSDValue = "amount_in_usd_value"
            case amountOutUSDValue = "amount_out_usd_value"
        }
    }
}
