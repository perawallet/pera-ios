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

//   SwapAccountSelectionListLayout.swift

import Foundation
import UIKit
import MacaroonUIKit

final class SwapAccountSelectionListLayout: AccountSelectionListLayout {
    typealias DataSource = SwapAccountSelectionListDataSource.DataSource

    private var sizeCache: [String: CGSize] = [:]

    private unowned let dataSource: DataSource
    private unowned let itemDataSource: SwapAccountSelectionListItemDataSource

    init(
        dataSource: DataSource,
        itemDataSource: SwapAccountSelectionListItemDataSource
    ) {
        self.dataSource = dataSource
        self.itemDataSource = itemDataSource
    }

    static func build() -> UICollectionViewFlowLayout {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = .zero
        return flowLayout
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        let snapshot = dataSource.snapshot()
        let sectionIdentifiers = snapshot.sectionIdentifiers

        guard let listSection = sectionIdentifiers[safe: section] else {
            return .zero
        }

        switch listSection {
        case .empty:
            return .zero
        case .accounts:
            return UIEdgeInsets(
                top: 24,
                left: .zero,
                bottom: 8,
                right: .zero
            )
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        let snapshot = dataSource.snapshot()
        let sectionIdentifiers = snapshot.sectionIdentifiers

        guard let listSection = sectionIdentifiers[safe: section],
              listSection == .accounts else {
            return .zero
        }

        let size = listView(
            collectionView,
            sizeForHeaderItem: itemDataSource.headerItem,
            atSection: section
        )
        return size
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        guard let itemIdentifier = dataSource.itemIdentifier(for: indexPath) else {
            return .zero
        }

        switch itemIdentifier {
        case .empty(let item):
            return listView(
                collectionView,
                layout: collectionViewLayout,
                sizeForEmptyItem: item,
                atSection: indexPath.section
            )
        case .account(let item):
            return listView(
                collectionView,
                layout: collectionViewLayout,
                sizeForAccountCellItem: itemDataSource.accountItems[item.accountAddress]!,
                atSection: indexPath.section
            )
        }
    }
}

extension SwapAccountSelectionListLayout {
    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForEmptyItem item: SwapAccountSelectionListEmptyItemIdentifier,
        atSection section: Int
    ) -> CGSize {
        let width = calculateContentWidth(
            for: listView,
            forSectionAt: section
        )
        let sectionInset = collectionView(
            listView,
            layout: listViewLayout,
            insetForSectionAt: section
        )
        let height =
            listView.bounds.height -
            listView.contentInset.top -
            sectionInset.vertical -
            listView.safeAreaTop -
            listView.safeAreaBottom
        return CGSize((width, height))
    }

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForAccountCellItem item: AccountListItemViewModel,
        atSection section: Int
    ) -> CGSize {
        let sizeCacheIdentifier = SwapAccountSelectionListAccountListItemCell.reuseIdentifier

        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }

        let width = listView.bounds.width
        let sampleAccountListItem = CustomAccountListItem(
            address: "someAlgorandAddress",
            icon: "icon-standard-account".uiImage,
            title: "title-unknown".localized,
            subtitle: "title-plus-asset-singular-count".localized(params: "1")
        )
        let sampleAccountItem = AccountListItemViewModel(sampleAccountListItem)
        let newSize = SwapAccountSelectionListAccountListItemCell.calculatePreferredSize(
            sampleAccountItem,
            for: SwapAccountSelectionListAccountListItemCell.theme.context,
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )

        sizeCache[sizeCacheIdentifier] = newSize

        return newSize
    }

    private func listView(
        _ listView: UICollectionView,
        sizeForHeaderItem item: SwapAccountSelectionListHeaderViewModel,
        atSection section: Int
    ) -> CGSize {
        let sizeCacheIdentifier = SwapAccountSelectionListHeader.reuseIdentifier

        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }

        let width = calculateContentWidth(
            for: listView,
            forSectionAt: section
        )
        let newSize = SwapAccountSelectionListHeader.calculatePreferredSize(
            item,
            for: SwapAccountSelectionListHeader.theme,
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )

        sizeCache[sizeCacheIdentifier] = newSize

        return newSize
    }
}

extension SwapAccountSelectionListLayout {
    private func calculateContentWidth(
        for listView: UICollectionView,
        forSectionAt section: Int
    ) -> LayoutMetric {
        let sectionInset = self.collectionView(
            listView,
            layout: listView.collectionViewLayout,
            insetForSectionAt: section
        )
        return
            listView.bounds.width -
            listView.contentInset.horizontal -
            sectionInset.left -
            sectionInset.right
    }
}
