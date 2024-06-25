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

//   IncomingASADetailHeaderViewModel.swift

import Foundation
import MacaroonUIKit
import MacaroonURLImage

struct IncomingASADetailHeaderViewModel: ViewModel {
    
    private(set) var accountItem: AccountListItemViewModel?
    private(set) var accountPortfolio: AccountPortfolioItem?
    private(set) var listItem: IncomingASAListItem
    private(set) var account: Account?

    init(_ draft: IncomingASAListItem, account: Account, accountPortfolio: AccountPortfolioItem) {
        self.listItem = draft
        self.accountPortfolio = accountPortfolio
        self.bindAccountItem(account, accountPortfolio: accountPortfolio)
    }
}

extension IncomingASADetailHeaderViewModel {
    mutating func bindAccountItem(_ account: Account, accountPortfolio: AccountPortfolioItem) {
        self.accountItem = AccountListItemViewModel(accountPortfolio)
        self.account = account
    }
}
