//
//  Formatter+Additions.swift

import Foundation

extension Formatter {
    static let separatorForAlgosInput: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale.preferred()
        formatter.currencySymbol = ""
        formatter.numberStyle = .currencyAccounting
        formatter.minimumFractionDigits = 6
        formatter.maximumFractionDigits = 6
        return formatter
    }()
    
    static let separatorForAlgosLabel: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale.preferred()
        formatter.currencySymbol = ""
        formatter.numberStyle = .currencyAccounting
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 6
        return formatter
    }()
    
    static func separatorForInputWith(fraction value: Int) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = Locale.preferred()
        formatter.currencySymbol = ""
        formatter.numberStyle = .currencyAccounting
        formatter.minimumFractionDigits = value
        formatter.maximumFractionDigits = value
        return formatter
    }
    
    static func separatorWith(fraction value: Int) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = Locale.preferred()
        formatter.currencySymbol = ""
        formatter.numberStyle = .currencyAccounting
        formatter.minimumFractionDigits = value == 0 ? 0 : 2
        formatter.maximumFractionDigits = value
        return formatter
    }
    
    static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale.preferred()
        formatter.currencySymbol = ""
        formatter.numberStyle = .currencyAccounting
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()
}
