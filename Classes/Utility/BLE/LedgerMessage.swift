//
//  LedgerConstants.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 16.12.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Foundation

enum LedgerMessage {
    enum Instruction {
        static let sign: Byte = 0x08
        static let publicKey: Byte = 0x03
        
        static func addressFetch(for index: Int) -> Data {
            var addressFetchInstruction = Data(bytes: [LedgerMessage.CLA.algorand, Instruction.publicKey, 0x00, 0x00, Size.accountIndex])
            addressFetchInstruction.append(contentsOf: index.toByteArray())
            return addressFetchInstruction
        }
    }
    
    enum Response {
        static let ledgerError = "6e00"
        static let ledgerTransactionCancelled = "6985"
    }
    
    enum Size {
        static let address = 34
        static let error = 2
        static let chunk: Byte = 0xFF
        static let header: Byte = 0x05
        static let accountIndex: Byte = 0x04
    }
    
    enum Paging {
        static let p1First: Byte = 0x00
        static let p1Transaction: Byte = 0x01
        static let p1More: Byte = 0x80
        static let p2Last: Byte = 0x00
        static let p2More: Byte = 0x80
    }
    
    enum MTU {
        static let `default` = 23
        static let min = 23
        static let max = 100
        static let offset = 5
    }

    enum CLA {
        static let ledger: Byte = 0x08
        static let data: Byte = 0x05
        static let algorand: Byte = 0x80
    }
}
