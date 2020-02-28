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
    private var centralManager: CBCentralManager?
    private var blePeripheral: CBPeripheral?
    
    weak var delegate: BLEConnectionManagerDelegate?
    
    private var txCharacteristic: CBCharacteristic?
    private var rxCharacteristic: CBCharacteristic?
    
    private var peripherals: [CBPeripheral] = []
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
}

extension BLEConnectionManager {
    func startScanForPeripherals() {
        peripherals = []
        centralManager?.scanForPeripherals(withServices: [bleServiceUuid], options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
    }
    
    func stopScan() {
        centralManager?.stopScan()
    }
    
    func connectToDevice(_ peripheral: CBPeripheral) {
        centralManager?.connect(peripheral)
    }
    
    func disconnectFromDevice(_ peripheral: CBPeripheral) {
        centralManager?.cancelPeripheralConnection(peripheral)
    }
    
    func write(_ data: Data) {
        if let txCharacteristic = txCharacteristic {
            blePeripheral?.writeValue(data, for: txCharacteristic, type: CBCharacteristicWriteType.withResponse)
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
        print("Found new pheripheral devices with services")
        print("Peripheral name: \(String(describing: peripheral.name))")
        print("Advertisement Data: \(advertisementData)")
        
        blePeripheral = peripheral
        peripherals.append(peripheral)
        peripheral.delegate = self
        delegate?.bleConnectionManager(self, didDiscover: peripherals)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connection complete")
        print("Peripheral info: \(String(describing: blePeripheral))")
        centralManager?.stopScan()
        peripheral.delegate = self
        peripheral.discoverServices([bleServiceUuid])
        delegate?.bleConnectionManager(self, didConnect: peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        if error != nil {
            print("Failed to connect to peripheral")
        }
        delegate?.bleConnectionManager(self, didFailToConnect: peripheral, with: error)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected")
        delegate?.bleConnectionManager(self, didDisconnectFrom: peripheral, with: error)
    }
}

extension BLEConnectionManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("Error discovering services: \(error.localizedDescription)")
            return
        }
        
        guard let services = peripheral.services else {
            return
        }
        
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
        
        print("Discovered Services: \(services)")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            print("\(error.debugDescription)")
            return
        }
        
        guard let descriptors = characteristic.descriptors else {
            return
        }
        
        for descriptor in descriptors {
            let descript = descriptor as CBDescriptor
            print("function name: DidDiscoverDescriptorForChar \(String(describing: descript.description))")
            print("Rx Value \(String(describing: rxCharacteristic?.value))")
            print("Tx Value \(String(describing: txCharacteristic?.value))")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("Error discovering characteristics: \(error.localizedDescription)")
            return
        }
        
        guard let characteristics = service.characteristics else {
            return
        }
        
        print("Found \(characteristics.count) characteristics!")
        
        for characteristic in characteristics {
            if characteristic.uuid.isEqual(bleCharacteristicUuidRx) {
                rxCharacteristic = characteristic
                
                guard let rxCharacteristic = rxCharacteristic else {
                    return
                }
                
                peripheral.setNotifyValue(true, for: rxCharacteristic)
                peripheral.readValue(for: rxCharacteristic)
                print("Rx Characteristic: \(characteristic.uuid)")
            }
            if characteristic.uuid.isEqual(bleCharacteristicUuidTx) {
                txCharacteristic = characteristic
                print("Tx Characteristic: \(characteristic.uuid)")
            }
            peripheral.discoverDescriptors(for: characteristic)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic == rxCharacteristic {
           guard let characteristicData = characteristic.value else {
                return
            }
            
            let readData = characteristicData.toHexString()
            print("Value Recieved: \(readData)")
            
            delegate?.bleConnectionManager(self, didRead: readData)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            print("Error changing notification state:\(String(describing: error?.localizedDescription))")
        } else {
            print("Characteristic's value subscribed")
        }
        
        if characteristic.isNotifying {
            print("Subscribed. Notification has begun for: \(characteristic.uuid)")
        }
    }
}

protocol BLEConnectionManagerDelegate: class {
    func bleConnectionManager(_ bleConnectionManager: BLEConnectionManager, didConnect peripheral: CBPeripheral)
    func bleConnectionManager(_ bleConnectionManager: BLEConnectionManager, didDiscover peripherals: [CBPeripheral])
    func bleConnectionManager(_ bleConnectionManager: BLEConnectionManager, didFailBLEConnectionWith state: CBManagerState)
    func bleConnectionManager(_ bleConnectionManager: BLEConnectionManager, didRead string: String)
    func bleConnectionManager(_ bleConnectionManager: BLEConnectionManager, didFailToConnect peripheral: CBPeripheral, with error: Error?)
    func bleConnectionManager(_ bleConnectionManager: BLEConnectionManager, didDisconnectFrom peripheral: CBPeripheral, with error: Error?)
}

extension BLEConnectionManagerDelegate {
    func bleConnectionManager(_ bleConnectionManager: BLEConnectionManager, didDiscover peripherals: [CBPeripheral]) { }
    
    func bleConnectionManager(
        _ bleConnectionManager: BLEConnectionManager,
        didDisconnectFrom peripheral: CBPeripheral,
        with error: Error?
    ) { }
    
    func bleConnectionManager(
        _ bleConnectionManager: BLEConnectionManager,
        didFailToConnect peripheral: CBPeripheral,
        with error: Error?
    ) { }
}
