//
//  LedgerUUIDKey.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 26.02.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import CoreBluetooth

let bleServiceUuidText = "13D63400-2C97-0004-0000-4C6564676572"
let bleCharacteristicUuidTxText = "13D63400-2C97-0004-0002-4C6564676572"
let bleCharacteristicUuidRxText = "13D63400-2C97-0004-0001-4C6564676572"

let bleServiceUuid = CBUUID(string: bleServiceUuidText)
let bleCharacteristicUuidTx = CBUUID(string: bleCharacteristicUuidTxText)
let bleCharacteristicUuidRx = CBUUID(string: bleCharacteristicUuidRxText)

let bleLedgerAddressMessage = "8003"
let ledgerErrorResponse = "6e00"
