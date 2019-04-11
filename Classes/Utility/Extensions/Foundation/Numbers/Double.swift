//
//  Double.swift
//  algorand
//
//  Created by Omer Emre Aslan on 11.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Foundation

extension Double {
    var toMicroAlgos: Int64 {
        return Int64(Double(algosInMicroAlgos) * self)
    }
}
