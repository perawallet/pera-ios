// Copyright 2019 Algorand, Inc.

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
//  TransactionParams.swift

import Foundation
import MagpieCore
import MacaroonUtils

final class TransactionParams: ALGResponseModel {
    var debugData: Data?

    let fee: UInt64
    let minFee: UInt64
    let lastRound: UInt64
    let genesisHashData: Data?
    let genesisId: String?

    init(_ apiModel: APIModel = APIModel()) {
        self.fee = apiModel.fee
        self.minFee = apiModel.minFee
        self.lastRound = apiModel.lastRound
        if let genesisHashBase64String = apiModel.genesisHash {
            genesisHashData = Data(base64Encoded: genesisHashBase64String)
        } else {
            genesisHashData = nil
        }
        self.genesisId = apiModel.genesisId
    }
}

extension TransactionParams {
    func getProjectedTransactionFee(from dataSize: Int? = nil) -> UInt64 {
        if let dataSize = dataSize {
            return max(UInt64(dataSize) * fee, Transaction.Constant.minimumFee)
        }
        return max(dataSizeForMaxTransaction * fee, Transaction.Constant.minimumFee)
    }
}

extension TransactionParams {
    struct APIModel: ALGAPIModel {
        let lastRound: UInt64
        let fee: UInt64
        let minFee: UInt64
        let genesisHash: String?
        let genesisId: String?

        init() {
            self.lastRound = 0
            self.fee = 0
            self.minFee = 0
            self.genesisHash = nil
            self.genesisId = nil
        }
    }
}
