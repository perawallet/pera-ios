//
//  TransactionControllerDelegate.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 28.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

protocol TransactionControllerDelegate: class {
    func transactionControllerDidComposedAlgosTransactionData(
        _ transactionController: TransactionController,
        forTransaction draft: AlgosTransactionSendDraft?
    )
    func transactionControllerDidComposedAssetTransactionData(
        _ transactionController: TransactionController,
        forTransaction draft: AssetTransactionSendDraft?
    )
    func transactionController(_ transactionController: TransactionController, didFailedComposing error: Error)
    func transactionController(_ transactionController: TransactionController, didCompletedTransaction id: TransactionID)
    func transactionController(_ transactionController: TransactionController, didFailedTransaction error: Error)
}

extension TransactionControllerDelegate {
    func transactionControllerDidComposedAlgosTransactionData(
        _ transactionController: TransactionController,
        forTransaction draft: AlgosTransactionSendDraft?
    ) { }
    
    func transactionControllerDidComposedAssetTransactionData(
        _ transactionController: TransactionController,
        forTransaction draft: AssetTransactionSendDraft?
    ) { }
    
    func transactionController(_ transactionController: TransactionController, didFailedComposing error: Error) { }
    
    func transactionController(_ transactionController: TransactionController, didCompletedTransaction id: TransactionID) { }
    
    func transactionController(_ transactionController: TransactionController, didFailedTransaction error: Error) { }
}
