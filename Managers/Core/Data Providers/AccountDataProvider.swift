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

//   AccountDataProvider.swift

final class AccountDataProvider {
    
    // MARK: - Properties
    
    private let legacySessionManager: Session
    
    // MARK: - Initialisers
    
    init(legacySessionManager: Session) {
        self.legacySessionManager = legacySessionManager
    }
    
    // MARK: - Actions
    
    func accountType(localAccount: AccountInformation) -> PeraAccount.AccountType {
        if localAccount.type == .watch { return .watch }
        if localAccount.hdWalletAddressDetail != nil { return .universalWallet }
        return havePrivateData(address: localAccount.address) ? .algo25 : .invalid
    }
    
    func authorizationType(indexerAccount: IndexerAccount?, localAccounts: [AccountInformation]) -> PeraAccount.AuthorizedAccountType? {
        guard let indexerAccount, indexerAccount.isRekeyed, let authAddress = indexerAccount.authAddr else { return nil }
        guard let authAccount = localAccounts.first(where: { $0.address == authAddress }) else { return .invalid }
        if authAccount.ledgerDetail != nil { return .ledger }
        return havePrivateData(address: authAccount.address) ? .wallet : .invalid
    }
    
    // MARK: - Helpers
    
    private func havePrivateData(address: String) -> Bool {
        legacySessionManager.hasPrivateData(for: address)
    }
}

private extension IndexerAccount {
    var isRekeyed: Bool { authAddr != nil && authAddr != address }
}
