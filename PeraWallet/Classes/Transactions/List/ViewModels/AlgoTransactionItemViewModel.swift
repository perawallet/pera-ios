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

//   AlgoTransactionItemViewModel.swift

import Foundation
import MacaroonUIKit
import pera_wallet_core

struct AlgoTransactionItemViewModel:
    TransactionListItemViewModel,
    Hashable {
    let isAmountHidden: Bool
    var id: String?
    var title: EditText?
    var subtitle: EditText?
    var icon: Image?
    var transactionAmountViewModel: TransactionAmountViewModel?
    
    init(
        _ draft: TransactionViewModelDraft,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter,
        isAmountHidden: Bool
    ) {
        self.isAmountHidden = isAmountHidden
        bindID(draft)
        bindTitle(draft)
        bindSubtitle(draft)
        bindIcon(draft)
        bindAmount(
            draft,
            currency: currency,
            currencyFormatter: currencyFormatter
        )
    }
    
    private mutating func bindID(
        _ draft: TransactionViewModelDraft
    ) {
        id = draft.transaction.id
    }
    
    private mutating func bindTitle(
        _ draft: TransactionViewModelDraft
    ) {
        guard let receiver = draft.transaction.receiver else { return }
        
        if let tx = draft.transaction as? TransactionV2, tx.swapGroupDetail != nil {
            bindTitle(String(localized: "title-swap"))
            return
        }
        
        if draft.transaction.sender == draft.account.address, draft.transaction.isSelfTransaction {
            bindTitle(String(localized: "transaction-item-self-transfer"))
            return
        }
        
        if isReceivingTransaction(draft, for: receiver) {
            bindTitle(String(localized: "transaction-detail-receive"))
            return
        }
        
        bindTitle(String(localized: "transaction-detail-send"))
    }
    
    private mutating func bindSubtitle(
        _ draft: TransactionViewModelDraft
    ) {
        guard let receiver = draft.transaction.receiver else { return }
        
        if let tx = draft.transaction as? TransactionV2, let swapDetail = tx.swapDetail {
            bindSubtitle(swapDetail)
            return
        }
        
        if draft.transaction.isSelfTransaction {
            subtitle = nil
            return
        }
        
        let address = isReceivingTransaction(draft, for: receiver)
        ? draft.transaction.sender
        : receiver
        
        bindSubtitle(getSubtitle(from: draft, for: address))
    }
    
    private mutating func bindIcon(
        _ draft: TransactionViewModelDraft
    ) {
        guard let tx = draft.transaction as? TransactionV2 else { return }
        
        if tx.swapGroupDetail != nil {
            bindIcon("icon-transaction-list-swap")
            return
        }
        
        if let receiver = tx.receiver, isReceivingTransaction(draft, for: receiver) {
            bindIcon("icon-transaction-list-receive")
            return
        }
        
        if let sender = tx.sender, isSendingTransaction(draft, for: sender) {
            bindIcon("icon-transaction-list-send")
            return
        }
        
        bindIcon("icon-transaction-list-optin")
    }
    
    private mutating func bindAmount(
        _ draft: TransactionViewModelDraft,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        guard let receiver = draft.transaction.receiver else { return }
        
        let amount: Decimal? = {
            if let tx = draft.transaction as? Transaction, let payment = tx.payment { return payment.amountForTransaction(includesCloseAmount: true).toAlgos }
            if let tx = draft.transaction as? TransactionV2, let amount = tx.amount { return Decimal(string: amount) }
            
            return nil
        }()
        
        guard let amount else { return }
        currencyFormatter.isValueHidden = isAmountHidden
        
        let style: TransactionAmountView.Mode
        if receiver == draft.transaction.sender || isAmountHidden {
            style = .normal(amount: amount)
        } else if receiver == draft.account.address {
            style = .positive(amount: amount, hideSign: draft.transaction is TransactionV2)
        } else {
            style = .negative(amount: amount)
        }
        
        transactionAmountViewModel = TransactionAmountViewModel(
            style,
            currency: currency,
            currencyFormatter: currencyFormatter,
            showAbbreviation: true
        )
    }
    
    private func isReceivingTransaction(
        _ draft: TransactionViewModelDraft,
        for receiver: String
    ) -> Bool {
        return draft.account.address == receiver
    }
    
    private func isSendingTransaction(
        _ draft: TransactionViewModelDraft,
        for sender: String
    ) -> Bool {
        return draft.account.address == sender
    }
}
