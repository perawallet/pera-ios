//
//  Int.swift
//  algorand
//
//  Created by Omer Emre Aslan on 11.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Foundation

let algosInMicroAlgos = 1000000
let maximumMicroAlgos = Int64.max / Int64(algosInMicroAlgos)
let minimumTransactionMicroAlgosLimit = 10000

extension Int {
    var toAlgos: Double {
        return Double(self) / Double(algosInMicroAlgos)
    }
}

extension Int64 {
    var toAlgos: Double {
        return Double(self) / Double(algosInMicroAlgos)
    }
}

extension UInt64 {
    var toAlgos: Double {
        return Double(self) / Double(algosInMicroAlgos)
    }
}
