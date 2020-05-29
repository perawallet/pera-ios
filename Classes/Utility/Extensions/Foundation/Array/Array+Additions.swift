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

extension Array {
    public func firstIndex<T: Equatable>(of other: Element?, equals keyPath: KeyPath<Element, T>) -> Index? {
        if let other = other {
            return firstIndex { $0[keyPath: keyPath] == other[keyPath: keyPath] }
        }
        return nil
    }
}

extension Array {
    subscript (safe index: Index?) -> Element? {
        if let index = index, indices.contains(index) {
            return self[index]
        }
        return nil
    }
}
