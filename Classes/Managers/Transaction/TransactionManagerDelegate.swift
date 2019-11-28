//
//  TransactionManagerDelegate.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 28.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

protocol TransactionManagerDelegate: class {
    func transactionManagerDidComposedAlgoTransactionData(
        _ transactionManager: TransactionManager,
        forTransaction draft: TransactionPreviewDraft?
    )
    func transactionManagerDidComposedAssetTransactionData(
        _ transactionManager: TransactionManager,
        forTransaction draft: AssetTransactionDraft?
    )
    func transactionManager(_ transactionManager: TransactionManager, didFailedComposing error: Error)
    func transactionManager(_ transactionManager: TransactionManager, didCompletedTransaction id: TransactionID)
    func transactionManager(_ transactionManager: TransactionManager, didFailedTransaction error: Error)
}

extension TransactionManagerDelegate {
    func transactionManagerDidComposedAlgoTransactionData(
        _ transactionManager: TransactionManager,
        forTransaction draft: TransactionPreviewDraft?
    ) {
        
    }
    
    func transactionManagerDidComposedAssetTransactionData(
        _ transactionManager: TransactionManager,
        forTransaction draft: AssetTransactionDraft?
    ) {
        
    }
    
    func transactionManager(_ transactionManager: TransactionManager, didFailedComposing error: Error) {
        
    }
    
    func transactionManager(_ transactionManager: TransactionManager, didCompletedTransaction id: TransactionID) {
        
    }
    
    func transactionManager(_ transactionManager: TransactionManager, didFailedTransaction error: Error) {
        
    }
}
