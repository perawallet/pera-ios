//
//  TransactionControllerDelegate.swift

import Magpie

protocol TransactionControllerDelegate: class {
    func transactionController(_ transactionController: TransactionController, didComposedTransactionDataFor draft: TransactionSendDraft?)
    func transactionController(_ transactionController: TransactionController, didFailedComposing error: HIPError<TransactionError>)
    func transactionController(_ transactionController: TransactionController, didCompletedTransaction id: TransactionID)
    func transactionController(_ transactionController: TransactionController, didFailedTransaction error: HIPError<TransactionError>)
    func transactionControllerDidFailToSignWithLedger(_ transactionController: TransactionController)
}

extension TransactionControllerDelegate where Self: BaseViewController {
    func transactionController(
        _ transactionController: TransactionController,
        didComposedTransactionDataFor draft: TransactionSendDraft?
    ) { }
    
    func transactionController(_ transactionController: TransactionController, didFailedComposing error: HIPError<TransactionError>) { }
    
    func transactionController(_ transactionController: TransactionController, didCompletedTransaction id: TransactionID) { }
    
    func transactionController(_ transactionController: TransactionController, didFailedTransaction error: HIPError<TransactionError>) { }
    
    func transactionControllerDidFailToSignWithLedger(_ transactionController: TransactionController) { }
}
