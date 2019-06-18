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
    
    var toDecimalStringForAlgosInput: String? {
        return Formatter.separatorForAlgosInput.string(from: NSNumber(value: self))
    }
    
    var toDecimalStringForLabel: String? {
        return Formatter.separatorForAlgosLabel.string(from: NSNumber(value: self))
    }
    
    var toDecimalStringForURL: String? {
        return Formatter.numberToStringFormatter.string(from: NSNumber(value: self))
    }
    
    var toDecimalStringForBidInput: String? {
        return Formatter.separatorForBidInput.string(from: NSNumber(value: self))
    }
    
    var toStringForTwoDecimal: String? {
        return Formatter.twoDecimalFormatter.string(from: NSNumber(value: self))
    }
    
    func truncate(places: Int) -> Double {
        return Double(floor(pow(10.0, Double(places)) * self) / pow(10.0, Double(places)))
    }
    
    func formatToShort() -> String {
        let sign = (self < 0) ? "-" : ""
        
        switch self {
        case 1000000000...:
            var formatted = self / 1000000000.0
            formatted = formatted.truncate(places: 1)
            if let formattedString = formatted.toStringForTwoDecimal {
                return "\(sign)\(formattedString)B"
            } else {
                return "\(sign)\(formatted)B"
            }
        case 1000000...:
            var formatted = self / 1000000.0
            formatted = formatted.truncate(places: 1)
            if let formattedString = formatted.toStringForTwoDecimal {
                return "\(sign)\(formattedString)M"
            } else {
                return "\(sign)\(formatted)M"
            }
        case 1000...:
            var formatted = self / 1000.0
            formatted = formatted.truncate(places: 1)
            if let formattedString = formatted.toStringForTwoDecimal {
                return "\(sign)\(formattedString)K"
            } else {
                return "\(sign)\(formatted)K"
            }
        case 0...:
            if let formatted = toStringForTwoDecimal {
                return "\(formatted)"
            } else {
                return "\(self)"
            }
        default:
            if let formatted = toStringForTwoDecimal {
                return "\(sign)\(formatted)"
            } else {
                return "\(sign)\(self)"
            }
        }
    }
}
