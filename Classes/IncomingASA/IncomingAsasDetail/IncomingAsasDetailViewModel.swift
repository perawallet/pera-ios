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

struct IncomingAsasDetailViewModel: ViewModel {
    private(set) var accountAssets: IncomingASAAccountViewModel?
    private(set) var amount: IncomingAsaRequestHeaderViewModel?
    private(set) var id: TextProvider?
    private(set) var senders: [IncomingAsaSenderViewModel]?
    
    init(
        sourceAccount: WCSessionConnectionDraft,
        senders: [IncomingAsaSenderViewModel],
        id: TextProvider
    ) {
        bindAccountAssets(sourceAccount)
        bindAmount(sourceAccount)
        self.senders = senders
        self.id = id
    }
}

extension IncomingAsasDetailViewModel {
    private mutating func bindAccountAssets(_ draft: WCSessionConnectionDraft) {
        self.accountAssets = IncomingASAAccountViewModel(draft)
    }
    
    private mutating func bindAmount(_ draft: WCSessionConnectionDraft) {
        self.amount = IncomingAsaRequestHeaderViewModel(draft)
    }
}
