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
//   HomeListLayout.swift

import Foundation
import MacaroonUIKit
import UIKit

final class HomeListLayout: NSObject {
    private var sizeCache: [String: CGSize] = [:]
    
    private let listDataSource: HomeListDataSource

    private let sectionHorizontalInsets: LayoutHorizontalPaddings = (24, 24)

    init(
        listDataSource: HomeListDataSource
    ) {
        self.listDataSource = listDataSource
        super.init()
    }
    
    class func build() -> UICollectionViewLayout {
        return UICollectionViewFlowLayout()
    }
}

extension HomeListLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        let sectionIdentifiers = listDataSource.snapshot().sectionIdentifiers
        
        guard let section = sectionIdentifiers[safe: section] else {
            return .zero
        }
        
        var insets =
            UIEdgeInsets(
                (0, sectionHorizontalInsets.leading, 0, sectionHorizontalInsets.trailing)
            )
        
        switch section {
        case .empty:
            return .zero
        case .portfolio:
            insets.top = sectionIdentifiers.contains(.announcement) ? 24 : 72
            insets.bottom = 40
            return insets
        case .announcement:
            return insets
        case .accounts:
            insets.top = 40
            insets.bottom = 8
            return insets
        case .watchAccounts:
            insets.top = 24
            insets.bottom = 8
            return insets
        }
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
        case .empty(let item):
            return listView(
                collectionView,
                layout: collectionViewLayout,
                sizeForEmptyItem: item
            )
        case .portfolio(let item):
            return listView(
                collectionView,
                layout: collectionViewLayout,
                sizeForPortfolioItem: item
            )
        case .announcement:
            return CGSize((calculateContentWidth(for: collectionView), 0))
        case .account:
            return CGSize((calculateContentWidth(for: collectionView), 72))
        }
    }

//    func collectionView(
//        _ collectionView: UICollectionView,
//        layout collectionViewLayout: UICollectionViewLayout,
//        referenceSizeForHeaderInSection section: Int
//    ) -> CGSize {
//        guard let section = AccountPortfolioSection(rawValue: section) else {
//            return .zero
//        }
//
//        switch section {
//        case .portfolio,
//                .announcement:
//            return .zero
//        case .standardAccount,
//                .watchAccount:
//            return CGSize(theme.listHeaderSize)
//              (UIScreen.main.bounds.width, 40)
//        }
//    }
}

extension HomeListLayout {
    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForEmptyItem item: HomeEmptyItem
    ) -> CGSize {
        let width = listView.bounds.width
        let height = listView.bounds.height - listView.adjustedContentInset.bottom
        return CGSize((width, height))
    }
    
    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForPortfolioItem item: HomePortfolioViewModel
    ) -> CGSize {
        let sizeCacheIdentifier = HomePortfolioCell.reuseIdentifier
        
        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }
        
        let width = calculateContentWidth(for: listView)
        let newSize = HomePortfolioCell.calculatePreferredSize(
            item,
            for: HomePortfolioCell.theme,
            fittingIn: CGSize((width, .greatestFiniteMagnitude)))
        
        sizeCache[sizeCacheIdentifier] = newSize
        
        return newSize
    }
}

extension HomeListLayout {
    private func calculateContentWidth(
        for listView: UICollectionView
    ) -> LayoutMetric {
        return
            listView.bounds.width -
            listView.contentInset.horizontal -
            sectionHorizontalInsets.leading -
            sectionHorizontalInsets.trailing
    }
}
