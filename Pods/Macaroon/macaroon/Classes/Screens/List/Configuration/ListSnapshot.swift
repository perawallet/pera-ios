// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

public protocol ListSnapshot {
    var updates: ListUpdates { get }

    /// <warning> It should return the item from the new list after updates.
    subscript(newIndexPath: IndexPath) -> Any? { get }
}

extension ListSnapshot {
    public var hasUpdates: Bool {
        return !updates.isEmpty
    }
}

public protocol ListMove {
    var source: Int { get }
    var destination: Int { get }
    var isMutated: Bool { get }
}

public struct ArrayListSnapshot<Item>: ListSnapshot {
    public typealias List = Array<Item>

    public let newList: List
    public let updates: ListUpdates

    public init(
        newList: List,
        updates: ListUpdates
    ) {
        self.newList = newList
        self.updates = updates
    }

    public subscript(newIndexPath: IndexPath) -> Any? {
        return newList[safe: newIndexPath.item]
    }
}

public struct ListUpdates {
    public var isEmpty: Bool {
        return
            inserts.isEmpty &&
            deletes.isEmpty &&
            reloads.isEmpty &&
            moves.isEmpty
    }

    public var inserts: IndexSet
    public var deletes: IndexSet
    public var reloads: IndexSet
    public var moves: [ListMove]

    public let section: Int

    public init(
        section: Int = 0,
        inserts: IndexSet = [],
        deletes: IndexSet = [],
        reloads: IndexSet = [],
        moves: [ListMove] = []
    ) {
        self.section = section
        self.inserts = inserts
        self.deletes = deletes
        self.reloads = reloads
        self.moves = moves
    }
}
