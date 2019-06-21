//
//  String+Number.swift
//  algorand
//
//  Created by Omer Emre Aslan on 16.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Foundation

extension String {
    var digits: String { return filter(("0"..."9").contains) }
    var decimal: Decimal { return Decimal(string: digits) ?? 0 }
    
    var doubleForSendSeparator: Double? {
        return Formatter.separatorForAlgosInput.number(from: self)?.doubleValue
    }
    
    var doubleForReadSeparator: Double? {
        return Formatter.separatorForAlgosLabel.number(from: self)?.doubleValue
    }
    
    func currencyAlgosInputFormatting() -> String? {
        let decimal = self.decimal / pow(10, Formatter.separatorForAlgosInput.maximumFractionDigits)
        return Formatter.separatorForAlgosInput.string(for: decimal)
    }
    
    func currencyBidInputFormatting() -> String? {
        let decimal = self.decimal / pow(10, Formatter.separatorForBidInput.maximumFractionDigits)
        return Formatter.separatorForBidInput.string(for: decimal)
    }
}
