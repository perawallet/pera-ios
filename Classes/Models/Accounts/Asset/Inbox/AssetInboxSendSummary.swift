// Copyright 2024 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   AssetInboxSendSummary.swift

import Foundation

final class AssetInboxSendSummary: ALGEntityModel {
    let isOptedInToProtocol: Bool
    let minBalanceAmount: UInt64
    let innerTransactionCount: Int
    let totalProtocolFee: UInt64
    let inboxAddress: String?
    let algoFundAmount: UInt64
    let warningMessage: AssetInboxSendSummaryWarningMessage?
    
    init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.isOptedInToProtocol = apiModel.isArc59OptedIn ?? false
        self.minBalanceAmount = apiModel.minimumBalanceRequirement ?? 1000
        self.innerTransactionCount = apiModel.innerTxCount ?? 0
        self.totalProtocolFee = apiModel.totalProtocolAndMbrFee ?? 1000
        self.inboxAddress = apiModel.inboxAddress
        self.algoFundAmount = apiModel.algoFundAmount ?? 0
        self.warningMessage = apiModel.warningMessage
    }

    func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.isArc59OptedIn = isOptedInToProtocol
        apiModel.minimumBalanceRequirement = minBalanceAmount
        apiModel.innerTxCount = innerTransactionCount
        apiModel.totalProtocolAndMbrFee = totalProtocolFee
        apiModel.inboxAddress = inboxAddress
        apiModel.algoFundAmount = algoFundAmount
        apiModel.warningMessage = warningMessage
        return apiModel
    }
}

extension AssetInboxSendSummary {
    struct APIModel: ALGAPIModel {
        var isArc59OptedIn: Bool?
        var minimumBalanceRequirement: UInt64?
        var innerTxCount: Int?
        var totalProtocolAndMbrFee: UInt64?
        var inboxAddress: String?
        var algoFundAmount: UInt64?
        var warningMessage: AssetInboxSendSummaryWarningMessage?

        init() {
            self.isArc59OptedIn = false
            self.minimumBalanceRequirement = 0
            self.innerTxCount = 0
            self.totalProtocolAndMbrFee = 0
            self.inboxAddress = nil
            self.algoFundAmount = 0
            self.warningMessage = nil
        }

        private enum CodingKeys:
            String,
            CodingKey {
            case isArc59OptedIn = "is_arc59_opted_in"
            case minimumBalanceRequirement = "minimum_balance_requirement"
            case innerTxCount = "inner_tx_count"
            case totalProtocolAndMbrFee = "total_protocol_and_mbr_fee"
            case inboxAddress = "inbox_address"
            case algoFundAmount = "algo_fund_amount"
            case warningMessage = "warning_message"
        }
    }
}
