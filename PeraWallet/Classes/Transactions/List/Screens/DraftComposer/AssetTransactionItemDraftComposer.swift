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

//   AssetTransactionItemDraftComposer.swift

import Foundation
import pera_wallet_core

struct AssetTransactionItemDraftComposer: TransactionListItemDraftComposer {
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
        
        let assetId: Int64? = {
            if let tx = transactionItem as? Transaction, let assetTransfer = tx.assetTransfer { return assetTransfer.assetId }
            if let tx = transactionItem as? TransactionV2, let assetId = tx.asset?.assetId { return Int64(assetId) }
            return nil
        }()
        
        let receiverAddress: String? = {
            if let tx = transactionItem as? Transaction, let assetTransfer = tx.assetTransfer { return assetTransfer.receiverAddress }
            if let tx = transactionItem as? TransactionV2 { return tx.receiver }
            return nil
        }()

        var asset: AssetDecoration?
        if let assetId, let anAsset = sharedDataController.assetDetailCollection[assetId] {
            asset = anAsset
        }

        let address = receiverAddress == draft.accountHandle.value.address ? transaction.sender : receiverAddress

        if let contact = contacts.first(where: { contact in
            contact.address == address
        }) {
            transactionItem.contact = contact

            let draft = TransactionViewModelDraft(
                account: draft.accountHandle.value,
                asset: asset,
                transaction: transactionItem,
                contact: contact,
                localAccounts: sharedDataController.sortedAccounts().map { $0.value },
                localAssets: sharedDataController.assetDetailCollection
            )

            return draft
        }

        let draft = TransactionViewModelDraft(
            account: draft.accountHandle.value,
            asset: asset,
            transaction: transaction,
            localAccounts: sharedDataController.sortedAccounts().map { $0.value },
            localAssets: sharedDataController.assetDetailCollection
        )

        return draft
    }
}
