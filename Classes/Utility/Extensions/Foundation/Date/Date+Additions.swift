//
//  Date+Additions.swift

import Foundation

extension Date {
    
    var dayAfter: Date? {
        return Calendar.current.date(byAdding: .day, value: 1, to: self)
    }
}
