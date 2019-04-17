//
//  Formatter+Additions.swift
//  algorand
//
//  Created by Omer Emre Aslan on 16.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Foundation

extension Formatter {
    static let withSeparator: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = ","
        formatter.currencySymbol = ""
        formatter.locale = Locale(identifier: "en_US")
        formatter.numberStyle = .currencyAccounting
        formatter.maximumFractionDigits = 6
        formatter.minimumFractionDigits = 6
        return formatter
    }()
}
