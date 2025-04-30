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

//
//   WalletFlowType.swift

enum WalletFlowType {
    case bip39
    case algo25
    
    var mnemonicProvider: MnemonicProvider {
        switch self {
        case .bip39:
            return Bip39MnemonicProvider()
        case .algo25:
            return Algo25MnemonicProvider()
        }
    }
    
    var passphraseBackUpViewTheme: PassphraseBackUpViewTheme {
        switch self {
        case .bip39:
            return PassphraseBackUpViewBip39Theme()
        case .algo25:
            return PassphraseBackUpViewCommonTheme()
        }
    }
    
    var accountRecoverViewControllerTheme: AccountRecoverViewControllerTheme {
        switch self {
        case .bip39:
            return AccountRecoverViewControllerBip39Theme()
        case .algo25:
            return AccountRecoverViewControllerCommonTheme()
        }
    }
}
