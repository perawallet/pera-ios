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
    
    var asByte: UInt8 {
        UInt8(self)
    }
}
