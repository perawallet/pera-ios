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

import Foundation
import pera_wallet_core
import KeychainAccess


final class RecoveryToolViewModel: ObservableObject {
    
    // MARK: - Properties
    
    @Published fileprivate(set) var statusText: String = ""
    @Published fileprivate(set) var loading: Bool = false
    @Published fileprivate(set) var isErrorState: Bool = false
    @Published var address: String = ""
    
    // MARK: - Initializers
    
    init() {
    }
    
    
    // MARK: - Methods
    
    @MainActor
    func scanForAddress() {
        do {
            statusText = ""
            isErrorState = false
            loading = true
            
            defer { loading = false }
            
            guard let config = CoreAppConfiguration.shared else {
                loading = false
                return
            }
            
            if config.session.privateData(for: address) != nil {
                guard config.sharedDataController.accountCollection.filter({ $0.value.address == address }).first == nil else {
                    statusText = String(localized: "search-recovery-already-exists")
                    isErrorState = true
                    return
                }
                
                saveAccountInfo(AccountInformation(
                    address: address,
                    name: address.shortAddressDisplay,
                    isWatchAccount: false,
                    preferredOrder: config.sharedDataController.getPreferredOrderForNewAccount(),
                    isBackedUp: true,
                    hdWalletAddressDetail: nil
                ))
            } else if let key = config.hdWalletStorage.allHDWalletKeys().first(where: { $0.contains(address) }) {
                let parts = key.split(separator: ".")
                let walletId = String(parts[1])
                let address = String(parts[2])
                
                if let hdWallet = try config.hdWalletStorage.wallet(id: walletId) {
                    guard config.sharedDataController.accountCollection.filter({ $0.value.address == address }).first == nil else {
                        statusText = String(localized: "search-recovery-already-exists")
                        isErrorState = true
                        return
                    }
                
                    let mnemonics = HDWalletUtils.generateMnemonic(fromEntropy: hdWallet.entropy)?.components(separatedBy: .whitespaces) ?? []
                    
                    Task {
                        let recovery = try await config.hdWalletService.recoverAccounts(fromMnemonic: mnemonics.joined(separator: " "), api: config.api)
                        if let account = recovery.first(where: {$0.address == address}) {
                            
                            let hdWalletAddressDetail = HDWalletAddressDetail(
                                walletId: hdWallet.id,
                                account: account.accountIndex,
                                change: 0,
                                keyIndex: account.addressIndex
                            )
                            
                            saveAccountInfo(AccountInformation(
                                address: account.address,
                                name: account.address.shortAddressDisplay,
                                isWatchAccount: false,
                                preferredOrder: config.sharedDataController.getPreferredOrderForNewAccount(),
                                isBackedUp: true,
                                hdWalletAddressDetail: hdWalletAddressDetail
                            ))
                        }
                    }
                }
            } else {
                statusText = String(localized: "search-recovery-not-found")
                isErrorState = true
                return
            }
        } catch {
            isErrorState = true
            statusText = error.localizedDescription
        }
    }
    
    private func saveAccountInfo(_ info: AccountInformation) {
        
        guard let config = CoreAppConfiguration.shared else {
            return
        }
        
        let authenticatedUser = config.session.authenticatedUser ?? User()
        authenticatedUser.addAccounts([info])
        
        let pushNotificationController = PushNotificationController(
            target: ALGAppTarget.current,
            session: config.session,
            api: config.api
        )
        pushNotificationController.sendDeviceDetails()
        
        config.session.authenticatedUser = authenticatedUser
        
        statusText = String(localized: "search-recovery-recovered")
        isErrorState = false
        loading = false
    }
}
