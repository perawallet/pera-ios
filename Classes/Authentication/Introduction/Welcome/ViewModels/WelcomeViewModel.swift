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

//   WelcomeViewModel.swift

import Foundation
import Foundation
import MacaroonUIKit

struct WelcomeViewModel: ViewModel {
    private(set) var title: String?
    private(set) var createWalletViewModel: WelcomeTypeViewModel?
    private(set) var importWalletViewModel: WelcomeTypeViewModel?

    init(
        with flow: AccountSetupFlow
    ) {
        bind(flow)
    }
}

extension WelcomeViewModel {
    private mutating func bind(_ flow: AccountSetupFlow) {
        bindTitle(flow)
        bindCreateWalletViewModel()
        bindImportWalletViewModel()
    }

    private mutating func bindTitle(_ flow: AccountSetupFlow) {
        switch flow {
        case .initializeAccount,
             .none:
            title = "account-welcome-wallet-title".localized
        case .addNewAccount, .backUpAccount:
            fatalError("Shouldn't enter here")
        }
    }

    private mutating func bindCreateWalletViewModel() {
        createWalletViewModel = WelcomeTypeViewModel(.addBip39Wallet)
    }

    private mutating func bindImportWalletViewModel() {
        importWalletViewModel = WelcomeTypeViewModel(.recover(type: .none))
    }
}

