// Copyright 2022 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   SortCollectibleListLayout.swift

import Foundation
import MacaroonUIKit
import UIKit

final class SortCollectibleListLayout: NSObject {
    private let listDataSource: SortCollectibleListDataSource

    init(
        listDataSource: SortCollectibleListDataSource
    ) {
        self.listDataSource = listDataSource
        super.init()
    }

    class func build() -> UICollectionViewLayout {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0
        flowLayout.sectionInset = UIEdgeInsets(LayoutPaddings(20, 24, 16, 24))
        return flowLayout
    }
}

extension SortCollectibleListLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        guard listDataSource.itemIdentifier(for: indexPath) != nil else {
            return CGSize((collectionView.bounds.width, 0))
        }

        return CGSize(
            width: calculateContentWidth(for: collectionView),
            height: 56
        )
    }
}

extension SortCollectibleListLayout {
    private func calculateContentWidth(
        for listView: UICollectionView
    ) -> LayoutMetric {
        return listView.bounds.width -
            listView.contentInset.horizontal -
            (24 + 24)
    }
}
