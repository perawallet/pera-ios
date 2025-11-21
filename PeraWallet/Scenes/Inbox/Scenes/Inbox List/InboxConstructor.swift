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

//   InboxConstructor.swift

import pera_wallet_core

enum InboxConstructor {
    
    static func buildScene(legacyConfiguration: ViewControllerConfiguration) -> IncomingASAAccountsViewController? {
        guard let session = legacyConfiguration.session else { return nil }
        let model = InboxModel(inboxService: PeraCoreManager.shared.inbox, accountsService: PeraCoreManager.shared.accounts, legacySessionManager: session, legacyFeatureFlagService: legacyConfiguration.featureFlagService)
        return IncomingASAAccountsViewController(model: model, legacyConfiguration: legacyConfiguration)
    }
}
