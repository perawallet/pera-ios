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

//   AlgoInnerTransactionPreviewViewModel.swift

import Foundation
import MacaroonUIKit
import pera_wallet_core

struct AlgoInnerTransactionPreviewViewModel:
    InnerTransactionPreviewViewModel {
    var title: EditText?
    var amountViewModel: TransactionAmountViewModel?
    
    init(
        transaction: TransactionItem,
        account: Account,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        bindTitle(transaction)
        bindAmount(
            transaction: transaction,
            account: account,
            currency: currency,
            currencyFormatter: currencyFormatter
        )
    }
}

extension AlgoInnerTransactionPreviewViewModel {
    private mutating func bindTitle(
        _ transaction: TransactionItem
    ) {
        title = Self.getTitle(
            transaction.sender.shortAddressDisplay
        )
    }

    private mutating func bindAmount(
        transaction: TransactionItem,
        account: Account,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        
        let amount: Decimal? = {
            if let tx = transaction as? Transaction { return tx.payment?.amountForTransaction(includesCloseAmount: true).toAlgos }
            if let tx = transaction as? TransactionV2 { return tx.amountValue}
            return nil
        }()
        
        if transaction.receiver == transaction.sender, let amount {
            amountViewModel = TransactionAmountViewModel(
                .normal(amount: amount),
                currency: currency,
                currencyFormatter: currencyFormatter,
                showAbbreviation: true
            )
            return
        }

        if transaction.receiver == account.address, let amount {
            amountViewModel = TransactionAmountViewModel(
                .positive(amount: amount),
                currency: currency,
                currencyFormatter: currencyFormatter,
                showAbbreviation: true
            )
            return
        }

        if transaction.sender == account.address, let amount {
            amountViewModel = TransactionAmountViewModel(
                .negative(amount: amount),
                currency: currency,
                currencyFormatter: currencyFormatter,
                showAbbreviation: true
            )
            return
        }

        amountViewModel = TransactionAmountViewModel(
            .normal(amount: amount ?? 0),
            currency: currency,
            currencyFormatter: currencyFormatter,
            showAbbreviation: true
        )
    }
}
