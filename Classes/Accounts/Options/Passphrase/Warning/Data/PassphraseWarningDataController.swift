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

//   PassphraseWarningDataController.swift

import Foundation
import OrderedCollections

struct WarningCheckRow {
    let index: Int
    let title: String
}

final class PassphraseWarningDataController {
    typealias Index = Int

    private let warningCheckRows: OrderedDictionary<Index, String>
    private lazy var selectedwarningCheckRows: OrderedDictionary<Index, String> = [:]
    
    init(warningRowsArray: [String]) {
        self.warningCheckRows = OrderedDictionary(uniqueKeysWithValues: warningRowsArray.enumerated().map{ ($0.offset, $0.element) })
    }
}

extension PassphraseWarningDataController {
    func isRowSelected(at index: Index) -> Bool {
        return selectedwarningCheckRows[index] != nil
    }

    var isFinishActionEnabled: Bool {
        return warningCheckRows.count == selectedwarningCheckRows.count
    }
    
    func row(at index: Index) -> String? {
        return warningCheckRows[index]
    }
    
    var rows: [String] {
        return warningCheckRows.values.elements
    }
}

extension PassphraseWarningDataController {
    func updateSelectionWithItem(at index: Index) {
        if isRowSelected(at: index) {
            unselectAddressItem(at: index)
        } else {
            selectRowItem(at: index)
        }
    }
    
    private func selectRowItem(at index: Index) {
        guard
            let warningCheckRow = warningCheckRows[index]
        else {
            return
        }

        selectedwarningCheckRows[index] = warningCheckRow
    }

    private func unselectAddressItem(at index: Index ) {
        selectedwarningCheckRows[index] = nil
    }

}
