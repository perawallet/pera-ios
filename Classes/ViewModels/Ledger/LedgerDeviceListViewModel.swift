//
//  LedgerDeviceListViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 23.02.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

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
