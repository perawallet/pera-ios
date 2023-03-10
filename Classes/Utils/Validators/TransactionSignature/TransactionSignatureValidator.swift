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

//   TransactionSignatureValidator.swift

import Foundation

struct TransactionSignatureValidator {
    private let session: Session
    private let sharedDataController: SharedDataController
    
    init(
        session: Session,
        sharedDataController: SharedDataController
    ) {
        self.session = session
        self.sharedDataController = sharedDataController
    }
    
    func validateTransactionSignature(for account: Account) -> TransactionSignatureValidationResult {
        if account.isWatchAccount() {
            return .failure(TransactionSignatureInvalidAccountTypeError())
        }
        
        if account.hasAuthAccount() {
            return validateTransactionSignatureErrorForRekeyedAccount(account)
        }
        
        if account.isLedger() {
            return validateTransactionSignatureErrorForLedgerAccount(account)
        }
        
        return validateTransactionSignatureErrorForStandardAccount(account)
    }
}

extension TransactionSignatureValidator {
    private func validateTransactionSignatureErrorForRekeyedAccount(_ account: Account) -> TransactionSignatureValidationResult {
        guard let authAddress = account.authAddress else {
            return .failure(TransactionSignatureMissingAuthAddressError())
        }
        
        if hasRekeyedLedgerInformation(for: account) {
            return .success
        }
        
        if !hasAuthorizationAccount(authAddress) {
            return .failure(TransactionSignatureMissingAuthAddressError())
        }
        
        return .success
    }
    
    private func hasRekeyedLedgerInformation(for account: Account) -> Bool {
        guard let authAddress = account.authAddress else {
            return false
        }
        
        return account.rekeyDetail?[safe: authAddress] != nil
    }
    
    private func hasAuthorizationAccount(_ authAddress: PublicKey) -> Bool {
        return sharedDataController.accountCollection[authAddress] != nil
    }
}

extension TransactionSignatureValidator {
    private func validateTransactionSignatureErrorForLedgerAccount(_ account: Account) -> TransactionSignatureValidationResult {
        if !account.hasLedgerDetail() {
            return .failure(TransactionSignatureMissingLedgerDetailError())
        }
        
        return .success
    }
}

extension TransactionSignatureValidator {
    private func validateTransactionSignatureErrorForStandardAccount(_ account: Account) -> TransactionSignatureValidationResult {
        if !session.hasPrivateData(for: account.address) {
            return .failure(TransactionSignatureMissingPrivateKeyError())
        }
        
        return .success
    }
}
