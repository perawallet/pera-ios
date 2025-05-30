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

//   SortAccountAssetListDataSource.swift

import Foundation
import UIKit

final class SortAccountAssetListDataSource:
    UICollectionViewDiffableDataSource<SortAccountAssetListSection, SortAccountAssetListItem> {
    init(
        _ collectionView: UICollectionView
    ) {
        super.init(collectionView: collectionView) {
            collectionView, indexPath, itemIdentifier in

            switch itemIdentifier {
            case .sortOption(let item):
                let cell = collectionView.dequeue(
                    SingleSelectionCell.self,
                    at: indexPath
                )
                cell.bindData(
                    item.value
                )
                return cell
            }
        }

        [
            SingleSelectionCell.self,
        ].forEach {
            collectionView.register($0)
        }
    }
}
