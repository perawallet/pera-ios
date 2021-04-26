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
//   LedgerAccountVerifyOperation.swift

import UIKit
import CoreBluetooth

class LedgerAccountVerifyOperation: LedgerOperation, BLEConnectionManagerDelegate, LedgerBLEControllerDelegate {

    let bleConnectionManager = BLEConnectionManager()
    let ledgerBleController = LedgerBLEController()

    var ledgerApprovalViewController: LedgerApprovalViewController?

    var ledgerMode: LedgerApprovalViewController.Mode {
        return .connection
    }

    var timer: Timer?
    var connectedDevice: CBPeripheral?

    private var ledgerAccounts = [Account]()
    private var accountIndex: Int {
        return ledgerAccounts.count
    }

    weak var delegate: LedgerAccountVerifyOperationDelegate?

    private let api: AlgorandAPI
    private let ledgerDetail: LedgerDetail

    init(api: AlgorandAPI, ledgerDetail: LedgerDetail) {
        self.api = api
        self.ledgerDetail = ledgerDetail
        bleConnectionManager.delegate = self
        ledgerBleController.delegate = self
    }
}

extension LedgerAccountVerifyOperation {
    func startOperation() {
        ledgerBleController.verifyAddress(at: accountIndex)
    }

    func completeOperation(with data: Data) {
        guard let address = parseAddress(from: data) else {
            NotificationBanner.showError(
                "ble-error-transmission-title".localized,
                message: "ble-error-fail-fetch-account-address".localized
            )
            reset()
            delegate?.ledgerAccountVerifyOperation(self, didFailed: .failedToFetchAddress)
            return
        }

        delegate?.ledgerAccountVerifyOperation(self, didVerify: address)
    }

    func handleDiscoveryResults(_ peripherals: [CBPeripheral]) {
        guard let savedPeripheralId = ledgerDetail.id,
              let savedPeripheral = peripherals.first(where: { $0.identifier == savedPeripheralId }) else {
            return
        }

        bleConnectionManager.connectToDevice(savedPeripheral)
    }

    func reset() {
        connectedDevice = nil
        stopScan()
        disconnectFromCurrentDevice()
        ledgerApprovalViewController?.dismissIfNeeded()
        ledgerAccounts.removeAll()
    }
}

protocol LedgerAccountVerifyOperationDelegate: class {
    func ledgerAccountVerifyOperation(_ ledgerAccountVerifyOperation: LedgerAccountVerifyOperation, didVerify account: String)
    func ledgerAccountVerifyOperation(_ ledgerAccountVerifyOperation: LedgerAccountVerifyOperation, didFailed error: LedgerOperationError)
}
