// Copyright 2023 Pera Wallet, LDA

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
    private unowned let sharedDataController: SharedDataController

    init(
        session: Session,
        sharedDataController: SharedDataController
    ) {
        self.session = session
        self.sharedDataController = sharedDataController
    }
}

extension AccountAuthorizationDeterminer {
    func determineAccountAuthorization(of acc: Account) -> AccountAuthorization {
        if acc.isWatchAccount() {
            return .watch
        }

        if acc.hasAuthAccount() {
            return determineAccountAuthorizationForRekeyedAccount(acc)
        }

        if acc.hasLedgerDetail() {
            return .ledger
        }

        let isStandard = session.hasPrivateData(for: acc.address)
        if isStandard {
            return .standard
        }

        return .unknown
    }
}

extension AccountAuthorizationDeterminer {
    private func determineAccountAuthorizationForRekeyedAccount(_ acc: Account) -> AccountAuthorization {
        if isRekeyedToLedgerAccountInLocal(acc) {
            return determineAccountAuthorizationForRekeyedToLedgerAccount(acc)
        }

        if isRekeyedToStandardAccountInLocal(acc) {
            return determineAccountAuthorizationForRekeyedToStandardAccount(acc)
        }

        return .noAuthInLocal
    }

    private func determineAccountAuthorizationForRekeyedToStandardAccount(_ acc: Account) -> AccountAuthorization {
        let hasPrivateData = session.hasPrivateData(for: acc.address)
        if hasPrivateData { return .standardToStandardRekeyed }

        let hasLedgerDetail = acc.hasLedgerDetail()
        if hasLedgerDetail { return .ledgerToStandardRekeyed }

        return .unknownToStandardRekeyed
    }

    private func determineAccountAuthorizationForRekeyedToLedgerAccount(_ acc: Account) -> AccountAuthorization {
        let hasPrivateData = session.hasPrivateData(for: acc.address)
        if hasPrivateData { return .standardToLedgerRekeyed }

        let hasLedgerDetail = acc.hasLedgerDetail()
        if hasLedgerDetail { return .ledgerToLedgerRekeyed }

        return .unknownToLedgerRekeyed
    }
    
    private func isRekeyedToLedgerAccountInLocal(_ acc: Account) -> Bool {
        return acc.rekeyDetail?[safe: acc.authAddress] != nil
    }

    private func isRekeyedToStandardAccountInLocal(_ acc: Account) -> Bool {
        guard let authAddress = acc.authAddress else { return false }
        guard let authAccount = sharedDataController.accountCollection[authAddress] else { return false }

        return session.hasPrivateData(for: authAccount.value.address)
    }
}
