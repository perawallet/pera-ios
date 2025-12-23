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

//   AlgoTransactionItemDraftComposer.swift

import Foundation
import pera_wallet_core

struct AlgoTransactionItemDraftComposer: TransactionListItemDraftComposer {
    let draft: TransactionListing
    private let sharedDataController: SharedDataController
    private let contacts: [Contact]

    init(
        draft: TransactionListing,
        sharedDataController: SharedDataController,
        contacts: [Contact]
    ) {
        self.draft = draft
        self.sharedDataController = sharedDataController
        self.contacts = contacts
    }

    func composeTransactionItemPresentationDraft(
        from transaction: TransactionItem
    ) -> TransactionViewModelDraft? {
        
        var transactionItem = transaction

        let address: String? = {
            if let tx = transactionItem as? Transaction,
               let payment = tx.payment {
                return payment.receiver == draft.accountHandle.value.address
                    ? tx.sender
                    : payment.receiver
            }

            if let tx = transactionItem as? TransactionV2 {
                return tx.receiver == draft.accountHandle.value.address
                    ? tx.sender
                    : tx.receiver
            }

            return nil
        }()

        let contact = address.flatMap { addr in
            contacts.first { $0.address == addr }
        }

        transactionItem.contact = contact

        return TransactionViewModelDraft(
            account: draft.accountHandle.value,
            asset: nil,
            transaction: transactionItem,
            contact: contact,
            localAccounts: sharedDataController.sortedAccounts().map { $0.value },
            localAssets: nil
        )
    }
}
