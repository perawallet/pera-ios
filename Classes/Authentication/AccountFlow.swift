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
//  AccountFlow.swift

import UIKit

enum AccountSetupFlow: Equatable {
    case initializeAccount(mode: AccountSetupMode)
    case addNewAccount(mode: AccountSetupMode)
    case backUpAccount(needsAccountSelection: Bool)
    case none
}

extension AccountSetupFlow {
    var rekeyingAccount: Account? {
        switch self {
        case .addNewAccount(let mode):
            switch mode {
            case .rekey(let account): return account
            default: return nil
            }
        default: return nil
        }
    }
}

extension AccountSetupFlow {
    var isBackUpAccount: Bool {
        if case .backUpAccount = self {
            return true
        }

        return false
    }
}

enum AccountSetupMode: Equatable {
    case addAlgo25Account
    case addBip39Address(newAddress: HDWalletAddress?)
    case addBip39Wallet
    case recover(type: RecoverType)
    case rekey(account: Account)
    case watch
    case none
}

extension AccountSetupMode {
    var shouldShowNewAccountWarning: Bool {
        switch self {
        case .addBip39Address:
            return true
        case .addAlgo25Account, .addBip39Wallet, .recover, .rekey, .watch:
            return false
        case .none:
            assertionFailure("Should not happen")
            return false
        }
    }
}

enum RecoverType: Equatable {
    case passphraseAlgo25
    case passphrase
    case importFromSecureBackup
    case qr
    case ledger
    case importFromWeb
    case titleAlgo25
    case title
}
