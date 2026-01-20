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
    public let type: TransactionType?
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
    public let innerTransactionCount: Int?
    public let innerTransactions: [TransactionV2]?
    
    public var status: TransactionStatus? {
        get {
            guard let statusString = swapGroupDetail?.status else { return .completed }
            return TransactionStatus(fromString: statusString)
        }
        set { }
    }
    
    public var allInnerTransactionsCount: Int { innerTransactionCount ?? innerTransactions?.count ?? 0 }
    
    public var contact: Contact?
    
    public var isSelfTransaction: Bool {
        guard let sender, let receiver else { return false }
        return sender == receiver
    }
    
    public var appId: Int64? {
        guard let applicationId else { return nil }
        return Int64(applicationId)
    }
    
    public var swapDetail: String? {
        guard
            let asset,
            let swapGroupDetail,
            let amountInWithSlippage = Double(swapGroupDetail.amountInWithSlippage ?? ""),
            let amountOutWithSlippage = Double(swapGroupDetail.amountOutWithSlippage ?? ""),
            let assetInUnitName = swapGroupDetail.assetIn?.unitName,
            let assetOutUnitName = swapGroupDetail.assetOut?.unitName
        else { return nil}
        
        let fractionDecimals = Double(asset.fractionDecimals ?? 0)
        let amountIn = fractionDecimals > 0 ? amountInWithSlippage / pow(10, fractionDecimals) : amountInWithSlippage
        let amountOut = fractionDecimals > 0 ? amountOutWithSlippage / pow(10, fractionDecimals) : amountInWithSlippage
    
        return String(format: String(localized: "swap-detail-text"), Formatter.numberTextWithSuffix(from: amountIn), assetInUnitName, Formatter.numberTextWithSuffix(from: amountOut), assetOutUnitName)
    }
    
    public var amountValue: Decimal? {
        let fractionDecimals = asset?.fractionDecimals ?? 0
        let rawAmount = swapGroupDetail?.amountInWithSlippage ?? amount
        guard let rawAmount, let amount = Decimal(string: rawAmount) else { return nil }
        return fractionDecimals > 0 ? amount / pow(10, fractionDecimals) : amount
    }
    
    public func isPending() -> Bool {
        if let status = status {
            return status == .pending
        }
        return confirmedRound == nil || confirmedRound == "0"
    }
    
    public func isAssetAdditionTransaction(for address: String) -> Bool {
        guard type == .assetTransfer else {
            return false
        }
        
        return receiver == address && sender == address && UInt64(amount ?? "") == 0
    }
    
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
        self.innerTransactionCount = apiModel.innerTransactionCount
        self.innerTransactions = apiModel.innerTransactions.unwrapMap(TransactionV2.init)
    }

    public func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.id = id
        apiModel.txType = type?.rawValue
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
        apiModel.innerTransactionCount = innerTransactionCount
        apiModel.innerTransactions = innerTransactions.map { $0.encode() }
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
        var innerTransactionCount: Int?
        var innerTransactions: [TransactionV2.APIModel]?

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
            self.innerTransactionCount = 0
            self.innerTransactions = []
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
            case innerTransactionCount = "inner_transaction_count"
            case innerTransactions = "inner_txns"
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
