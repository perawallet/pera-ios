//
//  Int16+Byte.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 7.12.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Foundation

extension UInt16 {
    func shiftOneByteRight() -> UInt16 {
        return self >> 8
    }
    
    func shiftOneByteLeft() -> UInt16 {
        return self << 8
    }
    
    func removeExcessBytes() -> UInt16 {
        return self & 0xFF
    }
    
    var asByte: UInt8 {
        UInt8(self)
    }
}
