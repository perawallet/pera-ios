// Copyright © 2019 hipolabs. All rights reserved.

import Foundation

extension Array {
    public var lastIndex: Index {
        if startIndex == endIndex {
            return endIndex
        }
        return index(before: endIndex)
    }
}

extension Array {
    public subscript(safe index: Index?) -> Element? {
        if let index = index, indices.contains(index) {
            return self[index]
        }
        return nil
    }
}

extension Array {
    public func previousElement(beforeElementAt i: Index) -> Element? {
        return i > startIndex ? self[index(before: i)] : nil
    }

    public func nextElement(afterElementAt i: Index) -> Element? {
        return i < index(before: endIndex) ? self[index(after: i)] : nil
    }
}

extension Array {
    public func first<T: Equatable>(of keyPath: KeyPath<Element, T>, equalsTo value: T) -> Element? {
        return first(where: { $0[keyPath: keyPath] == value })
    }

    public func first<T: Equatable>(of keyPath: KeyPath<Element, T>, equalsTo value: T?) -> Element? {
        return first(where: { $0[keyPath: keyPath] == value })
    }

    public func first<T: Equatable>(of keyPath: KeyPath<Element, T?>, equalsTo value: T) -> Element? {
        return first(where: { $0[keyPath: keyPath] == value })
    }

    public func first<T: Equatable>(of keyPath: KeyPath<Element, T?>, equalsTo value: T?) -> Element? {
        return first(where: { $0[keyPath: keyPath] != nil && $0[keyPath: keyPath] == value })
    }

    public func firstIndex<T: Equatable>(of other: Element?, equals keyPath: KeyPath<Element, T>) -> Index? {
        if let other = other {
            return firstIndex { $0[keyPath: keyPath] == other[keyPath: keyPath] }
        }
        return nil
    }
}

extension Array {
    public func findFirst<T>(_ keyPath: KeyPath<Element, T>, where predicate: (Element) -> Bool) -> T? {
        return first(where: predicate)?[keyPath: keyPath]
    }

    public func findFirst<T>(_ keyPath: KeyPath<Element, T?>, where predicate: (Element) -> Bool) -> T? {
        return first(where: predicate)?[keyPath: keyPath]
    }

    public func findLast<T>(nonNil keyPath: KeyPath<Element, T>) -> T? {
        let elem = last { $0[keyPath: keyPath] != nil }
        return elem?[keyPath: keyPath]
    }

    public func findLast<T>(nonNil keyPath: KeyPath<Element, T?>) -> T? {
        let elem = last { $0[keyPath: keyPath] != nil }
        return elem?[keyPath: keyPath]
    }
}

extension Array {
    public func unique<T: Hashable>(_ keyPath: KeyPath<Element, T>) -> Self {
        var observer: Set<T> = []
        return filter { observer.insert($0[keyPath: keyPath]).inserted }
    }

    public func nonNil<T>() -> [T] where Element == T? {
        return compactMap {
            $0
        }
    }
}

extension Array {
    @discardableResult
    public mutating func remove(
        where predicate: (Element) -> Bool
    ) -> Element? {
        guard let index = firstIndex(where: predicate) else {
            return nil
        }

        return remove(
            at: index
        )
    }

    public mutating func removeAll(
        where predicate: (Element) -> Bool
    ) -> [Element] {
        var currentElements = self
        var removedElements: [Element] = []

        for (i, elem) in currentElements.enumerated() {
            if predicate(elem) {
                let removedElem =
                    remove(
                        at: i
                    )
                removedElements.append(
                    removedElem
                )
            }
        }

        return removedElements
    }
}

extension Array where Element: Hashable {
    public func elementsEqualWithoutOrder(
        _ other: Self
    ) -> Bool {
        return Set(self) == Set(other)
    }
}

extension Array where Element: Hashable {
    public func element(before nextElement: Element) -> Element? {
        guard let index = firstIndex(where: { $0 == nextElement }) else {
            return nil
        }

        return previousElement(beforeElementAt: index)
    }

    public func element(after previousElement: Element) -> Element? {
        guard let index = firstIndex(where: { $0 == previousElement }) else {
            return nil
        }

        return nextElement(afterElementAt: index)
    }
}
