// Copyright © 2019 hipolabs. All rights reserved.

import Foundation

extension NumberFormatter {
    public static var shared: NumberFormatter {
        return NumberFormatter()
    }

    public static var ordinal: NumberFormatter {
        let formatter = NumberFormatter.shared
        formatter.numberStyle = .ordinal
        return formatter
    }

    public static var currency: NumberFormatter {
        let formatter = NumberFormatter.shared
        formatter.numberStyle = .currency
        return formatter
    }
}
