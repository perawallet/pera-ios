// Copyright 2019 Algorand, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//   WCTransactionValidator.swift

import UIKit

protocol WCTransactionValidator {
    func validateTransactions(_ transactions: [WCTransaction], with transactionGroups: [Int64: [WCTransaction]])
    func rejectTransactionRequest(with error: WCTransactionErrorResponse)
}

extension WCTransactionValidator {
    func validateTransactions(_ transactions: [WCTransaction], with transactionGroups: [Int64: [WCTransaction]]) {
        if !hasValidTransactionCount(for: transactions) {
            rejectTransactionRequest(with: .unsupported)
            return
        }

        if !hasValidNetwork(for: transactions) {
            rejectTransactionRequest(with: .unauthorized)
            return
        }

        if !hasValidAddresses(in: transactions) {
            rejectTransactionRequest(with: .invalidInput)
            return
        }

        if containsMultisigTransaction(in: transactions) {
            rejectTransactionRequest(with: .unsupported)
            return
        }

        if !hasValidSignerAddress(in: transactions) {
            rejectTransactionRequest(with: .invalidInput)
            return
        }

        if requiresLedgerInAtomicTransaction(for: transactionGroups) {
            rejectTransactionRequest(with: .unsupported)
            return
        }

        if hasInvalidApplicationCallTransaction(in: transactions) {
            rejectTransactionRequest(with: .unsupported)
            return
        }

        if hasInvalidGroupedTransaction(in: transactionGroups) {
            rejectTransactionRequest(with: .invalidInput)
            return
        }
    }

    private func hasValidTransactionCount(for transactions: [WCTransaction]) -> Bool {
        return transactions.count <= supportedTransactionCount
    }

    private func hasValidNetwork(for transactions: [WCTransaction]) -> Bool {
        guard let params = UIApplication.shared.appDelegate?.accountManager.params else {
            return false
        }

        for transaction in transactions {
            if !transaction.isInTheSameNetwork(with: params) {
                return false
            }
        }

        return true
    }

    private func hasValidAddresses(in transactions: [WCTransaction]) -> Bool {
        let algorandSDK = AlgorandSDK()
        for transaction in transactions {
            let addresses = transaction.validationAddresses.compactMap { $0 }
            for address in addresses {
                if !algorandSDK.isValidAddress(address) {
                    return false
                }
            }
        }

        return true
    }

    private func containsMultisigTransaction(in transactions: [WCTransaction]) -> Bool {
        return transactions.contains { $0.isMultisig }
    }

    private func hasValidSignerAddress(in transactions: [WCTransaction]) -> Bool {
        for transaction in transactions where transaction.authAddress != nil {
            if !transaction.hasValidAuthAddressForSigner || !transaction.hasValidSignerAddress {
                return false
            }
        }

        return true
    }

    private func requiresLedgerInAtomicTransaction(for transactionGroups: [Int64: [WCTransaction]]) -> Bool {
        for group in transactionGroups where group.value.count > 1 {
            for transaction in group.value {
                if let signerAccount = transaction.signerAccount,
                   signerAccount.requiresLedgerConnection() {
                    return true
                }
            }
        }

        return false
    }

    private func hasInvalidApplicationCallTransaction(in transactions: [WCTransaction]) -> Bool {
        let appCallTransactions = transactions.filter { $0.transactionDetail?.isAppCallTransaction ?? false }

        if appCallTransactions.isEmpty {
            return false
        }

        return appCallTransactions.contains { transaction in
            return !(transaction.transactionDetail?.isSupportedAppCallTransaction ?? true)
        }
    }

    private func hasInvalidGroupedTransaction(in transactionGroups: [Int64: [WCTransaction]]) -> Bool {
        for group in transactionGroups {
            let signableTransactions = group.value.filter { $0.signerAccount != nil }
            if signableTransactions.isEmpty {
                return true
            }
        }

        return false
    }
}

extension WCTransactionValidator {
    private var supportedTransactionCount: Int {
        return 16
    }
}
