//
//  Int.swift
//  algorand
//
//  Created by Omer Emre Aslan on 11.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Foundation

let algosInMicroAlgos = 1000000
let minimumFee: UInt64 = 1000
let minimumTransactionMicroAlgosLimit = 100000
let algosFraction = 6

extension Int {
    var toAlgos: Double {
        return Double(self) / Double(algosInMicroAlgos)
    }
    
    func assetAmount(fromFraction decimal: Int) -> Double {
        if decimal == 0 {
            return Double(self)
        }
        return Double(self) / (pow(10, decimal) as NSDecimalNumber).doubleValue
    }
    
    func convertToDollars(withSymbol: Bool = true) -> String {
        let doubleValue = Double(self) / 100
        let formatter = NumberFormatter()
        
        if withSymbol {
            formatter.currencyCode = "USD"
            formatter.currencySymbol = "$"
            formatter.numberStyle = .currencyAccounting
        }
        
        formatter.locale = Locale(identifier: "en_US")
        formatter.groupingSeparator = ","
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSDecimalNumber(value: doubleValue)) ?? "$\(doubleValue)"
    }
    
    func convertSecondsToHoursMinutesSeconds() -> String? {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        return formatter.string(from: TimeInterval(self))
    }
}

extension Int64 {
    var toAlgos: Double {
        return Double(self) / Double(algosInMicroAlgos)
    }
    
    func assetAmount(fromFraction decimal: Int) -> Double {
        if decimal == 0 {
            return Double(self)
        }
        return Double(self) / (pow(10, decimal) as NSDecimalNumber).doubleValue
    }
    
    var toDecimalStringForLabel: String? {
        return Formatter.separatorForAlgosLabel.string(from: NSNumber(value: self))
    }
    
    func toFractionStringForLabel(fraction: Int) -> String? {
        return Formatter.separatorWith(fraction: fraction).string(from: NSNumber(value: self))
    }
}

extension UInt64 {
    var toAlgos: Double {
        return Double(self) / Double(algosInMicroAlgos)
    }
    
    func assetAmount(fromFraction decimal: Int) -> Double {
        if decimal == 0 {
            return Double(self)
        }
        return Double(self) / (pow(10, decimal) as NSDecimalNumber).doubleValue
    }
}
