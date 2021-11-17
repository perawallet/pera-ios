// Copyright © 2019 hipolabs. All rights reserved.

import Foundation

extension Int {
    public var ordinalDescription: String {
        return NumberFormatter.ordinal.string(from: NSNumber(value: self)) ?? ""
    }
}

extension Int: CustomStringConvertible {
    public var description: String {
        return String(self)
    }
}
