// Copyright 2024 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   IncomingAsasDetailViewModel.swift

import Foundation
import UIKit
import MacaroonUIKit

struct IncomingASAsDetailViewModel: ViewModel {
    private(set) var accountItem: AccountListItemViewModel?
    private(set) var account: Account?
    private(set) var amount: IncomingASARequestHeaderViewModel?
    private(set) var senders: [IncomingASARequesSenderViewModel]?
    private(set) var accountId: TextProvider?
    private(set) var algoGainOnClaim: UInt64?
    private(set) var algoGainOnReject: UInt64?
    private(set) var draft: IncomingASAListItem!
    private(set) var currencyFormatter: CurrencyFormatter!

    init(
        draft: IncomingASAListItem,
        account: Account,
        accountPortfolio: AccountPortfolioItem,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter,
        algoGainOnClaim: UInt64?,
        algoGainOnReject: UInt64?
    ) {
        self.account = account
        self.accountItem = AccountListItemViewModel(accountPortfolio)
        bindSenders(
            draft: draft, 
            currencyFormatter: currencyFormatter
        )
        bindAmount(
            draft: draft,
            currency: currency, 
            currencyFormatter: currencyFormatter
        )
        self.algoGainOnClaim = algoGainOnClaim
        self.algoGainOnReject = algoGainOnReject
        self.draft = draft
        self.accountId = String(draft.asset.id)
        self.currencyFormatter = currencyFormatter
    }
}

extension IncomingASAsDetailViewModel {
    private mutating func bindSenders(
        draft: IncomingASAListItem,
        currencyFormatter: CurrencyFormatter
    ) {
        let senders = draft.senders
        
        guard let results = senders?.results else { return }
        
        self.senders = results.compactMap { sender -> IncomingASARequesSenderViewModel? in
            return IncomingASARequesSenderViewModel(
                currencyFormatter: currencyFormatter,
                asset: draft.asset,
                amount: sender.amount,
                sender: sender.sender
            )
        }
    }
    
    private mutating func bindAmount(
        draft: IncomingASAListItem,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        self.amount = IncomingASARequestHeaderViewModel(
            draft: draft,
            currency: currency,
            currencyFormatter: currencyFormatter
        )
    }
}
