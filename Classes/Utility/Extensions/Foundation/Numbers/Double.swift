//
//  Double.swift

import Foundation

extension Double {
    var toMicroAlgos: Int64 {
        return Int64(Double(algosInMicroAlgos) * self)
    }
    
    func toFraction(of fraction: Int) -> Int64 {
        if fraction == 0 {
            return Int64(self)
        }
        
        return Int64(self * (pow(10, fraction) as NSDecimalNumber).doubleValue)
    }
    
    var toDecimalStringForAlgosInput: String? {
        return Formatter.separatorForAlgosInput.string(from: NSNumber(value: self))
    }
    
    var toAlgosStringForLabel: String? {
        return Formatter.separatorForAlgosLabel.string(from: NSNumber(value: self))
    }
    
    func toFractionStringForLabel(fraction: Int) -> String? {
        return Formatter.separatorWith(fraction: fraction).string(from: NSNumber(value: self))
    }
    
    var toCurrencyStringForLabel: String? {
        return Formatter.currencyFormatter.string(from: NSNumber(value: self))
    }
}
