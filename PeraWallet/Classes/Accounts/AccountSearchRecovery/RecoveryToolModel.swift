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


protocol RecoveryToolModelable {
    var viewModel: RecoveryToolViewModel { get }
    
    func scanForAddress()
}

final class RecoveryToolViewModel: ObservableObject {
    
    // MARK: - Properties
    
    @Published fileprivate(set) var statusText: String = ""
    @Published fileprivate(set) var loading: Bool = false
    @Published fileprivate(set) var isErrorState: Bool = false
    @Published var address: String = ""
}

final class RecoveryToolModel: RecoveryToolModelable {
    
    // MARK: - RecoveryToolModelable
    
    var viewModel = RecoveryToolViewModel()
    
    private let session: Session
    private let sharedDataController: SharedDataController
    private let hdWalletStorage: HDWalletStorable
    private let hdWalletService: HDWalletServicing
    private let api: ALGAPI
    
    
    // MARK: - Initialisers
    init(session: Session, sharedDataController: SharedDataController, hdWalletStorage: HDWalletStorable, hdWalletService: HDWalletServicing, api: ALGAPI) {
        self.session = session
        self.sharedDataController = sharedDataController
        self.hdWalletStorage = hdWalletStorage
        self.hdWalletService = hdWalletService
        self.api = api
    }
    
    // MARK: - Setups
    
    // MARK: - Methods
    func scanForAddress() {
        guard !viewModel.loading else {
            return
        }
        
        do {
            updateViewModel(statusText: "", loading: true, isErrorState: false)
            
            defer {
                updateViewModel(statusText: nil, loading: false, isErrorState: nil)
            }
            
            if session.privateData(for: viewModel.address) != nil {
                try recoverAlgo25Account(address: viewModel.address)
            } else if let key = hdWalletStorage.allHDWalletKeys.first(where: { $0.contains(viewModel.address) }) {
                try recoverHDWalletAccount(key: key)
            } else {
                updateViewModel(statusText: String(localized: "search-recovery-not-found"),
                                loading: nil,
                                isErrorState: true)
                return
            }
        } catch {
            updateViewModel(statusText: error.localizedDescription,
                            loading: nil,
                            isErrorState: true)
        }
    }
    
    private func recoverAlgo25Account(address: String) throws {
        
        guard sharedDataController.accountCollection.contains(where: { $0.value.address == address }) else {
            updateViewModel(statusText: String(localized: "search-recovery-already-exists"),
                            loading: nil,
                            isErrorState: true)
            return
        }
        
        saveAccountInfo(AccountInformation(
            address: address,
            name: address.shortAddressDisplay,
            isWatchAccount: false,
            preferredOrder: sharedDataController.getPreferredOrderForNewAccount(),
            isBackedUp: true,
            hdWalletAddressDetail: nil
        ))
    }
    
    private func recoverHDWalletAccount(key: String) throws {
        let parts = key.split(separator: ".")
        let walletId = String(parts[1])
        let address = String(parts[2])
        
        if let hdWallet = try hdWalletStorage.wallet(id: walletId) {
            guard sharedDataController.accountCollection.filter({ $0.value.address == address }).first == nil else {
                updateViewModel(statusText: String(localized: "search-recovery-already-exists"),
                                loading: nil,
                                isErrorState: true)
                return
            }
        
            let mnemonics = HDWalletUtils.generateMnemonic(fromEntropy: hdWallet.entropy)?.components(separatedBy: .whitespaces) ?? []
            
            Task {
                let recovery = try await hdWalletService.recoverAccounts(fromMnemonic: mnemonics.joined(separator: " "), api: api)
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
                        preferredOrder: sharedDataController.getPreferredOrderForNewAccount(),
                        isBackedUp: true,
                        hdWalletAddressDetail: hdWalletAddressDetail
                    ))
                }
            }
        }
    }
    
    private func saveAccountInfo(_ info: AccountInformation) {
        guard let config = CoreAppConfiguration.shared else {
            return
        }
        
        let authenticatedUser = session.authenticatedUser ?? User()
        authenticatedUser.addAccounts([info])
        
        let pushNotificationController = PushNotificationController(
            target: ALGAppTarget.current,
            session: config.session,
            api: config.api
        )
        pushNotificationController.sendDeviceDetails()
        
        config.session.authenticatedUser = authenticatedUser
        updateViewModel(statusText: String(localized: "search-recovery-recovered"),
                        loading: false,
                        isErrorState: false)
    }
    
    private func updateViewModel(statusText: String?, loading: Bool?, isErrorState: Bool?) {
        Task { @MainActor [weak self] in
            if let statusText { self?.viewModel.statusText = statusText }
            if let isErrorState { self?.viewModel.isErrorState = isErrorState }
            if let loading { self?.viewModel.loading = loading }
        }
    }
}
