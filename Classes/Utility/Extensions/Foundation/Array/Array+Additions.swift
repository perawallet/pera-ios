//
//  Array+Additions.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 30.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Foundation

extension Array where Element: Comparable {
    func containsSameElements(as other: [Element]) -> Bool {
        return self.count == other.count && self.sorted() == other.sorted()
    }
}
