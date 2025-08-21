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
import DeveloperToolsSupport
import AuthenticationServices
import pera_wallet_core

final class PasskeyListViewModel: ObservableObject {
    
    // MARK: - Properties
    
    @Published fileprivate(set) var passkeys: [PassKey] = []
    @Published fileprivate(set) var settingNotEnabled = false
    private let passKeyManager: PassKeyService?
    
    // MARK: - Initializers
    
    init() {
        guard let appConfig = AppDelegate.shared?.appConfiguration else {
            passKeyManager = nil
            return
        }
        
        passKeyManager = PassKeyService(hdWalletStorage: appConfig.hdWalletStorage, session: appConfig.session)
        checkForSettingEnabled()
        reloadPasskeys()
    }
    
    
    // MARK: - Methods
    
    func reloadPasskeys() {
        passkeys = passKeyManager?.allPassKeys ?? []
    }
    
    func trackDeletion() {
        if let analytics = CoreAppConfiguration.shared?.analytics {
            analytics.track(.webAuthNPassKeyDeleted())
        }
        reloadPasskeys()
    }
    
    private func checkForSettingEnabled() {
        let store = ASCredentialIdentityStore.shared
        store.getState { [weak self] state in
            Task {
                await self?.updateEnabledState(state.isEnabled)
            }
        }
    }
    
    @MainActor
    private func updateEnabledState(_ isEnabled: Bool) {
        settingNotEnabled = !isEnabled
    }
    
}

protocol PasskeyListModelable {
    var viewModel: PasskeyListViewModel { get }
}

final class PasskeyListModel: PasskeyListModelable {
    
    // MARK: - PasskeyListModelable
    
    let viewModel: PasskeyListViewModel = PasskeyListViewModel()
}
