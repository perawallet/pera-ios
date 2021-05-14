// Copyright 2019 Algorand, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//  Array+Additions.swift

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

    func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        return sorted { first, second in
            first[keyPath: keyPath] > second[keyPath: keyPath]
        }
    }

    func sorted<T: Comparable>(by keyPath: KeyPath<Element, T?>) -> [Element] {
        return sorted { first, second in
            guard let firstValue = first[keyPath: keyPath], let secondValue = second[keyPath: keyPath] else {
                return false
            }

            return firstValue > secondValue
        }
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
