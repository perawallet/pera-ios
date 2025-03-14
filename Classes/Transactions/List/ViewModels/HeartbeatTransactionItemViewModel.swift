// Copyright 2025 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   HeartbeatTransactionItemViewModel.swift

import MacaroonUIKit

struct HeartbeatTransactionItemViewModel: TransactionListItemViewModel {
    var id: String?
    var title: MacaroonUIKit.EditText? = .string("transaction-detail-heartbeat".localized)
    var subtitle: MacaroonUIKit.EditText? = nil
    var transactionAmountViewModel: TransactionAmountViewModel? = nil
}

extension HeartbeatTransactionItemViewModel: Hashable {
    
    static func == (lhs: HeartbeatTransactionItemViewModel, rhs: HeartbeatTransactionItemViewModel) -> Bool {
        lhs.id == rhs.id
    }
}
