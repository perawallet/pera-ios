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
//   WCGroupTransactionItemViewModel.swift

import UIKit

class WCGroupTransactionItemViewModel {
    private(set) var hasWarning = false
    private(set) var title: String?
    private(set) var isAlgos = true
    private(set) var amount: String?
    private(set) var assetName: String?
    private(set) var accountInformationViewModel: WCGroupTransactionAccountInformationViewModel?

    init(transaction: WCTransaction) {
        setHasWarning(from: transaction)
        setTitle(from: transaction)
        setIsAlgos(from: transaction)
        setAmount(from: transaction)
        setAssetName(from: transaction)
        setAccountInformationViewModel(from: transaction)
    }

    private func setHasWarning(from transaction: WCTransaction) {
        guard let transactionDetail = transaction.transactionDetail else {
            return
        }

        hasWarning = transactionDetail.isCloseTransaction || transactionDetail.isRekeyTransaction
    }

    private func setTitle(from transaction: WCTransaction) {
        title = ""
    }

    private func setIsAlgos(from transaction: WCTransaction) {
        guard let transactionDetail = transaction.transactionDetail else {
            return
        }

        isAlgos = transactionDetail.isAlgosTransaction
    }

    private func setAmount(from transaction: WCTransaction) {
        amount = ""
    }

    private func setAssetName(from transaction: WCTransaction) {
        assetName = ""
    }

    private func setAccountInformationViewModel(from transaction: WCTransaction) {
        
    }
}
