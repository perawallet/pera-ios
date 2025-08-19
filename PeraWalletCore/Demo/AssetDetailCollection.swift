// Copyright 2022-2025 Pera Wallet, LDA

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
//   AssetDetailCollection.swift


import Foundation
import MacaroonUtils

public struct AssetDetailCollection:
    Collection,
    ExpressibleByArrayLiteral,
    Printable {
    public typealias Key = AssetID
    public typealias Index = AssetDetailCollectionIndex
    public typealias Element = AssetDecoration
    
    fileprivate typealias Table = [Key: Element]

    public var startIndex: Index {
        return Index(table.startIndex)
    }
    public var endIndex: Index {
        return Index(table.endIndex)
    }
    
    public var debugDescription: String {
        return table.debugDescription
    }
    
    @Atomic(identifier: "assetDetailCollection.table")
    private var table = Table()
    
    public init(
        _ collection: AssetDetailCollection
    ) {
        $table.mutate { $0 = collection.table }
    }
    
    public init(
        _ elements: [Element]
    ) {
        let keysAndValues = elements.map { ($0.id, $0) }
        let aTable = Table(keysAndValues, uniquingKeysWith: { $1 })
        $table.mutate { $0 = aTable }
    }

    public init(
        arrayLiteral elements: Element...
    ) {
        self.init(elements)
    }
}

extension AssetDetailCollection {
    public subscript (position: Index) -> Element {
        return table[position.wrapped].value
    }
    
    public subscript (key: Key) -> Element? {
        get { table[key] }
        set { $table.mutate { $0[key] = newValue } }
    }
}

extension AssetDetailCollection {
    public func index(
        after i: Index
    ) -> Index {
        return Index(table.index(after: i.wrapped))
    }
}

public struct AssetDetailCollectionIndex: Comparable {
    fileprivate typealias InternalIndex = AssetDetailCollection.Table.Index
    
    fileprivate let wrapped: InternalIndex
    
    fileprivate init(
        _ wrapped: InternalIndex
    ) {
        self.wrapped = wrapped
    }
    
    public static func == (
        lhs: Self,
        rhs: Self
    ) -> Bool {
        return lhs.wrapped == rhs.wrapped
    }

    public static func < (
        lhs: Self,
        rhs: Self
    ) -> Bool {
        return  lhs.wrapped < rhs.wrapped
    }
}
