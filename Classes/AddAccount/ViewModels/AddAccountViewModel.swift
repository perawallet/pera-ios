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

//   AddAccountViewModel.swift

import Foundation
import Foundation
import MacaroonUIKit

struct AddAccountViewModel: ViewModel {
    private(set) var title: String?
    private(set) var createAddressViewModel: AccountTypeViewModel?
    private(set) var createWalletViewModel: AccountTypeViewModel?
    private(set) var importWalletViewModel: AccountTypeViewModel?
    private(set) var watchWalletViewModel: AccountTypeViewModel?

    init(
        with flow: AccountSetupFlow,
        and isHDWalletActive: Bool
    ) {
        bind(flow, isHDWalletActive: isHDWalletActive)
    }
}

extension AddAccountViewModel {
    private mutating func bind(_ flow: AccountSetupFlow, isHDWalletActive: Bool) {
        bindTitle(flow, with: isHDWalletActive)
        bindCreateAddressViewModel()
        bindCreateWalletViewModel(with: isHDWalletActive)
        bindImportWalletViewModel(with: isHDWalletActive)
        bindWatchWalletViewModel()
    }

    private mutating func bindTitle(_ flow: AccountSetupFlow, with isHDWalletActive: Bool) {
        switch flow {
        case .addNewAccount:
            if isHDWalletActive {
                title = String(localized: "account-welcome-add-wallet-or-account-title")
            } else {
                title = String(localized: "account-welcome-add-account-title")
            }
        case .backUpAccount:
            title = nil
        case .initializeAccount,
             .none:
            fatalError("Shouldn't enter here")
        }
    }
    
    private mutating func bindCreateAddressViewModel() {
        createAddressViewModel = AccountTypeViewModel(.addBip39Address(newAddress: nil))
    }

    private mutating func bindCreateWalletViewModel(with isHDWalletActive: Bool) {
        createWalletViewModel = AccountTypeViewModel(isHDWalletActive ? .addBip39Wallet : .addAlgo25Account)
    }

    private mutating func bindImportWalletViewModel(with isHDWalletActive: Bool) {
        importWalletViewModel = AccountTypeViewModel(.recover(type: isHDWalletActive ? .title : .titleAlgo25))
    }
    
    private mutating func bindWatchWalletViewModel() {
        watchWalletViewModel = AccountTypeViewModel(.watch)
    }
}

