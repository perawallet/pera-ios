//
//  TransactionControllerDelegate.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 28.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie
import CoreBluetooth

protocol TransactionControllerDelegate: class {
    func transactionController(_ transactionController: TransactionController, didComposedTransactionDataFor draft: TransactionSendDraft?)
    func transactionController(_ transactionController: TransactionController, didFailedComposing error: HIPError)
    func transactionController(_ transactionController: TransactionController, didCompletedTransaction id: TransactionID)
    func transactionController(_ transactionController: TransactionController, didFailedTransaction error: HIPError)
    func transactionControllerDidStartBLEConnection(_ transactionController: TransactionController)
    func transactionController(_ transactionController: TransactionController, didFailBLEConnectionWith state: CBManagerState)
    func transactionController(_ transactionController: TransactionController, didFailToConnect peripheral: CBPeripheral)
    func transactionController(_ transactionController: TransactionController, didDisconnectFrom peripheral: CBPeripheral)
    func transactionControllerDidFailToSignWithLedger(_ transactionController: TransactionController)
}

extension TransactionControllerDelegate where Self: BaseViewController {
    func transactionController(
        _ transactionController: TransactionController,
        didComposedTransactionDataFor draft: TransactionSendDraft?
    ) { }
    
    func transactionController(_ transactionController: TransactionController, didFailedComposing error: HIPError) { }
    
    func transactionController(_ transactionController: TransactionController, didCompletedTransaction id: TransactionID) { }
    
    func transactionController(_ transactionController: TransactionController, didFailedTransaction error: HIPError) { }
    
    func transactionControllerDidStartBLEConnection(_ transactionController: TransactionController) { }
    
    func transactionController(_ transactionController: TransactionController, didFailBLEConnectionWith state: CBManagerState) { }
    
    func transactionController(_ transactionController: TransactionController, didFailToConnect peripheral: CBPeripheral) { }
    
    func transactionController(_ transactionController: TransactionController, didDisconnectFrom peripheral: CBPeripheral) { }
    
    func transactionControllerDidFailToSignWithLedger(_ transactionController: TransactionController) { }
}
