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

//   AppCallTransactionItemViewModel.swift

import Foundation
import MacaroonUIKit
import pera_wallet_core

struct AppCallTransactionItemViewModel:
    TransactionListItemViewModel,
    Hashable {
    var id: String?
    var title: EditText?
    var subtitle: EditText?
    var transactionAmountViewModel: TransactionAmountViewModel?

    init(
        _ draft: TransactionViewModelDraft
    ) {
        bindID(draft)
        bindTitle(draft)
        bindSubtitle(draft)
        bindInnerTransactions(draft)
    }

    private mutating func bindID(
        _ draft: TransactionViewModelDraft
    ) {
        id = draft.transaction.id
    }

    private mutating func bindTitle(
        _ draft: TransactionViewModelDraft
    ) {
        bindTitle(String(localized: "title-app-call"))
    }

    private mutating func bindSubtitle(
        _ draft: TransactionViewModelDraft
    ) {

        let appID: Int64? = {
            if let tx = draft.transaction as? Transaction, let applicationCall = tx.applicationCall { return applicationCall.appID }
            if let tx = draft.transaction as? TransactionV2, let appId = tx.applicationId { return Int64(appId) }
            return nil
        }()

        if let appID {
            let appId = String(format: String(localized: "transaction-item-app-id-title"), appID)
            bindSubtitle(appId)
        }
    }

    private mutating func bindInnerTransactions(
        _ draft: TransactionViewModelDraft
    ) {
        guard
            let transaction = draft.transaction as? Transaction,
            let innerTransactions = transaction.innerTransactions,
            !innerTransactions.isEmpty
        else {
            return
        }

        transactionAmountViewModel = TransactionAmountViewModel(
            innerTransactionCount: transaction.allInnerTransactionsCount
        )
    }
}
