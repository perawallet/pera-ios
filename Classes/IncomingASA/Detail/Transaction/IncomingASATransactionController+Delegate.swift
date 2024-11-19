// Copyright 2024 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   IncomingASATransactionController+Delegate.swift

import Foundation

protocol IncomingASATransactionControllerDelegate: AnyObject {
    func incomingASATransactionController(
        _ incomingASATransactionController: IncomingASATransactionController,
        didCompletedTransaction transactionId: TransactionID?
    )
    func incomingASATransactionController(
        _ incomingASATransactionController: IncomingASATransactionController,
        didSignTransactionAt index: Int
    )
    func incomingASATransactionControllerDidStartUploadingTransaction(
        _ incomingASATransactionController: IncomingASATransactionController
    )
    func incomingASATransactionController(
        _ incomingASATransactionController: IncomingASATransactionController,
        didFailedComposing error: HIPTransactionError
    )
    func incomingASATransactionControllerDidResetLedgerOperation(
        _ incomingASATransactionController: IncomingASATransactionController
    )
    func incomingASATransactionControllerDidRejectedLedgerOperation(
        _ incomingASATransactionController: IncomingASATransactionController
    )
    func incomingASATransactionControllerDidResetLedgerOperationOnSuccess(
        _ incomingASATransactionController: IncomingASATransactionController
    )
    func incomingASATransactionController(
        _ incomingASATransactionController: IncomingASATransactionController,
        didRequestUserApprovalFrom ledger: String
    )
    func incomingASATransactionController(
        _ incomingASATransactionController: IncomingASATransactionController,
        didComposedTransactionDataFor draft: TransactionSendDraft?
    )
    func incomingASATransactionController(
        _ incomingASATransactionController: IncomingASATransactionController,
        didFailedTransaction error: HIPTransactionError
    )
}
