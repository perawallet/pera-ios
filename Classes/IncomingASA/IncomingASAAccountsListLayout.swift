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

//   IncomingASAAccountsListLayout.swift

import Foundation
import MacaroonUIKit
import UIKit

final class IncomingASAAccountsListLayout: NSObject {
    lazy var handlers = Handlers()
    
    private var sizeCache: [String: CGSize] = [:]

    private lazy var theme = Theme()

    private let listDataSource: IncomingASAAccountsDataSource

    init(listDataSource: IncomingASAAccountsDataSource) {
        self.listDataSource = listDataSource
        super.init()
    }

    class func build() -> UICollectionViewLayout {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0
        return flowLayout
    }
}

extension IncomingASAAccountsListLayout {
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
        case .account:
            return listView(
                collectionView,
                layout: collectionViewLayout,
                atSection: indexPath.section
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



extension IncomingASAAccountsListLayout {
    
    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        atSection section: Int
    ) -> CGSize {
        return self.listView(
            listView,
            layout: listViewLayout,
            sizeForAccountCellItemAtSection: section
        )
    }
    
        
    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        sizeForAccountCellItemAtSection section: Int
    ) -> CGSize {
        let sizeCacheIdentifier = HomeAccountCell.reuseIdentifier
        
        if let cachedSize = sizeCache[sizeCacheIdentifier] {
            return cachedSize
        }
        
        let width = calculateContentWidth(
            listView,
            forSectionAt: section
        )
        let sampleAccountListItem = CustomAccountListItem(
            address: "someAlgorandAddress",
            icon: "icon-standard-account".uiImage,
            title: "title-unknown".localized,
            subtitle: "title-plus-asset-singular-count".localized(params: "1")
        )
        let sampleAccountItem = AccountListItemViewModel(sampleAccountListItem)
        let newSize = HomeAccountCell.calculatePreferredSize(
            sampleAccountItem,
            for: HomeAccountCell.theme,
            fittingIn: CGSize((width, .greatestFiniteMagnitude))
        )
        
        sizeCache[sizeCacheIdentifier] = newSize
        
        return newSize
    }

}

extension IncomingASAAccountsListLayout {
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

extension IncomingASAAccountsListLayout {
    struct Handlers {
        var willDisplay: ((UICollectionViewCell, IndexPath) -> Void)?
    }
}
