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
    public let dateTime: String
    public let transactionGroupId: String
    public let assetIn: SwapAsset
    public let assetOut: SwapAsset
    public let amountIn: String
    public let amountOut: String
    public let amountInUSDValue: String
    public let amountOutUSDValue: String
    
    public init(
        historyId: Int,
        providerId: String,
        status: String,
        dateTime: String,
        transactionGroupId: String,
        assetIn: SwapAsset,
        assetOut: SwapAsset,
        amountIn: String,
        amountOut: String,
        amountInUSDValue: String,
        amountOutUSDValue: String
    ) {
        self.historyId = historyId
        self.providerId = providerId
        self.status = status
        self.dateTime = dateTime
        self.transactionGroupId = transactionGroupId
        self.assetIn = assetIn
        self.assetOut = assetOut
        self.amountIn = amountIn
        self.amountOut = amountOut
        self.amountInUSDValue = amountInUSDValue
        self.amountOutUSDValue = amountOutUSDValue
    }

    public init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.historyId = apiModel.historyId
        self.providerId = apiModel.providerId
        self.status = apiModel.status
        self.dateTime = apiModel.dateTime
        self.transactionGroupId = apiModel.transactionGroupId
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
        apiModel.providerId = providerId
        apiModel.status = status
        apiModel.dateTime = dateTime
        apiModel.transactionGroupId = transactionGroupId
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
        var providerId: String
        var status: String
        var dateTime: String
        var transactionGroupId: String
        var assetIn: SwapAsset
        var assetOut: SwapAsset
        var amountIn: String
        var amountOut: String
        var amountInUSDValue: String
        var amountOutUSDValue: String

        public init() {
            self.historyId = 0
            self.providerId = .empty
            self.status = .empty
            self.dateTime = .empty
            self.transactionGroupId = .empty
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
            case providerId = "provider"
            case status
            case dateTime = "completed_datetime"
            case transactionGroupId = "transaction_group_id"
            case assetIn = "asset_in"
            case assetOut = "asset_out"
            case amountIn = "amount_in"
            case amountOut = "amount_out"
            case amountInUSDValue = "amount_in_usd_value"
            case amountOutUSDValue = "amount_out_usd_value"
        }
    }
}

extension SwapHistory {
    public var title: String {
        String(format: NSLocalizedString("swap-top-pair-text", comment: ""), assetIn.name, assetOut.name)
    }
    
    public var swappedText: String {
        String(format: NSLocalizedString("swapped-for-text", comment: ""), "2,000.00", assetIn.unitName)
    }
    
    public var resultText: String {
        "600.80 \(assetOut.unitName)"
    }
    
    public var dateText: String {
        let isoFormatter = ISO8601DateFormatter()
        guard let date = isoFormatter.date(from: dateTime) else {
            return .empty
        }
        return date.toFormat("MMM d, yyyy")
    }
}
