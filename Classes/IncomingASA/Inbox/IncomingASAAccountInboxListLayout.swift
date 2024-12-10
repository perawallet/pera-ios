// Copyright 2024 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   IncomingASAAccountInboxListLayout.swift

import Foundation
import MacaroonUIKit
import UIKit

final class IncomingASAAccountInboxListLayout: NSObject {
    lazy var handlers = Handlers()
    
    private var sizeCache: [String: CGSize] = [:]

    private lazy var theme = Theme()

    private let listDataSource: IncomingASAAccountInboxListDataSource

    init(listDataSource: IncomingASAAccountInboxListDataSource) {
        self.listDataSource = listDataSource
        super.init()
    }

    class func build() -> UICollectionViewLayout {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0
        return flowLayout
    }
}

extension IncomingASAAccountInboxListLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        handlers.willDisplay?(cell, indexPath)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        guard let itemIdentifier = listDataSource.itemIdentifier(for: indexPath) else {
            return CGSize((collectionView.bounds.width, 0))
        }
        
        switch itemIdentifier {
        case let .asset(item):
            return listView(
                collectionView,
                layout: collectionViewLayout,
                sizeForAssetCellItem: item.viewModel,
                atSection: indexPath.section
            )
        case .assetLoading:
            return listView(
                collectionView,
                layout: collectionViewLayout,
                sizeForAssetLoadingItemAt: indexPath
            )
        case .empty:
            return collectionView.bounds.size
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return .zero
    }
}


extension IncomingASAAccountInboxListLayout {
    
    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForAssetLoadingItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = calculateContentWidth(
            listView,
            forSectionAt: indexPath.section
        )
        return AccountAssetListLoadingCell.calculatePreferredSize(
            for: AccountAssetListLoadingCell.theme,
            fittingIn: .init(width: width, height: .greatestFiniteMagnitude)
        )
    }

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForAssetCellItem item: IncomingASAListItemViewModel,
        atSection section: Int
    ) -> CGSize {
        let sizeCacheIdentifier = IncomingASAAccountInboxListItemCell.reuseIdentifier

        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }

        let width = calculateContentWidth(
            listView,
            forSectionAt: section
        )
        let newSize = IncomingASAAccountInboxListItemCell.calculatePreferredSize(
            item,
            for: IncomingASAAccountInboxListItemCell.theme,
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )

        sizeCache[sizeCacheIdentifier] = newSize

        return newSize
    }

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForCollectibleAssetCellItem item: CollectibleListItemViewModel,
        atSection section: Int
    ) -> CGSize {
        let sizeCacheIdentifier = CollectibleListItemCell.reuseIdentifier

        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }

        let width = calculateContentWidth(
            listView,
            forSectionAt: section
        )
        let newSize = CollectibleListItemCell.calculatePreferredSize(
            item,
            for: CollectibleListItemCell.theme,
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )

        sizeCache[sizeCacheIdentifier] = newSize

        return newSize
    }

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForPendingCollectibleAssetCellItem item: CollectibleListItemViewModel,
        atSection section: Int
    ) -> CGSize {
        let sizeCacheIdentifier = PendingCollectibleAssetListItemCell.reuseIdentifier

        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }

        let width = calculateContentWidth(
            listView,
            forSectionAt: section
        )
        let newSize = PendingCollectibleAssetListItemCell.calculatePreferredSize(
            item,
            for: PendingCollectibleAssetListItemCell.theme,
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )

        sizeCache[sizeCacheIdentifier] = newSize

        return newSize
    }
}

extension IncomingASAAccountInboxListLayout {
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
}

extension IncomingASAAccountInboxListLayout {
    struct Handlers {
        var willDisplay: ((UICollectionViewCell, IndexPath) -> Void)?
    }
}
