// Copyright 2019 Algorand, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//  LedgerOperation.swift

import UIKit
import CoreBluetooth

protocol LedgerOperation: AnyObject {
    func startOperation()
    func completeOperation(with data: Data)
    func handleDiscoveryResults(_ peripherals: [CBPeripheral])
    func reset()

    var shouldDisplayLedgerApprovalModal: Bool { get }
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
                (self.topMostController as? BaseViewController)?.loadingController?.stopLoading()
                self.bleConnectionManager.stopScan()

                (self.topMostController as? BaseViewController)?.bannerController?.presentErrorBanner(
                    title: "ble-error-connection-title".localized,
                    message: ""
                )

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.presentConnectionSupportWarningAlert()
                }
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
        (self.topMostController as? BaseViewController)?.loadingController?.stopLoading()
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

            (self.topMostController as? BaseViewController)?.bannerController?.presentErrorBanner(title: errorTitle, message: errorSubtitle)
            stopTimer()
            (self.topMostController as? BaseViewController)?.loadingController?.stopLoading()
        default:
            reset()
            (self.topMostController as? BaseViewController)?.bannerController?.presentErrorBanner(
                title: "ble-error-connection-title".localized,
                message: "".localized
            )

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.presentConnectionSupportWarningAlert()
            }
        }
    }
}

extension LedgerOperation where Self: LedgerBLEControllerDelegate {
    func ledgerBLEController(_ ledgerBLEController: LedgerBLEController, shouldWrite data: Data) {
        bleConnectionManager.sendDataToPeripheral(data)
    }
    
    func ledgerBLEController(_ ledgerBLEController: LedgerBLEController, didReceive data: Data) {
        completeOperation(with: data)
    }
}

extension LedgerOperation {
    func parseAddress(from data: Data) -> String? {
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

extension LedgerOperation {
    private func presentLedgerApprovalModal() {
        if !shouldDisplayLedgerApprovalModal {
            return
        }
        
        if let presentingViewController = topMostController {
            let ledgerApprovalTransition = BottomSheetTransition(presentingViewController: presentingViewController)
            ledgerApprovalViewController = ledgerApprovalTransition.perform(
                .ledgerApproval(mode: .approve, deviceName: (connectedDevice?.name).emptyIfNil)
            )
        }
    }

    private func presentConnectionSupportWarningAlert() {
        if let presentingViewController = topMostController {
           let warningModalTransition = BottomSheetTransition(presentingViewController: presentingViewController)

            // These texts won't be localized for now
            let message = """
            Make sure the device is unlocked, nearby and has bluetooth enabled. If problems persist, please remove the device from your phone’s
            bluetooth settings, remove the ledger account, and then re-pair your Ledger following the Algorand Wallet instructions.
            """

            let warningAlert = WarningAlert(
                title: "Having Ledger Nano X connection issues?",
                image: img("img-warning-circle"),
                description: message,
                actionTitle: "title-ok".localized
            )

            warningModalTransition.perform(.warningAlert(warningAlert: warningAlert))
        }
    }
}

enum LedgerOperationError: Error {
    case connection
    case failedToFetchAddress
    case cancelled
    case closedApp
    case failedToSign
    case unknown
    case unmatchedAddress
}
