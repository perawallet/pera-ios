//
//  TransactionControllerDelegate.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 28.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

protocol TransactionControllerDelegate: class {
    func transactionControllerDidComposedAlgoTransactionData(
        _ transactionController: TransactionController,
        forTransaction draft: TransactionPreviewDraft?
    )
    func transactionControllerDidComposedAssetTransactionData(
        _ transactionController: TransactionController,
        forTransaction draft: AssetTransactionDraft?
    )
    func transactionController(_ transactionController: TransactionController, didFailedComposing error: Error)
    func transactionController(_ transactionController: TransactionController, didCompletedTransaction id: TransactionID)
    func transactionController(_ transactionController: TransactionController, didFailedTransaction error: Error)
}

extension TransactionControllerDelegate {
    func transactionControllerDidComposedAlgoTransactionData(
        _ transactionController: TransactionController,
        forTransaction draft: TransactionPreviewDraft?
    ) {
        
    }
    
    func transactionControllerDidComposedAssetTransactionData(
        _ transactionController: TransactionController,
        forTransaction draft: AssetTransactionDraft?
    ) {
        
    }
    
    func transactionController(_ transactionController: TransactionController, didFailedComposing error: Error) {
        
    }
    
    func transactionController(_ transactionController: TransactionController, didCompletedTransaction id: TransactionID) {
        
    }
    
    func transactionController(_ transactionController: TransactionController, didFailedTransaction error: Error) {
        
    }
}
