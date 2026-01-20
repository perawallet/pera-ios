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
    var icon: Image?
    var transactionAmountViewModel: TransactionAmountViewModel?
    let isAssetDetailV2Enabled: Bool

    init(
        _ draft: TransactionViewModelDraft,
        isAssetDetailV2Enabled: Bool
    ) {
        self.isAssetDetailV2Enabled = isAssetDetailV2Enabled
        bindID(draft)
        bindIcon(draft)
        bindTitle(draft)
        bindSubtitle(draft)
        bindInnerTransactions(draft)
    }

    private mutating func bindID(
        _ draft: TransactionViewModelDraft
    ) {
        id = draft.transaction.id
    }
    
    private mutating func bindIcon(
        _ draft: TransactionViewModelDraft
    ) {
        guard draft.transaction is TransactionV2 else { return }
        bindIcon("icon-transaction-list-optin")
    }

    private mutating func bindTitle(
        _ draft: TransactionViewModelDraft
    ) {
        bindTitle(String(localized: "title-app-call"))
    }

    private mutating func bindSubtitle(
        _ draft: TransactionViewModelDraft
    ) {
        if let appId = draft.transaction.appId {
            let appIdText = String(format: String(localized: "transaction-item-app-id-title"), appId)
            bindSubtitle(appIdText)
        }
    }

    private mutating func bindInnerTransactions(
        _ draft: TransactionViewModelDraft
    ) {
        if draft.transaction.allInnerTransactionsCount > 0 {
            transactionAmountViewModel = TransactionAmountViewModel(innerTransactionCount: draft.transaction.allInnerTransactionsCount)
        }
    }
}
