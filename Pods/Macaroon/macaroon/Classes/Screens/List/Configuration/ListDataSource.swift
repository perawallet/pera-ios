// Copyright © 2019 hipolabs. All rights reserved.

import Foundation

public protocol ListDataSource {
    subscript(section: Int) -> Any? { get }
    subscript(indexPath: IndexPath) -> Any? { get }

    func isEmpty() -> Bool
    func isSectionEmpty(_ section: Int) -> Bool
    func numberOfSections() -> Int
    func numberOfItems(inSection section: Int) -> Int
    func section(of item: Any) -> Int?
    func indexPath(of item: Any) -> IndexPath?
}

public protocol SingleListDataSource: ListDataSource {
    associatedtype SomeList: Collection

    var list: SomeList { get }

    subscript(indexPath: IndexPath) -> SomeList.Element { get }

    func indexPath(of item: SomeList.Element) -> IndexPath?
}

extension SingleListDataSource {
    public subscript(section: Int) -> Any? {
        return list
    }

    public subscript(indexPath: IndexPath) -> Any? {
        let elem: SomeList.Element = self[indexPath]
        return elem
    }

    public func isEmpty() -> Bool {
        return isSectionEmpty(0)
    }

    public func isSectionEmpty(_ section: Int) -> Bool {
        return list.isEmpty
    }

    public func numberOfSections() -> Int {
        return 1
    }

    public func numberOfItems(inSection section: Int) -> Int {
        return list.count
    }

    public func section(of item: Any) -> Int? {
        return 0
    }

    public func indexPath(of item: Any) -> IndexPath? {
        if let validItem = item as? SomeList.Element {
            return indexPath(of: validItem)
        }
        return nil
    }
}

extension SingleListDataSource where SomeList.Index == Int {
    public subscript(indexPath: IndexPath) -> SomeList.Element {
        return list[indexPath.item]
    }
}

extension SingleListDataSource where SomeList.Index == Int, SomeList.Element: Equatable {
    public func indexPath(of item: SomeList.Element) -> IndexPath? {
        if let i = list.firstIndex(of: item) {
            return IndexPath(item: i, section: 0)
        }
        return nil
    }
}

public protocol SectionedListDataSource: ListDataSource {
    associatedtype SomeList: Collection where SomeList.Element: Collection

    var list: SomeList { get }

    subscript(section: Int) -> SomeList.Element { get }
    subscript(indexPath: IndexPath) -> SomeList.Element.Element { get }

    func section(of item: SomeList.Element) -> Int?
    func indexPath(of item: SomeList.Element.Element) -> IndexPath?
}

extension SectionedListDataSource {
    public subscript(section: Int) -> Any? {
        let elem: SomeList.Element = self[section]
        return elem
    }

    public subscript(indexPath: IndexPath) -> Any? {
        let elem: SomeList.Element.Element = self[indexPath]
        return elem
    }

    public func isEmpty() -> Bool {
        return !((0..<numberOfSections()).contains { !isSectionEmpty($0) })
    }

    public func numberOfSections() -> Int {
        return list.count
    }

    public func section(of item: Any) -> Int? {
        if let validItem = item as? SomeList.Element {
            return section(of: validItem)
        }
        return nil
    }

    public func indexPath(of item: Any) -> IndexPath? {
        if let validItem = item as? SomeList.Element.Element {
            return indexPath(of: validItem)
        }
        return nil
    }
}

extension SectionedListDataSource where SomeList.Index == Int {
    public subscript(section: Int) -> SomeList.Element {
        return list[section]
    }

    public func isSectionEmpty(_ section: Int) -> Bool {
        return list[section].isEmpty
    }

    public func numberOfItems(inSection section: Int) -> Int {
        return list[section].count
    }
}

extension SectionedListDataSource where SomeList.Index == Int, SomeList.Element: Equatable {
    public func section(of item: SomeList.Element) -> Int? {
        return list.firstIndex(of: item)
    }
}

extension SectionedListDataSource where SomeList.Index == Int, SomeList.Element.Index == Int {
    public subscript(indexPath: IndexPath) -> SomeList.Element.Element {
        return list[indexPath.section][indexPath.item]
    }
}

extension SectionedListDataSource where SomeList.Index == Int, SomeList.Element.Index == Int, SomeList.Element.Element: Equatable {
    public func indexPath(of item: SomeList.Element.Element) -> IndexPath? {
        for (section, items) in list.enumerated() {
            if let index = items.firstIndex(of: item) {
                return IndexPath(item: index, section: section)
            }
        }
        return nil
    }
}
