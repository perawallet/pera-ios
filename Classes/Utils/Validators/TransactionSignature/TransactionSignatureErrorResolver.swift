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

//   TransactionSignatureErrorResolver.swift

import Foundation

struct TransactionSignatureErrorResolver: TransactionSignatureErrorResolving {
    private let session: Session
    private let sharedDataController: SharedDataController
    
    init(
        session: Session,
        sharedDataController: SharedDataController
    ) {
        self.session = session
        self.sharedDataController = sharedDataController
    }
    
    func findTransactionSignatureErrorIfPresent(for account: inout Account) -> TransactionSignatureValidationError? {
        if account.isWatchAccount() {
            return TransactionSignatureInvalidAccountTypeError()
        }
        
        if account.hasAuthAccount() {
            return findTransactionSignatureErrorForRekeyedAccountIfPresent(&account)
        }
        
        if account.isLedger() {
            return findTransactionSignatureErrorForLedgerAccountIfPresent(account)
        }
        
        return findTransactionSignatureErrorForStandardAccountIfPresent(account)
    }
}

extension TransactionSignatureErrorResolver {
    private func findTransactionSignatureErrorForRekeyedAccountIfPresent(_ account: inout Account) -> TransactionSignatureValidationError? {
        guard let authAddress = account.authAddress else {
            return TransactionSignatureMissingAuthAddressError()
        }
        
        if hasRekeyedLedgerInformation(for: account) {
            return nil
        }
        
        guard let authAccount = sharedDataController.accountCollection[authAddress] else {
            return TransactionSignatureMissingAuthAddressError()
        }
        
        bindLedgerDetailIfNeeded(
            to: &account,
            from: authAccount.value
        )
        
        return nil
    }
    
    private func hasRekeyedLedgerInformation(for account: Account) -> Bool {
        guard let authAddress = account.authAddress else {
            return false
        }
        
        return account.rekeyDetail?[authAddress] != nil
    }
    
    private func bindLedgerDetailIfNeeded(
        to account: inout Account,
        from authAccount: Account
    ) {
        guard let ledgerDetail = authAccount.ledgerDetail else { return }
        
        account.addRekeyDetail(
            ledgerDetail,
            for: authAccount.address
        )
    }
}

extension TransactionSignatureErrorResolver {
    private func findTransactionSignatureErrorForLedgerAccountIfPresent(_ account: Account) -> TransactionSignatureValidationError? {
        return !isLedgerDetailSet(on: account) ?
            TransactionSignatureMissingLedgerDetailError() :
            nil
    }
    
    private func isLedgerDetailSet(on account: Account) -> Bool {
        return account.ledgerDetail != nil
    }
}

extension TransactionSignatureErrorResolver {
    private func findTransactionSignatureErrorForStandardAccountIfPresent(_ account: Account) -> TransactionSignatureValidationError? {
        return !isPrivateKeyStored(for: account) ?
            TransactionSignatureMissingPrivateKeyError() :
            nil
    }
    
    private func isPrivateKeyStored(for account: Account) -> Bool {
        return session.privateData(for: account.address) != nil
    }
}
