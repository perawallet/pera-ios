//
//  LedgerTransactionOperation.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 4.12.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit
import CoreBluetooth

class LedgerTransactionOperation: LedgerOperation, BLEConnectionManagerDelegate, LedgerBLEControllerDelegate {
    var bleConnectionManager: BLEConnectionManager {
        return accountFetchOperation.bleConnectionManager
    }
    
    var ledgerBleController: LedgerBLEController {
        return accountFetchOperation.ledgerBleController
    }
    
    var ledgerApprovalViewController: LedgerApprovalViewController?
    
    var timer: Timer?
    var connectedDevice: CBPeripheral?
    
    private var isCorrectLedgerAddressFetched = false
    
    weak var delegate: LedgerTransactionOperationDelegate?
    
    private let api: AlgorandAPI
    
    private var account: Account?
    private var unsignedTransactionData: Data?
    
    private lazy var accountFetchOperation = LedgerAccountFetchOperation(api: api)
    
    init(api: AlgorandAPI) {
        self.api = api
        bleConnectionManager.delegate = self
        ledgerBleController.delegate = self
        accountFetchOperation.delegate = self
    }
    
    func setUnsignedTransactionData(_ unsignedTransaction: Data?) {
        self.unsignedTransactionData = unsignedTransaction
    }
    
    func setTransactionAccount(_ account: Account) {
        self.account = account
    }
}

extension LedgerTransactionOperation {
    func startOperation() {
        if isCorrectLedgerAddressFetched {
            sendTransactionSignInstruction()
        } else {
            accountFetchOperation.startOperation()
        }
    }
    
    func completeOperation(with data: Data) {
        if !isCorrectLedgerAddressFetched {
            accountFetchOperation.completeOperation(with: data)
            return
        }
        
        reset()
        
        guard let signature = parseSignedTransaction(from: data) else {
            delegate?.ledgerTransactionOperation(self, didFailed: .failedToSign)
            return
        }
        
        delegate?.ledgerTransactionOperation(self, didReceiveSignature: signature)
    }
    
    func handleDiscoveryResults(_ peripherals: [CBPeripheral]) {
        guard let savedPeripheralId = account?.ledgerDetail?.id,
              let savedPeripheral = peripherals.first(where: { $0.identifier == savedPeripheralId }) else {
            return
        }
        
        bleConnectionManager.connectToDevice(savedPeripheral)
    }
    
    func reset() {
        accountFetchOperation.reset()
        stopScan()
        disconnectFromCurrentDevice()
        unsignedTransactionData = nil
        ledgerApprovalViewController?.dismissIfNeeded()
        connectedDevice = nil
        isCorrectLedgerAddressFetched = false
    }
}

extension LedgerTransactionOperation {
    private func sendTransactionSignInstruction() {
        guard let hexString = unsignedTransactionData?.toHexString(),
            let unsignedTransaction = Data(fromHexEncodedString: hexString) else {
            return
        }
        
        ledgerBleController.signTransaction(unsignedTransaction)
    }
    
    private func parseSignedTransaction(from data: Data) -> Data? {
        if data.isLedgerTransactionCancelledError || data.isLedgerError {
            return nil
        }
        
        /// Remove last two bytes to fetch data since it declares status codes.
        var signatureData = data
        signatureData.removeLast(2)
      
        if signatureData.isEmpty {
            return nil
        }
        
        return signatureData
    }
}

extension LedgerTransactionOperation: LedgerAccountFetchOperationDelegate {
    func ledgerAccountFetchOperation(
        _ ledgerAccountFetchOperation: LedgerAccountFetchOperation,
        didReceive address: String,
        in ledgerApprovalViewController: LedgerApprovalViewController?
    ) {
        guard let account = account else {
            return
        }
        
        isCorrectLedgerAddressFetched = account.authAddress.unwrap(or: account.address) == address
        proceedSigningTransactionByLedgerIfPossible()
    }
    
    private func proceedSigningTransactionByLedgerIfPossible() {
        if isCorrectLedgerAddressFetched {
            sendTransactionSignInstruction()
        } else {
            NotificationBanner.showError(
                "ble-error-ledger-connection-title".localized,
                message: "ledger-transaction-account-match-error".localized
            )
            reset()
            delegate?.ledgerTransactionOperation(self, didFailed: .unmatchedAddress)
        }
    }
    
    func ledgerAccountFetchOperation(_ ledgerAccountFetchOperation: LedgerAccountFetchOperation, didDiscover peripherals: [CBPeripheral]) {
    }
    
    func ledgerAccountFetchOperation(_ ledgerAccountFetchOperation: LedgerAccountFetchOperation, didFailed error: LedgerOperationError) {
        reset()
        delegate?.ledgerTransactionOperation(self, didFailed: error)
    }
}

protocol LedgerTransactionOperationDelegate: class {
    func ledgerTransactionOperation(_ ledgerTransactionOperation: LedgerTransactionOperation, didReceiveSignature data: Data)
    func ledgerTransactionOperation(_ ledgerTransactionOperation: LedgerTransactionOperation, didFailed error: LedgerOperationError)
}
