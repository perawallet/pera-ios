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
    func transactionController(_ transactionController: TransactionController, didFailedComposing error: Error)
    func transactionController(_ transactionController: TransactionController, didCompletedTransaction id: TransactionID)
    func transactionController(_ transactionController: TransactionController, didFailedTransaction error: Error)
    func transactionController(_ transactionController: TransactionController, didFailBLEConnectionWith state: CBManagerState)
    func transactionController(_ transactionController: TransactionController, didFailToConnect peripheral: CBPeripheral)
    func transactionController(_ transactionController: TransactionController, didDisconnectFrom peripheral: CBPeripheral)
}

extension TransactionControllerDelegate where Self: BaseViewController {
    func transactionController(
        _ transactionController: TransactionController,
        didComposedTransactionDataFor draft: TransactionSendDraft?
    ) { }
    
    func transactionController(_ transactionController: TransactionController, didFailedComposing error: Error) { }
    
    func transactionController(_ transactionController: TransactionController, didCompletedTransaction id: TransactionID) { }
    
    func transactionController(_ transactionController: TransactionController, didFailedTransaction error: Error) { }
    
    func transactionController(_ transactionController: TransactionController, didFailBLEConnectionWith state: CBManagerState) {
        switch state {
        case .poweredOff:
            displaySimpleAlertWith(title: "title-error".localized, message: "ble-error-fail-ble-connection-power".localized)
        case .unsupported:
            displaySimpleAlertWith(title: "title-error".localized, message: "ble-error-fail-ble-connection-unsupported".localized)
        case .unknown:
            displaySimpleAlertWith(title: "title-error".localized, message: "ble-error-fail-ble-connection-unknown".localized)
        case .unauthorized:
            displaySimpleAlertWith(title: "title-error".localized, message: "ble-error-fail-ble-connection-unauthorized".localized)
        case .resetting:
            displaySimpleAlertWith(title: "title-error".localized, message: "ble-error-fail-ble-connection-resetting".localized)
        default:
            return
        }
    }
    
    func transactionController(_ transactionController: TransactionController, didFailToConnect peripheral: CBPeripheral) {
        displaySimpleAlertWith(title: "title-error".localized, message: "ble-error-fail-connect-peripheral".localized)
    }
    
    func transactionController(_ transactionController: TransactionController, didDisconnectFrom peripheral: CBPeripheral) {
        displaySimpleAlertWith(title: "title-error".localized, message: "ble-error-disconnected-peripheral".localized)
    }
}
