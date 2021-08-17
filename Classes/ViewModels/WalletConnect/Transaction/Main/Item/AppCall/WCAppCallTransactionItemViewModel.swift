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
//   WCAppCallTransactionItemViewModel.swift

import Foundation

class WCAppCallTransactionItemViewModel {
    private(set) var hasWarning = false
    private(set) var title: String?

    init(transaction: WCTransaction) {
        setHasWarning(from: transaction)
        setTitle(from: transaction)
    }

    private func setHasWarning(from transaction: WCTransaction) {
        guard let transactionDetail = transaction.transactionDetail else {
            return
        }

        hasWarning = transactionDetail.hasRekeyOrCloseAddress
    }

    private func setTitle(from transaction: WCTransaction) {
        if let appCallId = transaction.transactionDetail?.appCallId {
            title = "wallet-connect-transaction-group-app-call-title".localized(params: "\(appCallId)")
        }
    }
}
