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

//   TransactionV2.swift

import Foundation
import MagpieCore
import MacaroonUtils

public final class TransactionV2:
    ALGEntityModel,
    TransactionItem {
    public let id: String?
    public let type: TransactionType
    public let sender: String?
    public let receiver: String?
    public let confirmedRound: String?
    public let date: Date?
    public let swapGroupDetail: SwapGroupDetail?
    public let interpretedMeaning: InterpretedMeaning?
    public let fee: String?
    public let groupId: String?
    public let amount: String?
    public let closeTo: String?
    public let asset: TransactionV2Asset?
    public let applicationId: String?
    
    public init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.id = apiModel.id
        self.type = apiModel.txType.unwrap(TransactionType.init(rawValue:)) ?? .random()
        self.sender = apiModel.sender
        self.receiver = apiModel.receiver
        self.confirmedRound = apiModel.confirmedRound
        self.date = apiModel.roundTime.flatMap(Double.init).map(Date.init(timeIntervalSince1970:))
        self.swapGroupDetail = apiModel.swapGroupDetail
        self.interpretedMeaning = apiModel.interpretedMeaning
        self.fee = apiModel.fee
        self.groupId = apiModel.groupId
        self.amount = apiModel.amount
        self.closeTo = apiModel.closeTo
        self.asset = apiModel.asset
        self.applicationId = apiModel.applicationId
    }

    public func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.id = id
        apiModel.txType = type.rawValue
        apiModel.sender = sender
        apiModel.receiver = receiver
        apiModel.confirmedRound = confirmedRound
        apiModel.roundTime = String(format: "%.0f", date?.timeIntervalSince1970 ?? 0)
        apiModel.swapGroupDetail = swapGroupDetail
        apiModel.interpretedMeaning = interpretedMeaning
        apiModel.fee = fee
        apiModel.groupId = groupId
        apiModel.amount = amount
        apiModel.closeTo = closeTo
        apiModel.asset = asset
        apiModel.applicationId = applicationId
        return apiModel
    }
}

extension TransactionV2 {
    public struct APIModel: ALGAPIModel {
        var id: String?
        var txType: String?
        var sender: String?
        var receiver: String?
        var confirmedRound: String?
        var roundTime: String?
        var swapGroupDetail: SwapGroupDetail?
        var interpretedMeaning: InterpretedMeaning?
        var fee: String?
        var groupId: String?
        var amount: String?
        var closeTo: String?
        var asset: TransactionV2Asset?
        var applicationId: String?

        public init() {
            self.id = nil
            self.txType = nil
            self.sender = nil
            self.receiver = nil
            self.confirmedRound = nil
            self.roundTime = nil
            self.swapGroupDetail = nil
            self.interpretedMeaning = nil
            self.fee = nil
            self.groupId = nil
            self.amount = nil
            self.closeTo = nil
            self.asset = nil
            self.applicationId = nil
        }

        private enum CodingKeys: String, CodingKey {
            case id
            case txType = "tx_type"
            case sender
            case receiver
            case confirmedRound = "confirmed_round"
            case roundTime = "round_time"
            case swapGroupDetail = "swap_group_detail"
            case interpretedMeaning = "interpreted_meaning"
            case fee
            case groupId = "group_id"
            case amount
            case closeTo = "close_to"
            case asset
            case applicationId = "application_id"
        }
    }
}

public final class TransactionV2Asset: ALGAPIModel {
    public let assetId: String?
    public let unitName: String?
    public let fractionDecimals: Int?

    public init() {
        self.assetId = nil
        self.unitName = nil
        self.fractionDecimals = 0
    }
    
    private enum CodingKeys:
        String,
        CodingKey {
        case assetId = "asset_id"
        case unitName = "unit_name"
        case fractionDecimals = "fraction_decimals"
    }
}

public final class SwapGroupDetail: ALGAPIModel {
    public let swapId: String?
    public let provider: String?
    public let status: String?
    public let assetIn: TransactionV2Asset?
    public let assetOut: TransactionV2Asset?
    public let amountInWithSlippage: String?
    public let amountOutWithSlippage: String?
    public let transactionCount: Int?
    public let groupId: String?
    public let confirmedRound: String?
    public let roundTime: String?

    public init() {
        self.swapId = nil
        self.provider = nil
        self.status = nil
        self.assetIn = nil
        self.assetOut = nil
        self.amountInWithSlippage = nil
        self.amountOutWithSlippage = nil
        self.transactionCount = 0
        self.groupId = nil
        self.confirmedRound = nil
        self.roundTime = nil
    }
    
    private enum CodingKeys:
        String,
        CodingKey {
        case swapId = "swap_id"
        case provider
        case status
        case assetIn = "asset_in"
        case assetOut = "asset_out"
        case amountInWithSlippage = "amount_in_with_slippage"
        case amountOutWithSlippage = "amount_out_with_slippage"
        case transactionCount = "transaction_count"
        case groupId = "group_id"
        case confirmedRound = "confirmed_round"
        case roundTime = "round_time"
    }
}

public final class InterpretedMeaning: ALGAPIModel {
    public let property1: String?
    public let property2: String?

    public init() {
        self.property1 = nil
        self.property2 = nil
    }
    
    private enum CodingKeys:
        String,
        CodingKey {
        case property1
        case property2
    }
}
