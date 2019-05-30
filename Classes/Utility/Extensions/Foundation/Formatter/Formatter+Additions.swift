//
//  Formatter+Additions.swift
//  algorand
//
//  Created by Omer Emre Aslan on 16.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Foundation

extension Formatter {
    static let separatorForAlgosInput: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = ","
        formatter.currencySymbol = ""
        formatter.locale = Locale(identifier: "en_US")
        formatter.numberStyle = .currencyAccounting
        formatter.minimumFractionDigits = 6
        formatter.maximumFractionDigits = 6
        return formatter
    }()
    
    static let separatorForAlgosLabel: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = ","
        formatter.currencySymbol = ""
        formatter.locale = Locale(identifier: "en_US")
        formatter.numberStyle = .currencyAccounting
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 6
        return formatter
    }()
    
    static let numberToStringFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = ""
        formatter.currencySymbol = ""
        formatter.locale = Locale(identifier: "en_US")
        formatter.numberStyle = .currencyAccounting
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 6
        return formatter
    }()
    
    static let separatorForBidInput: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = ","
        formatter.currencySymbol = "$"
        formatter.locale = Locale(identifier: "en_US")
        formatter.numberStyle = .currencyAccounting
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()
}
