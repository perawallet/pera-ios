//
//  LedgerOperation.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 4.12.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit
import CoreBluetooth

protocol LedgerOperation: class {
    func startOperation()
    func completeOperation(with data: Data)
    func handleDiscoveryResults(_ peripherals: [CBPeripheral])
    func reset()
    
    var ledgerApprovalViewController: LedgerApprovalViewController? { get set }
    
    var timer: Timer? { get set }
    func startTimer()
    func stopTimer()
    
    var connectedDevice: CBPeripheral? { get set }
    
    var bleConnectionManager: BLEConnectionManager { get }
    var ledgerBleController: LedgerBLEController { get }
}

extension LedgerOperation {
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 15.0, repeats: false) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            DispatchQueue.main.async {
                self.topMostController?.dismissProgressIfNeeded()
                self.bleConnectionManager.stopScan()
                NotificationBanner.showError("ble-error-connection-title".localized, message: "ble-error-fail-connect-peripheral".localized)
            }
            
            self.stopTimer()
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

extension LedgerOperation {
    func startScan() {
        bleConnectionManager.startScanForPeripherals()
    }
    
    func stopScan() {
        bleConnectionManager.stopScan()
    }
    
    func connectToDevice(_ peripheral: CBPeripheral) {
        bleConnectionManager.connectToDevice(peripheral)
    }
    
    func disconnectFromCurrentDevice() {
        bleConnectionManager.disconnect(from: connectedDevice)
    }
    
    var topMostController: UIViewController? {
        return UIApplication.shared.rootViewController()?.topMostController
    }
}

extension LedgerOperation where Self: BLEConnectionManagerDelegate {
    func bleConnectionManager(_ bleConnectionManager: BLEConnectionManager, didDiscover peripherals: [CBPeripheral]) {
        handleDiscoveryResults(peripherals)
    }
    
    func bleConnectionManager(_ bleConnectionManager: BLEConnectionManager, didConnect peripheral: CBPeripheral) {
        connectedDevice = peripheral
        topMostController?.dismissProgressIfNeeded()
        stopTimer()
        presentLedgerApprovalModal()
    }
    
    func bleConnectionManagerEnabledToWrite(_ bleConnectionManager: BLEConnectionManager) {
        startOperation()
    }
    
    func bleConnectionManager(_ bleConnectionManager: BLEConnectionManager, didRead string: String) {
        ledgerBleController.readIncomingData(with: string)
    }
    
    func bleConnectionManager(_ bleConnectionManager: BLEConnectionManager, didFailWith error: BLEConnectionManager.BLEError) {
        switch error {
        case let .failedBLEConnection(state):
            guard let errorTitle = state.errorDescription.title,
                let errorSubtitle = state.errorDescription.subtitle else {
                    return
            }
            
            NotificationBanner.showError(errorTitle, message: errorSubtitle)
            stopTimer()
            topMostController?.dismissProgressIfNeeded()
        default:
            reset()
            NotificationBanner.showError("ble-error-connection-title".localized, message: "ble-error-fail-connect-peripheral".localized)
        }
    }
}

extension LedgerOperation where Self: LedgerBLEControllerDelegate {
    func ledgerBLEController(_ ledgerBLEController: LedgerBLEController, shouldWrite data: Data) {
        bleConnectionManager.sendDataToPeripheral(data)
    }
    
    func ledgerBLEController(_ ledgerBLEController: LedgerBLEController, didReceive data: Data) {
        if data.isErrorResponseFromLedger {
            displayLedgerError(for: data)
            return
        }
        
        completeOperation(with: data)
    }
}

extension LedgerOperation {
    private func presentLedgerApprovalModal() {
        let ledgerApprovalPresenter = CardModalPresenter(
            config: ModalConfiguration(
                animationMode: .normal(duration: 0.25),
                dismissMode: .none
            ),
            initialModalSize: .custom(CGSize(width: UIScreen.main.bounds.width, height: 354.0))
        )
        ledgerApprovalViewController = topMostController?.open(
            .ledgerApproval(mode: .approve),
            by: .customPresent(presentationStyle: .custom, transitionStyle: nil, transitioningDelegate: ledgerApprovalPresenter)
        ) as? LedgerApprovalViewController
    }
    
    private func displayLedgerError(for data: Data) {
        reset()
        
        if data.isLedgerTransactionCancelledError {
            NotificationBanner.showError(
                "ble-error-transaction-cancelled-title".localized,
                message: "ble-error-fail-sign-transaction".localized
            )
        } else {
            NotificationBanner.showError(
                "ble-error-ledger-connection-title".localized,
                message: "ble-error-ledger-connection-open-app-error".localized
            )
        }
    }
}

enum LedgerOperationError: Error {
    case connection
    case failedToFetchAddress
    case failedToSign
    case unknown
    case unmatchedAddress
}
