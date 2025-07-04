// Copyright 2025 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   NSDiffableDataSourceSnapshot+Replace.swift

import UIKit

extension NSDiffableDataSourceSnapshot {
    mutating func replaceItem(
        matching predicate: (ItemIdentifierType) -> Bool,
        with newItem: ItemIdentifierType
    ) {
        guard let oldIndex = itemIdentifiers.firstIndex(where: predicate) else { return }

        let oldItem = itemIdentifiers[oldIndex]
        deleteItems([oldItem])

        if oldIndex < itemIdentifiers.count {
            let beforeItem = itemIdentifiers[oldIndex]
            insertItems([newItem], beforeItem: beforeItem)
        } else if oldIndex > 0 {
            let afterItem = itemIdentifiers[oldIndex - 1]
            insertItems([newItem], afterItem: afterItem)
        } else {
            appendItems([newItem])
        }

        reloadItems([newItem])
    }
}
