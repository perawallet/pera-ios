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
    public let providerId: String
    public let status: String
    public let assetIn: SwapAsset
    public let assetOut: SwapAsset
    
    public init(
        historyId: Int,
        providerId: String,
        status: String,
        assetIn: SwapAsset,
        assetOut: SwapAsset
    ) {
        self.historyId = historyId
        self.providerId = providerId
        self.status = status
        self.assetIn = assetIn
        self.assetOut = assetOut
    }

    public init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.historyId = apiModel.historyId
        self.providerId = apiModel.providerId
        self.status = apiModel.status
        self.assetIn = apiModel.assetIn
        self.assetOut = apiModel.assetOut
    }

    public func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.historyId = historyId
        apiModel.providerId = providerId
        apiModel.status = status
        apiModel.assetIn = assetIn
        apiModel.assetOut = assetOut
        return apiModel
    }
}

extension SwapHistory {
    public struct APIModel: ALGAPIModel {
        var historyId: Int
        var providerId: String
        var status: String
        var assetIn: SwapAsset
        var assetOut: SwapAsset

        public init() {
            self.historyId = 0
            self.providerId = .empty
            self.status = .empty
            self.assetIn = SwapAsset()
            self.assetOut = SwapAsset()
        }

        private enum CodingKeys:
            String,
            CodingKey {
            case historyId = "id"
            case providerId = "provider"
            case status
            case assetIn = "asset_in"
            case assetOut = "asset_out"
        }
    }
}
