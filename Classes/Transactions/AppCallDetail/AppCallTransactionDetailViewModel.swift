// Copyright 2022 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   AppCallTransactionDetailViewModel.swift

import UIKit
import MacaroonUIKit

final class AppCallTransactionDetailViewModel: ViewModel {
    private(set) var sender: String?
    private(set) var applicationID: String?
    private(set) var onCompletion: String?
    private(set) var assetInformationViewModel: WCAssetInformationViewModel?
    private(set) var fee: TransactionAmountView.Mode?
    private(set) var note: String?
    private(set) var noteViewIsHidden: Bool = false
    private(set) var innerTransactionsViewModel: TransactionAmountInformationViewModel?

    init(
        transaction: Transaction,
        account: Account,
        assetDetail: StandardAsset?
    ) {
        bindSender(account)
        bindApplicationID(transaction)
        bindAsset(assetDetail)
        bindOnCompletion(transaction)
        bindFee(transaction)
        bindInnerTransactionsViewModel(transaction)
        bindNote(transaction)
    }
}

extension AppCallTransactionDetailViewModel {
    private func bindSender(
        _ account: Account
    ) {
        sender = account.address.shortAddressDisplay
    }

    private func bindApplicationID(
        _ transaction: Transaction
    ) {
        if let appID = transaction.applicationCall?.appID {
            applicationID  = "#\(appID)"
        }
    }

    private func bindAsset(
        _ assetDetail: StandardAsset?
    ) {
        if let assetDetail = assetDetail {
            assetInformationViewModel = WCAssetInformationViewModel(
                title: "asset-title".localized,
                asset: assetDetail
            )
        }
    }

    private func bindOnCompletion(
        _ transaction: Transaction
    ) {
        onCompletion = transaction.applicationCall?.onCompletion?.uiRepresentation
    }

    private func bindFee(
        _ transaction: Transaction
    ) {
        if let fee = transaction.fee {
            self.fee = .normal(amount: fee.toAlgos)
        }
    }

    private func bindNote(
        _ transaction: Transaction
    ) {
        if let note = transaction.noteRepresentation() {
            self.note = note
            return
        }

        noteViewIsHidden = true
    }

    private func bindInnerTransactionsViewModel(
        _ transaction: Transaction
    ) {
        if let innerTransactions = transaction.innerTransactions,
           !innerTransactions.isEmpty {

            let amountViewModel = TransactionAmountViewModel(
                innerTransactionCount: innerTransactions.count,
                showInList: false
            )

            innerTransactionsViewModel = TransactionAmountInformationViewModel(
                transactionViewModel: amountViewModel
            )
        }
    }
}
