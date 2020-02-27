//
//  LedgerBLEController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 26.02.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Foundation

class LedgerBLEController: NSObject {
    private var mtuSize: UInt16 = 35
    private var expectedNextSequence: UInt16 = 0
    private var responseBytesRemaining: UInt16 = 0
    private var bufferedData = NSMutableData()
    private let maxResponseSize: UInt16 = 65535
    private let minMTU: UInt16 = 20
    private let maxMTU: UInt16 = 100
    
    weak var delegate: LedgerBLEControllerDelegate?
    
    func updateIncomingData(with value: String) {
        guard let unhexData = Data(fromHexEncodedString: value),
            let incomingPacket = self.processNextIncomingPacket(unhexData) else {
            return
        }
        
        print("[Incoming]: \(incomingPacket.toHexString())")
        delegate?.ledgerBLEController(self, received: incomingPacket)
    }
    
    private func resetReceiver() {
        expectedNextSequence = 0
        responseBytesRemaining = 0
        bufferedData = NSMutableData()
    }
}

extension LedgerBLEController {
    func fetchAddress(_ data: Data) {
        let packets = packetizeData(data, maxPacketSize: mtuSize)
        for packet in packets {
            print("[Outgoing]: \(packet.toHexString())")
            delegate?.ledgerBLEController(self, shouldWrite: packet)
        }
    }
    
    func signTransaction(_ data: Data) {
        var packets = [Data]()
        let appPackets = composeSignTransactionPackets(from: data)
        for appPacket in appPackets {
            let subpackets = packetizeData(appPacket, maxPacketSize: mtuSize)
            for subpacket in subpackets {
                packets.append(subpacket)
            }
        }
            
        for packet in packets {
            print("[Outgoing]: \(packet.toHexString())")
            delegate?.ledgerBLEController(self, shouldWrite: packet)
        }
    }
        
    private func fetchMTU() {
        let commands: [UInt8] = [0x08, 0x00, 0x00, 0x00, 0x00]
        let data = NSData(bytes: commands, length: commands.count) as Data
        delegate?.ledgerBLEController(self, shouldWrite: data)
    }
}

extension LedgerBLEController {
    private func processNextIncomingPacket(_ packetdata: Data) -> Data? {
        let messages = [UInt8](packetdata)
        let lenght = messages.count
        var nextOutput = Data()
        var index = 0
        
        if lenght > maxResponseSize {
            resetReceiver()
            return nil
        }
        
        // First byte should be 0x05 (Data) or 0x08 (MTU)
        if (lenght - index) < 1 {
            resetReceiver()
            return nil
        }

        // Handle MTU case
        if messages[index] == 0x08 {
            index += 1
            // Sequence number, length, MTU
            if (lenght - index) < 5 {
                resetReceiver()
                return nil
            }

            // Sequence number should be zero and length should be one
            if messages[index] != 0x00 || messages[index + 1] != 0x00 || messages[index + 2] != 0x00 || messages[index + 3] != 0x01 {
                resetReceiver()
                return nil
            }

            // Last byte is MTU. For some reason the reported MTU from the device is actually too big? So cap it artificially.
            // Might make sense to just always use the protocol minimum of 20 bytes, though that's a little inefficient.
            var mtu = UInt16(messages[index + 4])
            mtu = mtu < minMTU ? minMTU : mtu
            mtu = mtu > maxMTU ? maxMTU : mtu
            mtuSize = mtu
            resetReceiver()
            return nil
        }

        if messages[index] != 0x05 {
            resetReceiver()
            return nil
        }

        index += 1
        
        // Then 2 bytes of sequence number
        if (lenght - index) < 2 {
            resetReceiver()
            return nil
        }
        
        // Parse sequence number
        var sequenceNumber: UInt16 = 0
        sequenceNumber += UInt16(messages[index]) << 8
        sequenceNumber += UInt16(messages[index + 1])
        index += 2

        // Check sequence number
        if sequenceNumber != expectedNextSequence {
            resetReceiver()
            return nil
        }
        
        // Then 2 bytes of length if this is the first packet
        if expectedNextSequence == 0 {
            if (lenght - index) < 2 {
                self.resetReceiver()
                return nil
            }

            // Read off the length and update bytes remaining
            var packetLength: UInt16 = 0
            packetLength += UInt16(messages[index]) << 8
            packetLength += UInt16(messages[index + 1])
            index += 2
            
            responseBytesRemaining = packetLength
        }
        
        // Copy the rest of this packet
        let remainingPacket: UInt16 = UInt16(lenght) - UInt16(index)
        let bytesToCopy = remainingPacket < responseBytesRemaining ? remainingPacket : responseBytesRemaining
        var outBuf = [UInt8](repeating: 0, count: Int(bytesToCopy))
        for i in 0..<bytesToCopy {
            outBuf[Int(i)] = messages[index]
            index += 1
        }
        
        // Append to in memory buffer
        nextOutput = NSData(bytes: outBuf, length: Int(bytesToCopy)) as Data
        bufferedData.append(nextOutput)
        
        // Are there any bytes left?
        responseBytesRemaining -= UInt16(bytesToCopy)
        if responseBytesRemaining == 0 {
            let response = bufferedData as Data
            resetReceiver()
            return response
        }
        
        // Bump sequence number, check for overflow
        expectedNextSequence += 1
        if expectedNextSequence == 0 {
            resetReceiver()
            return nil
        }

        // Not done with packet yet
        return nil
    }
    
    // packetizeData chunks up all of the data we send over BLE.
    private func packetizeData(_ messageData: Data, maxPacketSize: UInt16) -> [Data] {
        let messages = [UInt8](messageData)
        var outputs = [Data]()
        var sequenceIndex: UInt16 = 0
        var offset: UInt64 = 0
        var isFirst = true
        var bytesRemaining = messageData.count
        
        while bytesRemaining > 0 {
            var index = 0
            var packet = [UInt8](repeating: 0, count: Int(maxPacketSize))
            
            // 0x05 Marks application specific data
            packet[index] = 0x05
            index += 1

            // Encode sequence number
            packet[index] = UInt8(sequenceIndex >> 8)
            index += 1
            packet[index] = UInt8(sequenceIndex & 0xFF)
            index += 1

            // If this is the first packet, also encode the total message length
            if isFirst {
                packet[index] = UInt8(messages.count >> 8)
                index += 1
                packet[index] = UInt8(messages.count & 0xFF)
                index += 1
                isFirst = false
            }
            
            // Copy some number of bytes into the packet
            let remainingSpaceInPacket = packet.count - index
            let bytesToCopy = remainingSpaceInPacket < bytesRemaining ? remainingSpaceInPacket : bytesRemaining
            bytesRemaining -= bytesToCopy

            for byteIndex in 0..<bytesToCopy {
                packet[index] = messages[Int(offset) + byteIndex]
                index += 1
            }
            
            sequenceIndex += 1
            offset += UInt64(bytesToCopy)
            
            let data = NSData(bytes: packet, length: index) as Data
            outputs.append(data)
        }
        return outputs
    }
    
    // composeSignTransactionPackets chunks up transaction data at the application layer.
    // The packets generated from this layer should each be sent through packetizeData and transmitted one by one.
    func composeSignTransactionPackets(from transactionData: Data) -> [Data] {
        let msg = [UInt8](transactionData)
        let ledgerClass: UInt8 = 0x80
        let ledgerSignTxn: UInt8 = 0x08
        let ledgerP1First: UInt8 = 0x00
        let ledgerP1More: UInt8 = 0x80
        let ledgerP2Last: UInt8 = 0x00
        let ledgerP2More: UInt8 = 0x80
        let chunkSize: UInt8 = 0xFF
        let headerSize: UInt8 = 0x05

        var outputs = [Data]()
        var bytesRemaining = transactionData.count
        var offset: UInt64 = 0
        var p1 = ledgerP1First
        var p2 = ledgerP2More
        
        while bytesRemaining > 0 {
            var index = 0
            let bytesRemainingWithHeader = bytesRemaining + Int(headerSize)
            let packetSize = bytesRemainingWithHeader < chunkSize ? bytesRemainingWithHeader : Int(chunkSize)
            var packet = [UInt8](repeating: 0, count: Int(packetSize))

            // Copy some number of bytes into the packet
            let remainingSpaceInPacket = packet.count - Int(headerSize)
            let bytesToCopy = remainingSpaceInPacket < bytesRemaining ? remainingSpaceInPacket : bytesRemaining
            bytesRemaining -= bytesToCopy
            
            // Check if this is the last packet
            if bytesRemaining == 0 {
                p2 = ledgerP2Last
            }

            packet[index] = ledgerClass
            index += 1
            packet[index] = ledgerSignTxn
            index += 1
            packet[index] = p1
            index += 1
            packet[index] = p2
            index += 1
            packet[index] = UInt8(bytesToCopy)
            index += 1

            for byteIndex in 0..<bytesToCopy {
                packet[index] = msg[Int(offset) + byteIndex]
                index += 1
            }
            
            p1 = ledgerP1More
            offset += UInt64(bytesToCopy)
            
            let data = NSData(bytes: packet, length: packet.count) as Data
            outputs.append(data)
        }
        return outputs
    }
}

protocol LedgerBLEControllerDelegate: class {
    func ledgerBLEController(_ ledgerBLEController: LedgerBLEController, shouldWrite data: Data)
    func ledgerBLEController(_ ledgerBLEController: LedgerBLEController, received data: Data)
}
