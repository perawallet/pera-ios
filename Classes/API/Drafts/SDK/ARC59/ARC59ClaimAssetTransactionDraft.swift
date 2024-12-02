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

//   ARC59ClaimAssetTransactionDraft.swift

import Foundation

struct ARC59ClaimAssetTransactionDraft: TransactionDraft {
    var from: Account
    var transactionParams: TransactionParams
    let inboxAccount: String?
    let appID: Int64
    let assetID: Int64
    let isOptedIn: Bool
    let isClaimingAlgo: Bool
}
