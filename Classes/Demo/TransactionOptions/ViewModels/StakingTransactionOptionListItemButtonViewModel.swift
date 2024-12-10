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

//   StakingTransactionOptionListItemButtonViewModel.swift

import MacaroonUIKit

struct StakingTransactionOptionListItemButtonViewModel: TransactionOptionListItemButtonViewModel {
    let icon: Image?
    private(set) var isBadgeVisible: Bool
    let title: EditText?
    let subtitle: EditText?
    var accessory: (any Image)?
    let leftAccessory: Image?
    
    init(isBadgeVisible: Bool) {
        self.icon = "icon-transaction-option-list-stake"
        self.isBadgeVisible = false
        self.title = Self.getTitle("title-staking".localized)
        self.subtitle = Self.getSubtitle("transaction-option-list-staking-subtitle".localized)
        self.leftAccessory = "icon-transaction-option-list-stake-accessory"
    }
}
