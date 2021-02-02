//
//  String+Number.swift

import Foundation

extension String {
    var digits: String { return filter(("0"..."9").contains) }
    var decimal: Decimal { return Decimal(string: digits) ?? 0 }
    
    func doubleForSendSeparator(with fraction: Int) -> Double? {
        return Formatter.separatorWith(fraction: fraction).number(from: self)?.doubleValue
    }
    
    func currencyInputFormatting(with fraction: Int) -> String? {
        let decimal = self.decimal / pow(10, fraction)
        return Formatter.separatorForInputWith(fraction: fraction).string(for: decimal)
    }
}
