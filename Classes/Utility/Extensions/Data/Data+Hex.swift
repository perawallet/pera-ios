//
//  Data+Hex.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 26.02.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Foundation

extension Data {
    init?(fromHexEncodedString string: String) {
        self.init(capacity: string.utf16.count / 2)
        
        var isEven = true
        var byte: UInt8 = 0
        for character in string.utf16 {
            guard let decodedValue = decodeNibble(character) else {
                return nil
            }
            
            if isEven {
                byte = decodedValue << 4
            } else {
                byte += decodedValue
                append(byte)
            }
            
            isEven = !isEven
        }
        
        guard isEven else { return nil }
    }
    
    // Convert 0 ... 9, a ... f, A ...F to their decimal value, return nil for all other input characters
    private func decodeNibble(_ character: UInt16) -> UInt8? {
        switch character {
        case 0x30 ... 0x39:
            return UInt8(character - 0x30)
        case 0x41 ... 0x46:
            return UInt8(character - 0x41 + 10)
        case 0x61 ... 0x66:
            return UInt8(character - 0x61 + 10)
        default:
            return nil
        }
    }
}

extension Data {
    func toHexString() -> String {
        return self.map { String(format: "%02x", $0) }.joined()
    }
    
    func isLedgerErrorResponse() -> Bool {
        toHexString() == ledgerErrorResponse
    }
}
