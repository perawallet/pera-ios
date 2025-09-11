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

//   ImportAccountsHandler.swift

import pera_wallet_core

enum ImportAccountsHandler {
    
    static func handle(account: Account, presenter: BaseViewController) {
        
        let configuration = presenter.configuration
        guard let session = configuration.session else { return }
        let mnemonic = PassphraseUtils.mnemonics(account: account, hdWalletStorage: configuration.hdWalletStorage, session: session).mnemonics.joined(separator: " ")
        
        presenter.open(
            .importAccount(.recoverHDWallet(mnemonic)) { event, screen in
                switch event {
                case let .didCompleteHDWalletImport(addresses, universalWalletID):
                    guard let universalWalletID else {
                        close(importAccountScreen: screen)
                        return
                    }
                    finishRecoverAccount(addresses: addresses, hdWalletId: universalWalletID, importAccountScreen: screen, presenter: presenter)
                case .didCompleteImport:
                    close(importAccountScreen: screen)
                case let .didFailToImport(error):
                    showErrorScreen(importAccountScreen: screen, error: .decryption, from: presenter)
                }
            },
            by: .customPresent(presentationStyle: .fullScreen, transitionStyle: .coverVertical, transitioningDelegate: nil)
        )
    }
    
    private static func finishRecoverAccount(addresses: [RecoveredAddress], hdWalletId: String, importAccountScreen: ImportAccountScreen, presenter: BaseViewController) {
        importAccountScreen.dismissScreen() {
            presenter.open(.selectAddress(recoveredAddresses: addresses, hdWalletId: hdWalletId), by: .push)
        }
    }
    
    private static func showErrorScreen(importAccountScreen: ImportAccountScreen, error: ImportAccountScreenError, from presenter: BaseViewController) {
        importAccountScreen.dismissScreen() {
            let errorScreen = Screen.importAccountError(error) { _, _ in
                presenter.popScreen()
            }
            presenter.open(errorScreen, by: .push)
        }
    }
    
    private static func close(importAccountScreen: ImportAccountScreen) {
        importAccountScreen.dismissScreen()
    }
}
