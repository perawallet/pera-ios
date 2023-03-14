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

//   RekeyingValidator.swift

import Foundation

struct RekeyingValidator {
    private let transactionSignatureValidator: TransactionSignatureValidator
    
    init(
        session: Session,
        sharedDataController: SharedDataController
    ) {
        self.transactionSignatureValidator = TransactionSignatureValidator(
            session: session,
            sharedDataController: sharedDataController
        )
    }
    
    func validateRekeying(
        fromAccount: Account,
        toAccount: Account
    ) -> RekeyingValidationResult {
        if isRekeyingToTheSameAccount(
            fromAccount: fromAccount,
            toAccount: toAccount
        ) {
            return validateUndoRekeying(for: fromAccount)
        }
        
        if canCreateRekeyingChain(for: toAccount) {
            return .failure
        }
        
        return canSignTransactionForAccount(fromAccount)
    }
}

extension RekeyingValidator {
    private func isRekeyingToTheSameAccount(
        fromAccount: Account,
        toAccount: Account
    ) -> Bool {
        return fromAccount.isSameAccount(with: toAccount.address)
    }
    
    private func validateUndoRekeying(for account: Account) -> RekeyingValidationResult {
        return account.isRekeyed() ? .success : .failure
    }
    
    private func canCreateRekeyingChain(for account: Account) -> Bool {
        return account.isRekeyed()
    }
    
    private func canSignTransactionForAccount(_ fromAccount: Account) -> RekeyingValidationResult {
        let transactionSignatureValidationResult = transactionSignatureValidator.validateTransactionSignature(for: fromAccount)
       
        if case .success = transactionSignatureValidationResult {
            return .success
        }
        
        return .failure
    }
}

enum RekeyingValidationResult {
    case success
    case failure
    
    var canCompleteRekeying: Bool {
        return self == .success
    }
}
