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
    private(set) var accountAssets: IncomingASADetailHeaderViewModel?
    private(set) var amount: IncomingASARequestHeaderViewModel?
    private(set) var senders: [IncomingASARequesSenderViewModel]?
    private(set) var accountId: TextProvider?
    init(
        draft: IncomingASAListItem,
        account: Account?
    ) {
        bindAccountAssets(draft, account: account)
        bindSenders(draft.senders)
        bindAmount(draft)
    }
}

extension IncomingASAsDetailViewModel {
    private mutating func bindAccountAssets(_ draft: IncomingASAListItem, account: Account?) {
        self.accountAssets = IncomingASADetailHeaderViewModel(draft, account: account)
        self.accountId = String(draft.asset.id)
    }
    
    private mutating func bindSenders(_ senders: Senders?) {
        if let results = senders?.results {
            self.senders = results.compactMap { sender -> IncomingASARequesSenderViewModel? in
                return IncomingASARequesSenderViewModel(
                    amount: "\(sender.amount ?? 0)",
                    sender: sender.sender?.address ?? ""
                )
            }
        }
    }
    
    private mutating func bindAmount(_ draft: IncomingASAListItem) {
        self.amount = IncomingASARequestHeaderViewModel(draft)
    }
}
