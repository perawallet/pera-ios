// Copyright 2022 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//   AccountListViewModel.swift

import MacaroonUIKit

struct AccountListViewModel {
    private(set) var title: String

    init(_ mode: AccountListViewController.Mode) {
        switch mode {
        case .contact, .transactionSender:
            title = "send-sending-algos-select".localized
        case .transactionReceiver:
            title = "send-receiving-algos-select".localized
        case .walletConnect:
            title = "accounts-title".localized
        }
    }
}
