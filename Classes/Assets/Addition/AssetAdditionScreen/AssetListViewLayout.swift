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

//
//   AssetListViewLayout.swift

import Foundation
import MacaroonUIKit
import UIKit

final class AssetListViewLayout: NSObject {
    private var sizeCache: [String: CGSize] = [:]

    private let dataSource: AssetListViewDataSource

    init(
        _ dataSource: AssetListViewDataSource
    ) {
        self.dataSource = dataSource

        super.init()
    }
    
    static func build() -> UICollectionViewFlowLayout {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = .zero
        return flowLayout
    }
}

extension AssetListViewLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        let sectionIdentifiers = dataSource.snapshot().sectionIdentifiers

        guard let listSection = sectionIdentifiers[safe: section] else {
            return .zero
        }

        switch listSection {
        case .empty:
            return UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        case .assets:
            return UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0)
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        guard let itemIdentifier = dataSource.itemIdentifier(for: indexPath) else {
            return CGSize((collectionView.bounds.width, 0))
        }

        switch itemIdentifier {
        case .loading:
            return sizeForLoading(
                collectionView,
                forSectionAt: indexPath.section
            )
        case .asset(let item):
            return listView(
                collectionView,
                sizeForAssetCellItem: item,
                forSectionAt: indexPath.section
            )
        case .noContent:
            return sizeForSearchNoContent(
                collectionView,
                forSectionAt: indexPath.section
            )
        }
    }
}

extension AssetListViewLayout {
    private func calculateContentWidth(
        _ collectionView: UICollectionView,
        forSectionAt section: Int
    ) -> LayoutMetric {
        let sectionInset = self.collectionView(
            collectionView,
            layout: collectionView.collectionViewLayout,
            insetForSectionAt: section
        )
        return
            collectionView.bounds.width -
            collectionView.contentInset.horizontal -
            sectionInset.left -
            sectionInset.right
    }

    private func sizeForSearchNoContent(
        _ listView: UICollectionView,
        forSectionAt section: Int
    ) -> CGSize {
        let sizeCacheIdentifier = NoContentCell.reuseIdentifier

        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }

        let width = calculateContentWidth(
            listView,
            forSectionAt: section
        )
        let item = AssetAdditionNoContentViewModel()
        let newSize = NoContentCell.calculatePreferredSize(
            item,
            for: NoContentCell.theme,
            fittingIn:  CGSize((width, .greatestFiniteMagnitude))
        )

        sizeCache[sizeCacheIdentifier] = newSize

        return newSize
    }
    
    private func sizeForLoading(
        _ listView: UICollectionView,
        forSectionAt section: Int
    ) -> CGSize{
        let sizeCacheIdentifier = ManageAssetListLoadingCell.reuseIdentifier

        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }
        
        let width = calculateContentWidth(
            listView,
            forSectionAt: section
        )
        let maxSize = CGSize(width: width, height: .greatestFiniteMagnitude)
        let newSize = ManageAssetListLoadingCell.calculatePreferredSize(
            for: ManageAssetListLoadingCell.theme,
            fittingIn: maxSize
        )
        
        sizeCache[sizeCacheIdentifier] = newSize
        
        return newSize
    }

    private func listView(
        _ listView: UICollectionView,
        sizeForAssetCellItem item: OptInAssetListItem,
        forSectionAt section: Int
    ) -> CGSize {
        let sizeCacheIdentifier = OptInAssetListItemCell.reuseIdentifier

        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }

        let width = calculateContentWidth(
            listView,
            forSectionAt: section
        )
        let maxSize = CGSize(width: width, height: .greatestFiniteMagnitude)
        let newSize = OptInAssetListItemCell.calculatePreferredSize(
            item.viewModel,
            for: OptInAssetListItemCell.theme,
            fittingIn:maxSize
        )

        sizeCache[sizeCacheIdentifier] = newSize

        return newSize
    }
}
