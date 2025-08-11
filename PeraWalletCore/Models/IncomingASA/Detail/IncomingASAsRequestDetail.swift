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

//   IncomingASAsRequestDetail.swift

import Foundation
import MagpieCore
import MacaroonUtils

// MARK: - IncomingASAsRequestDetailListResult
public final class IncomingASAsRequestDetailResult: ALGEntityModel {
    public var totalAmount: UInt64?
    public var asset: AssetDecoration?
    public var senders: Senders?
    public var algoGainOnClaim: UInt64?
    public var algoGainOnReject: UInt64?
    public var shouldUseFundsBeforeClaiming: Bool
    public var hasInsufficientAlgoForClaiming: Bool
    public var shouldUseFundsBeforeRejecting: Bool
    public var hasInsufficientAlgoForRejecting: Bool
    
    // Initializer from APIModel
    public init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.totalAmount = apiModel.totalAmount
        self.asset = apiModel.asset.unwrap(AssetDecoration.init)
        self.senders = apiModel.senders.unwrap(Senders.init)
        self.algoGainOnClaim = apiModel.algoGainOnClaim
        self.algoGainOnReject = apiModel.algoGainOnReject
        self.shouldUseFundsBeforeClaiming = apiModel.shouldUseFundsBeforeClaiming ?? false
        self.hasInsufficientAlgoForClaiming = apiModel.hasInsufficientAlgoForClaiming ?? false
        self.shouldUseFundsBeforeRejecting = apiModel.shouldUseFundsBeforeRejecting ?? false
        self.hasInsufficientAlgoForRejecting = apiModel.hasInsufficientAlgoForRejecting ?? false
    }
    
    // Encode function to convert to APIModel
    public func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.totalAmount = totalAmount
        apiModel.asset = asset?.encode()
        apiModel.senders = senders?.encode()
        apiModel.algoGainOnClaim = algoGainOnClaim
        apiModel.algoGainOnReject = algoGainOnReject
        apiModel.shouldUseFundsBeforeClaiming = shouldUseFundsBeforeClaiming
        apiModel.hasInsufficientAlgoForClaiming = hasInsufficientAlgoForClaiming
        apiModel.shouldUseFundsBeforeRejecting = shouldUseFundsBeforeRejecting
        apiModel.hasInsufficientAlgoForRejecting = hasInsufficientAlgoForRejecting
        return apiModel
    }
}

extension IncomingASAsRequestDetailResult {
    public struct APIModel: ALGAPIModel {
        var totalAmount: UInt64?
        var asset: AssetDecoration.APIModel?
        var senders: Senders.APIModel?
        var algoGainOnClaim: UInt64?
        var algoGainOnReject: UInt64?
        var shouldUseFundsBeforeClaiming: Bool?
        var hasInsufficientAlgoForClaiming: Bool?
        var shouldUseFundsBeforeRejecting: Bool?
        var hasInsufficientAlgoForRejecting: Bool?
        
        public init() {
            self.totalAmount = 0
            self.asset = .init()
            self.senders = .init()
            self.algoGainOnClaim = 0
            self.algoGainOnReject = 0
            self.shouldUseFundsBeforeClaiming = false
            self.hasInsufficientAlgoForClaiming = false
            self.shouldUseFundsBeforeRejecting = false
            self.hasInsufficientAlgoForRejecting = false
        }

        private enum CodingKeys: String, CodingKey {
            case totalAmount = "total_amount"
            case asset
            case senders
            case algoGainOnClaim = "algo_gain_on_claim"
            case algoGainOnReject = "algo_gain_on_reject"
            case shouldUseFundsBeforeClaiming = "should_use_funds_before_claiming"
            case hasInsufficientAlgoForClaiming = "insufficient_algo_for_claiming"
            case shouldUseFundsBeforeRejecting = "should_use_funds_before_rejecting"
            case hasInsufficientAlgoForRejecting = "insufficient_algo_for_rejecting"
        }
    }
}

// MARK: - Senders
public final class Senders: ALGEntityModel {
    public var count: Int?
    public var results: [SendersResult]?

    public init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.count = apiModel.count
        self.results = apiModel.results?.map(SendersResult.init)
    }

    public func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.count = self.count
        apiModel.results = self.results?.map { $0.encode() }
        return apiModel
    }
}

extension Senders {
    public struct APIModel: ALGAPIModel {
        var count: Int?
        var results: [SendersResult.APIModel]?

        public init() {
            self.count = 0
            self.results = []
        }

        private enum CodingKeys: String, CodingKey {
            case count
            case results
        }
    }
}

// MARK: - SendersResult
public final class SendersResult: ALGEntityModel {
    public var sender: Sender?
    public var amount: UInt64?
    
    public init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.sender = apiModel.sender.map(Sender.init)
        self.amount = apiModel.amount
    }

    public func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.sender = self.sender?.encode()
        apiModel.amount = self.amount
        return apiModel
    }
}

extension SendersResult {
    public struct APIModel: ALGAPIModel {
        var sender: Sender.APIModel?
        var amount: UInt64?

        public init() {
            self.sender = .init()
            self.amount = 0
        }

        private enum CodingKeys: String, CodingKey {
            case sender
            case amount
        }
    }
}

// MARK: - Sender
public final class Sender: ALGEntityModel {
    public var address: String?
    public var name: String?

    public init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.address = apiModel.address
        self.name = apiModel.name
    }

    public func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.address = self.address
        apiModel.name = self.name
        return apiModel
    }
}

extension Sender {
    public struct APIModel: ALGAPIModel {
        var address: String?
        var name: String?

        public init() {
            self.address = ""
            self.name = ""
        }

        private enum CodingKeys: String, CodingKey {
            case address
            case name
        }
    }
}
