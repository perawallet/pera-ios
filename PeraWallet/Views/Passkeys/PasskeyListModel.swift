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
    
        
    @Published fileprivate(set) var passkeys: [PassKey] = []
    @Published var settingNotEnabled = false
    private let passKeyManager: PassKeyService?
    
    
    init() {
        if let appConfig = AppDelegate.shared?.appConfiguration {
            self.passKeyManager = PassKeyService(hdWalletStorage: appConfig.hdWalletStorage, session: appConfig.session)
            let store = ASCredentialIdentityStore.shared
            store.getState { [weak self] state in
                Task {
                    if let self = self {
                        await MainActor.run {
                            self.settingNotEnabled = !state.isEnabled
                        }
                    }
                }
            }
            reloadPasskeys()
        } else {
            self.passKeyManager = nil
        }
    }
    
    func reloadPasskeys() {
        self.passkeys = passKeyManager?.findAllPassKeys() ?? []
    }
    
    func trackDeletion() {
        if let analytics = CoreAppConfiguration.shared?.analytics {
            analytics.track(.webAuthNPassKeyDeleted())
        }
    }
    
}

// MARK: - Model

protocol PasskeyListModelable {
    var viewModel: PasskeyListViewModel { get }
}

final class PasskeyListModel: PasskeyListModelable {
    
    // MARK: - SettingsListModelable
    
    let viewModel:PasskeyListViewModel
    
    // MARK: - Initialisers
    
    init() {
        viewModel = PasskeyListViewModel()
    }
    
    // MARK: - Setups
    
    private func setupData(appVersion: String) {
    }
}
