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

//   AppCallTransactionDetailViewModel.swift

import UIKit
import MacaroonUIKit
import pera_wallet_core

final class AppCallTransactionDetailViewModel: ViewModel {
    private(set) var sender: String?
    private(set) var applicationID: String?
    private(set) var onCompletion: String?
    private(set) var rejectVersion: String?
    private(set) var rejectVersionViewIsHidden: Bool = false
    private(set) var accessList: String?
    private(set) var accessViewIsHidden: Bool = false
    private(set) var transactionAssetInformationViewModel: AppCallTransactionAssetInformationViewModel?
    private(set) var fee: TransactionAmountView.Mode?
    private(set) var transactionIDTitle: String?
    private(set) var transactionID: String?
    private(set) var note: String?
    private(set) var noteViewIsHidden: Bool = false
    private(set) var innerTransactionsViewModel: TransactionAmountInformationViewModel?

    init(
        transaction: TransactionItem,
        account: Account,
        assets: [Asset]?
    ) {
        bindSender(
            transaction: transaction,
            account: account
        )
        bindApplicationID(transaction)
        bindAssets(assets)
        bindOnCompletion(transaction)
        bindRejectVersion(transaction)
        bindAccessList(transaction)
        bindFee(transaction)
        bindInnerTransactionsViewModel(transaction)
        bindTransactionIDTitle(transaction)
        bindTransactionID(transaction)
        bindNote(transaction)
    }
}

extension AppCallTransactionDetailViewModel {
    private func bindSender(
        transaction: TransactionItem,
        account: Account
    ) {
        let senderAddress = transaction.sender
        let accountAddress = account.address

        if senderAddress == accountAddress {
            sender = account.primaryDisplayName
            return
        }

        sender = senderAddress
    }

    private func bindApplicationID(
        _ transaction: TransactionItem
    ) {
        if let appID = transaction.appId {
            applicationID  = "#\(appID)"
        } else if let tx = transaction as? TransactionV2, let appID = tx.applicationTransactionDetail?.applicationId {
            applicationID  = "#\(appID)"
        }
    }

    private func bindAssets(
        _ assets: [Asset]?
    ) {
        if let assets = assets,
           !assets.isEmpty {
            transactionAssetInformationViewModel = AppCallTransactionAssetInformationViewModel(
                assets: assets
            )
        }
    }

    private func bindOnCompletion(
        _ transaction: TransactionItem
    ) {
        if let tx = transaction as? Transaction {
            onCompletion = tx.applicationCall?.onCompletion?.uiRepresentation
        }
        
        if let tx = transaction as? TransactionV2, let onCompletion = tx.applicationTransactionDetail?.onCompletion {
            self.onCompletion = onCompletion
        }
    }
    
    private func bindRejectVersion(
        _ transaction: TransactionItem
    ) {
        if let tx = transaction as? Transaction, let aprv = tx.applicationCall?.aprv {
            self.rejectVersion = "\(aprv)"
        } else {
            rejectVersionViewIsHidden = true
        }
    }
    
    private func bindAccessList(
        _ transaction: TransactionItem
    ) {
        if let tx = transaction as? Transaction, let al = tx.applicationCall?.al {
            self.accessList = "\(String(localized: "count-number-title")) \(al.count)"
        } else {
            accessViewIsHidden = true
        }
    }

    private func bindFee(
        _ transaction: TransactionItem
    ) {
        let fee: UInt64? = {
            if let tx = transaction as? Transaction { return tx.fee }
            if let tx = transaction as? TransactionV2, let fee = tx.fee { return UInt64(fee) }
            return nil
        }()
        
        if let fee {
            self.fee = .normal(amount: fee.toAlgos)
        }
    }

    private func bindTransactionIDTitle(
        _ transaction: TransactionItem
    ) {
        let isParentID: Bool = {
            if let tx = transaction as? Transaction { return tx.isInner }
            if let tx = transaction as? TransactionV2 { return tx.parentId != nil }
            return false
        }()

        transactionIDTitle = String(
            localized: isParentID
                ? "transaction-detail-parent-id"
                : "transaction-detail-id"
        )
    }

    private func bindTransactionID(
        _ transaction: TransactionItem
    ) {
        let transactionId: String? = {
            if let tx = transaction as? Transaction { return tx.id ?? tx.parentID}
            if let tx = transaction as? TransactionV2 { return tx.parentId ?? tx.id }
            return nil
        }()
        
        transactionID = transactionId
    }

    private func bindNote(
        _ transaction: TransactionItem
    ) {
        if let note = transaction.noteRepresentation {
            self.note = note
            return
        }

        noteViewIsHidden = true
    }

    private func bindInnerTransactionsViewModel(
        _ transaction: TransactionItem
    ) {
        if transaction.allInnerTransactionsCount > 0 {
            let amountViewModel = TransactionAmountViewModel(
                innerTransactionCount: transaction.allInnerTransactionsCount,
                showInList: false
            )
            
            innerTransactionsViewModel = TransactionAmountInformationViewModel(
                transactionViewModel: amountViewModel
            )
        }
    }
}
