// Copyright 2022-2026 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   PeraSwapAmountDraft.swift

import Foundation
import MagpieCore

public struct PeraSwapAmountDraft: JSONObjectBody {
    public let address: String
    public let assetID: Int64
    public let assetOut: Int64
    public let amount: UInt64?
    public let percentage: String?
    
    public init(address: String, assetID: Int64, assetOut: Int64, amount: UInt64?, percentage: String?) {
        self.address = address
        self.assetID = assetID
        self.assetOut = assetOut
        self.amount = amount
        self.percentage = percentage
    }

    public var bodyParams: [APIBodyParam] {
        var params: [APIBodyParam] = []
        params.append(.init(.address, address))
        params.append(.init(.assetInID, assetID))
        params.append(.init(.assetOutID, assetOut))
        if let percentage {
            params.append(.init(.percentage, percentage))
        } else {
            params.append(.init(.amountInput, amount))
        }
        
        return params
    }
}
