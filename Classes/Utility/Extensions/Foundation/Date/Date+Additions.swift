//
//  Date+Additions.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 5.06.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Foundation

extension Date {
    
    var dayAfter: Date? {
        return Calendar.current.date(byAdding: .day, value: 1, to: self)
    }
}
