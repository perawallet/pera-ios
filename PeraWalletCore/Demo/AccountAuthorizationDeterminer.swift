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

//   AccountAuthorizationDeterminer.swift

final class AccountAuthorizationDeterminer {
    private unowned let session: Session

    init(session: Session) {
        self.session = session
    }
}

extension AccountAuthorizationDeterminer {
    func determineAccountAuthorization(
        of account: Account,
        with accountCollection: AccountCollection
    ) -> AccountAuthorization {
        if account.isWatchAccount {
            return .watch
        }

        if let accountHandle = accountCollection[account.address],
           !accountHandle.isAvailable {
            return .unknown
        }
        
        if account.isHDAccount {
            return determineAccountAuthorizationForHDWallet(
                account: account,
                accountCollection: accountCollection
            )
        }

        if account.hasAuthAccount() {
            
            guard !account.isJointAccount else { return .jointAccountRekeyed }
            
            return determineAccountAuthorizationForRekeyedAccount(
                account: account,
                accountCollection: accountCollection
            )
        }

        if account.hasLedgerDetail() {
            return .ledger
        }
        
        if account.hasJointAccountDetails, CoreAppConfiguration.shared?.featureFlagService.isEnabled(.jointAccountEnabled) == true {
            return .jointAccount
        }

        let isStandard = session.hasPrivateData(for: account.address)
        if isStandard {
            return .standard
        }

        return .noAuthInLocal
    }
}

extension AccountAuthorizationDeterminer {
    private func determineAccountAuthorizationForHDWallet(
        account: Account,
        accountCollection: AccountCollection
    ) -> AccountAuthorization {
        guard let hdWalletAddressDetail = account.hdWalletAddressDetail else {
            return .noAuthInLocal
        }
        
        if let authAddress = account.authAddress {
            return determineAccountAuthorizationForRekeyedHDWallet(
                account: account,
                authAddress: authAddress,
                accountCollection: accountCollection
            )
        }
        
        return determineAccountAuthorizationForNonRekeyedHDWallet(walletId: hdWalletAddressDetail.walletId)
    }
    
    private func determineAccountAuthorizationForRekeyedHDWallet(
        account: Account,
        authAddress: String,
        accountCollection: AccountCollection
    ) -> AccountAuthorization {
        
        if let authAccount = accountCollection[authAddress], let authAccountHDWalletDetail = authAccount.value.hdWalletAddressDetail {
            return determineAccountAuthorizationForRekeyedToHDWallet(walletId: authAccountHDWalletDetail.walletId)
        }
        
        return determineAccountAuthorizationForRekeyedAccount(
            account: account,
            accountCollection: accountCollection
        )
    }
    
    private func determineAccountAuthorizationForRekeyedToHDWallet(walletId: String) -> AccountAuthorization {
        let hasWallet = session.authenticatedUser?.accounts(withWalletId: walletId).isNonEmpty ?? false
        return hasWallet ? .standardToStandardRekeyed : .standardToNoAuthInLocalRekeyed
    }
    
    private func determineAccountAuthorizationForNonRekeyedHDWallet(walletId: String) -> AccountAuthorization {
        let hasWallet = session.authenticatedUser?.accounts(withWalletId: walletId).isNonEmpty ?? false
        return hasWallet ? .standard : .noAuthInLocal
    }
    
    private func determineAccountAuthorizationForRekeyedAccount(
        account: Account,
        accountCollection: AccountCollection
    ) -> AccountAuthorization {
        let isRekeyedToLedgerAccountInLocal = isRekeyedToLedgerAccountInLocal(
            account: account,
            accountCollection: accountCollection
        )
        if isRekeyedToLedgerAccountInLocal {
            return determineAccountAuthorizationForRekeyedToLedgerAccount(account)
        }

        let isRekeyedToStandardAccountInLocal = isRekeyedToStandardAccountInLocal(
            account: account,
            accountCollection: accountCollection
        )
        if isRekeyedToStandardAccountInLocal {
            return determineAccountAuthorizationForRekeyedToStandardAccount(account)
        }

        return determineAccountAuthorizationForRekeyedToNoAuthInLocalAccount(account)
    }

    private func determineAccountAuthorizationForRekeyedToLedgerAccount(_ account: Account) -> AccountAuthorization {
        let hasPrivateData = hasPrivateData(for: account)
        if hasPrivateData { return .standardToLedgerRekeyed }

        let hasLedgerDetail = account.hasLedgerDetail()
        if hasLedgerDetail { return .ledgerToLedgerRekeyed }

        return .unknownToLedgerRekeyed
    }

    private func determineAccountAuthorizationForRekeyedToStandardAccount(_ account: Account) -> AccountAuthorization {
        let hasPrivateData = hasPrivateData(for: account)
        if hasPrivateData { return .standardToStandardRekeyed }

        let hasLedgerDetail = account.hasLedgerDetail()
        if hasLedgerDetail { return .ledgerToStandardRekeyed }

        return .unknownToStandardRekeyed
    }

    private func determineAccountAuthorizationForRekeyedToNoAuthInLocalAccount(_ account: Account) -> AccountAuthorization {
        let hasPrivateData = hasPrivateData(for: account)
        if hasPrivateData { return .standardToNoAuthInLocalRekeyed }

        let hasLedgerDetail = account.hasLedgerDetail()
        if hasLedgerDetail { return .ledgerToNoAuthInLocalRekeyed }

        return .unknownToNoAuthInLocalRekeyed
    }
    
    private func isRekeyedToLedgerAccountInLocal(
        account: Account,
        accountCollection: AccountCollection
    ) -> Bool {
        updateLedgerDetailOfRekeyedAccountIfNeeded(
            account: account,
            accountCollection: accountCollection
        )

        let hasRekeyDetail = account.rekeyDetail?[safe: account.authAddress] != nil
        return hasRekeyDetail
    }

    private func updateLedgerDetailOfRekeyedAccountIfNeeded(
        account: Account,
        accountCollection: AccountCollection
    ) {
        guard let authAddress = account.authAddress,
              let authAccount = accountCollection[authAddress],
              let ledgerDetail = authAccount.value.ledgerDetail,
              account.rekeyDetail?[safe: authAddress] == nil else {
            return

        }

        account.addRekeyDetail(
            ledgerDetail,
            for: authAddress
        )
        session.authenticatedUser?.updateLocalAccount(account)
    }

    private func isRekeyedToStandardAccountInLocal(
        account: Account,
        accountCollection: AccountCollection
    ) -> Bool {
        guard let authAddress = account.authAddress, let authAccount = accountCollection[authAddress] else { return false }

        return hasPrivateData(for: authAccount.value)
    }
}

extension AccountAuthorizationDeterminer {
    private func hasPrivateData(for account: Account) -> Bool {
        if let hdWalletAddressDetail = account.hdWalletAddressDetail {
            return session.authenticatedUser?.accounts(withWalletId: hdWalletAddressDetail.walletId).isNonEmpty ?? false
        }
        
        return session.hasPrivateData(for: account.address)
    }
}
