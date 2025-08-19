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

//
//  Payment.swift

import Foundation
import MagpieCore
import MacaroonUtils

public final class Payment: ALGEntityModel {
    public let amount: UInt64
    public let receiver: String
    public let closeAmount: UInt64?
    public let closeAddress: String?

    public init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.amount = apiModel.amount ?? 0
        self.receiver = apiModel.receiver.someString
        self.closeAmount = apiModel.closeAmount
        self.closeAddress = apiModel.closeRemainderTo
    }

    public func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.amount = amount
        apiModel.receiver = receiver
        apiModel.closeAmount = closeAmount
        apiModel.closeRemainderTo = closeAddress
        return apiModel
    }
}

extension Payment {
    public func amountForTransaction(includesCloseAmount: Bool) -> UInt64 {
        if let closeAmount = closeAmount, closeAmount != 0, includesCloseAmount {
            return closeAmount + amount
        }
        return amount
    }

    public func closeAmountForTransaction() -> UInt64? {
        guard let closeAmount = closeAmount, closeAmount != 0 else {
            return nil
        }

        return closeAmount
    }
}

extension Payment {
    public struct APIModel: ALGAPIModel {
        var amount: UInt64?
        var receiver: String?
        var closeAmount: UInt64?
        var closeRemainderTo: String?

        public init() {
            self.amount = nil
            self.receiver = nil
            self.closeAmount = nil
            self.closeRemainderTo = nil
        }
    }
}

extension Payment.APIModel {
    private enum CodingKeys: String, CodingKey {
        case amount = "amount"
        case receiver = "receiver"
        case closeAmount = "close-amount"
        case closeRemainderTo = "close-remainder-to"
    }
}
