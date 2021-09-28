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
//  LedgerAccountSelectionListLayout.swift

import UIKit

final class LedgerAccountSelectionListLayout: NSObject {
    weak var delegate: LedgerAccountSelectionListLayoutDelegate?
    
    private weak var dataSource: LedgerAccountSelectionDataSource?

    init(dataSource: LedgerAccountSelectionDataSource) {
        self.dataSource = dataSource
        super.init()
    }
}

extension LedgerAccountSelectionListLayout: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let cellSize = CGSize(width: UIScreen.main.bounds.width - 40, height: 76)
        return cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.ledgerAccountSelectionListLayout(self, didSelectItemAt: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        delegate?.ledgerAccountSelectionListLayout(self, didDeselectItemAt: indexPath)
    }
}

protocol LedgerAccountSelectionListLayoutDelegate: AnyObject {
    func ledgerAccountSelectionListLayout(
        _ ledgerAccountSelectionListLayout: LedgerAccountSelectionListLayout,
        didSelectItemAt indexPath: IndexPath
    )
    func ledgerAccountSelectionListLayout(
        _ ledgerAccountSelectionListLayout: LedgerAccountSelectionListLayout,
        didDeselectItemAt indexPath: IndexPath
    )
}
