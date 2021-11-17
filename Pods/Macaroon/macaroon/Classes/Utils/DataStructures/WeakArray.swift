// Copyright © 2019 hipolabs. All rights reserved.

import Foundation

public struct WeakArray<Element: AnyObject>:
    Collection,
    ExpressibleByArrayLiteral {
    public var startIndex: Int {
        return items.startIndex
    }
    public var endIndex: Int {
        return items.endIndex
    }

    private var items: [WeakBox<Element>] = []

    public init(
        arrayLiteral elements: Element...
    ) {
        self.init(
            elements
        )
    }

    private init(
        _ items: [Element]
    ) {
        self.items =
            items.map(
                WeakBox.init
            )
    }

    public subscript(_ index: Int) -> Element? {
        return items[index].unboxValue
    }

    public func index(
        after i: Int
    ) -> Int {
        return items.index(
            after: i
        )
    }

    public mutating func append(
        _ newItem: Element
    ) {
        items.append(
            WeakBox(newItem)
        )
    }

    public mutating func remove(
        at index: Int
    ) -> Element? {
        return items.remove(
            at: index
        ).unboxValue
    }

    public mutating func removeAll() {
        items.removeAll()
    }

    public func forEachSafe(
        _ body: (Element) -> Void
    ) {
        items.forEach {
            if let safeUnboxValue = $0.unboxValue {
                body(safeUnboxValue)
            }
        }
    }
}

public final class WeakBox<Value: AnyObject> {
    public private(set) weak var unboxValue: Value?

    public init(
        _ value: Value
    ) {
        self.unboxValue = value
    }
}
