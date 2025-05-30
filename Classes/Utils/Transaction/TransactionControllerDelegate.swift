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

//
//  TransactionControllerDelegate.swift

import MagpieHipo
import MagpieExceptions
import MacaroonUtils

typealias HIPTransactionError = HIPError<TransactionError, PrintableErrorDetail>

protocol TransactionControllerDelegate: AnyObject {
    func transactionController(_ transactionController: TransactionController, didComposedTransactionDataFor draft: TransactionSendDraft?)
    func transactionController(_ transactionController: TransactionController, didFailedComposing error: HIPTransactionError)
    func transactionController(_ transactionController: TransactionController, didCompletedTransaction id: TransactionID)
    func transactionController(_ transactionController: TransactionController, didFailedTransaction error: HIPTransactionError)
    func transactionControllerDidFailToSignWithLedger(_ transactionController: TransactionController)
    func transactionController(_ transactionController: TransactionController, didRequestUserApprovalFrom ledger: String)
    func transactionControllerDidResetLedgerOperation(_ transactionController: TransactionController)
    func transactionControllerDidRejectedLedgerOperation(_ transactionController: TransactionController)

    /// This is a temporary solution for handling reset operations as successful resets until the whole flow is refactored.
    /// A successful reset means that you should not cancel any pending opt-in/opt-out requests in the delegate method implementation.
    /// The actual `reset` method is used for failure cases.
    func transactionControllerDidResetLedgerOperationOnSuccess(_ transactionController: TransactionController)
}

extension TransactionControllerDelegate where Self: BaseViewController {
    func transactionController(
        _ transactionController: TransactionController,
        didComposedTransactionDataFor draft: TransactionSendDraft?
    ) { }
    
    func transactionController(_ transactionController: TransactionController, didFailedComposing error: HIPTransactionError) { }
    
    func transactionController(_ transactionController: TransactionController, didCompletedTransaction id: TransactionID) { }
    
    func transactionController(_ transactionController: TransactionController, didFailedTransaction error: HIPTransactionError) { }
    
    func transactionControllerDidFailToSignWithLedger(_ transactionController: TransactionController) { }

    func transactionController(_ transactionController: TransactionController, didRequestUserApprovalFrom ledger: String) { }

    func transactionControllerDidResetLedgerOperation(_ transactionController: TransactionController) {}

    func transactionControllerDidRejectedLedgerOperation(_ transactionController: TransactionController) {}

    func transactionControllerDidResetLedgerOperationOnSuccess(_ transactionController: TransactionController) {
        transactionControllerDidResetLedgerOperation(transactionController)
    }
}

class PrintableErrorDetail: DebugPrintable {
    var debugDescription: String {
        return ""
    }
}
