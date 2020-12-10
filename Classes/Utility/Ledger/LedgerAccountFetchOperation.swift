//
//  LedgerAccountFetchOperation.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 4.12.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit
import CoreBluetooth

class LedgerAccountFetchOperation: LedgerOperation, BLEConnectionManagerDelegate, LedgerBLEControllerDelegate {
    
    let bleConnectionManager = BLEConnectionManager()
    let ledgerBleController = LedgerBLEController()
    
    var ledgerApprovalViewController: LedgerApprovalViewController?
    
    var timer: Timer?
    var connectedDevice: CBPeripheral?
    
    weak var delegate: LedgerAccountFetchOperationDelegate?
    
    private let api: AlgorandAPI
    
    init(api: AlgorandAPI) {
        self.api = api
        bleConnectionManager.delegate = self
        ledgerBleController.delegate = self
    }
}

extension LedgerAccountFetchOperation {
    func startOperation() {
        ledgerBleController.fetchAddress()
    }
    
    func completeOperation(with data: Data) {
        guard let address = parseAddress(from: data) else {
            NotificationBanner.showError(
                "ble-error-transmission-title".localized,
                message: "ble-error-fail-fetch-account-address".localized
            )
            reset()
            delegate?.ledgerAccountFetchOperation(self, didFailed: .failedToFetchAddress)
            return
        }
        
        delegate?.ledgerAccountFetchOperation(self, didReceive: address, in: ledgerApprovalViewController)
    }
    
    func handleDiscoveryResults(_ peripherals: [CBPeripheral]) {
        delegate?.ledgerAccountFetchOperation(self, didDiscover: peripherals)
    }
    
    func reset() {
        connectedDevice = nil
        stopScan()
        disconnectFromCurrentDevice()
        ledgerApprovalViewController?.dismissIfNeeded()
    }
}

extension LedgerAccountFetchOperation {
    private func parseAddress(from data: Data) -> String? {
        /// Remove last two bytes to fetch data since it declares status codes.
        var mutableData = data
        mutableData.removeLast(2)
        
        var error: NSError?
        let address = AlgorandSDK().addressFromPublicKey(mutableData, error: &error)
        
        if error != nil || !AlgorandSDK().isValidAddress(address) {
            return nil
        }
        
        return address
    }
}

protocol LedgerAccountFetchOperationDelegate: class {
    func ledgerAccountFetchOperation(
        _ ledgerAccountFetchOperation: LedgerAccountFetchOperation,
        didReceive address: String,
        in ledgerApprovalViewController: LedgerApprovalViewController?
    )
    func ledgerAccountFetchOperation(_ ledgerAccountFetchOperation: LedgerAccountFetchOperation, didDiscover peripherals: [CBPeripheral])
    func ledgerAccountFetchOperation(_ ledgerAccountFetchOperation: LedgerAccountFetchOperation, didFailed error: LedgerOperationError)
}
