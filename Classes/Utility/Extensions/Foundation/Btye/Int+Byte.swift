//
//  Int+Byte.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 7.12.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Foundation

extension Int {
    func removeExcessBytes() -> Int {
        return self & 0xFF
    }
    
    func toByteArray() -> [UInt8] {
        return [(self >> 24).asByte, (self >> 16).asByte, (self >> 8).asByte, self.asByte]
    }
    
    var asByte: UInt8 {
        UInt8(self)
    }
}
