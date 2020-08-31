//
//  BLEConnectionManager.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 25.02.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit
import CoreBluetooth

class BLEConnectionManager: NSObject {
    weak var delegate: BLEConnectionManagerDelegate?
    
    private var centralManager: CBCentralManager?
    private var connectedPeripheral: CBPeripheral?
    
    private var txCharacteristic: CBCharacteristic?
    private var rxCharacteristic: CBCharacteristic?
    
    private var peripherals: [CBPeripheral] = []
    private var isScanning = false
    private var isDisconnectedInternally = false
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
}

extension BLEConnectionManager {
    func startScanForPeripherals() {
        if !isScanning {
            isScanning = true
            peripherals = []
            centralManager?.scanForPeripherals(
                withServices: [bleServiceUuid],
                options: [CBCentralManagerScanOptionAllowDuplicatesKey: false]
            )
        }
    }
    
    func stopScan() {
        isScanning = false
        centralManager?.stopScan()
    }
    
    func connectToDevice(_ peripheral: CBPeripheral) {
        centralManager?.connect(peripheral)
    }
    
    func disconnect(from connectedPeripheral: CBPeripheral?) {
        if let peripheral = connectedPeripheral {
            isDisconnectedInternally = true
            centralManager?.cancelPeripheralConnection(peripheral)
            self.connectedPeripheral = nil
        }
    }
    
    func write(_ data: Data) {
        if let txCharacteristic = txCharacteristic {
            connectedPeripheral?.writeValue(data, for: txCharacteristic, type: CBCharacteristicWriteType.withResponse)
        }
    }
}

extension BLEConnectionManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            startScanForPeripherals()
        } else {
            delegate?.bleConnectionManager(self, didFailBLEConnectionWith: central.state)
        }
    }
    
    func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi RSSI: NSNumber
    ) {
        peripherals.append(peripheral)
        delegate?.bleConnectionManager(self, didDiscover: peripherals)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        stopScan()
        connectedPeripheral = peripheral
        isDisconnectedInternally = false
        peripheral.delegate = self
        peripheral.discoverServices([bleServiceUuid])
        
        delegate?.bleConnectionManager(self, didConnect: peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        delegate?.bleConnectionManager(self, didFailToConnect: peripheral, with: error)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if isDisconnectedInternally {
            return
        }
        
        if peripheral.identifier == connectedPeripheral?.identifier {
            connectedPeripheral = nil
        }
        
        delegate?.bleConnectionManager(self, didDisconnectFrom: peripheral, with: error)
    }
}

extension BLEConnectionManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else {
            return
        }
        
        discoverCharacteristics(peripheral, of: services)
    }
    
    private func discoverCharacteristics(_ peripheral: CBPeripheral, of services: [CBService]) {
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if error != nil {
            return
        }
        
        guard let characteristics = service.characteristics else {
            return
        }
        
        processCharacteristics(peripheral, of: characteristics)
    }
    
    private func processCharacteristics(_ peripheral: CBPeripheral, of characteristics: [CBCharacteristic]) {
        for characteristic in characteristics {
            if characteristic.uuid.isEqual(bleCharacteristicUuidRx) {
                rxCharacteristic = characteristic
                
                guard let rxCharacteristic = rxCharacteristic else {
                    return
                }
                
                peripheral.setNotifyValue(true, for: rxCharacteristic)
                peripheral.readValue(for: rxCharacteristic)
            }
            
            if characteristic.uuid.isEqual(bleCharacteristicUuidTx) {
                txCharacteristic = characteristic
                
                /// Can write a data to the device since txCharacteristic is set.
                delegate?.bleConnectionManagerEnabledToWrite(self)
            }
            peripheral.discoverDescriptors(for: characteristic)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        /// If it returns error, we should skip, whether it has value or not.
        /// Otherwise it will send the old value
        if error != nil {
            return
        }
        
        if characteristic == rxCharacteristic {
            guard let characteristicData = characteristic.value else {
                return
            }
            
            delegate?.bleConnectionManager(self, didRead: characteristicData.toHexString())
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
   
    }
}

protocol BLEConnectionManagerDelegate: class {
    typealias BLEError = Error
    
    func bleConnectionManager(_ bleConnectionManager: BLEConnectionManager, didDiscover peripherals: [CBPeripheral])
    func bleConnectionManager(_ bleConnectionManager: BLEConnectionManager, didConnect peripheral: CBPeripheral)
    func bleConnectionManagerEnabledToWrite(_ bleConnectionManager: BLEConnectionManager)
    func bleConnectionManager(_ bleConnectionManager: BLEConnectionManager, didRead string: String)
    func bleConnectionManager(_ bleConnectionManager: BLEConnectionManager, didFailBLEConnectionWith state: CBManagerState)
    func bleConnectionManager(
        _ bleConnectionManager: BLEConnectionManager,
        didFailToConnect peripheral: CBPeripheral,
        with error: BLEError?
    )
    func bleConnectionManager(
        _ bleConnectionManager: BLEConnectionManager,
        didDisconnectFrom peripheral: CBPeripheral,
        with error: BLEError?
    )
}
