// Copyright 2022-2026 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   TransactionViewModel.swift

import pera_wallet_core

struct TransactionViewModel: TransactionItem {
    
    let amount: Decimal
    let fee: UInt64?
    let transferType: TransferType
    
    var id: String?
    var type: TransactionType?
    var sender: String?
    var receiver: String?
    var contact: Contact?
    var isSelfTransaction: Bool
    var appId: Int64?
    var status: TransactionStatus?
    var allInnerTransactionsCount: Int
    var noteRepresentation: String?
    
    func isPending() -> Bool { status == .pending }
    func isAssetAdditionTransaction(for address: String) -> Bool { false }
}
