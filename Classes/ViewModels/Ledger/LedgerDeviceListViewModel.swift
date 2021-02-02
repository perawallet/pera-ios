//
//  LedgerDeviceListViewModel.swift

import CoreBluetooth

class LedgerDeviceListViewModel {
    private(set) var ledgerName: String?

    init(peripheral: CBPeripheral) {
        setLedgerName(from: peripheral)
    }

    private func setLedgerName(from peripheral: CBPeripheral) {
        self.ledgerName = peripheral.name
    }
}
