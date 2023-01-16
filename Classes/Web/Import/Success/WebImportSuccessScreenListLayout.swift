// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   WebImportSuccessScreenListLayout.swift

import Foundation
import MacaroonUIKit
import UIKit

final class WebImportSuccessScreenListLayout: NSObject {
    private let listDataSource: WebImportSuccessScreenDataSource

    private let sectionHorizontalInsets: LayoutHorizontalPaddings = (24, 24)

    init(
        listDataSource: WebImportSuccessScreenDataSource
    ) {
        self.listDataSource = listDataSource
        super.init()
    }
}

extension WebImportSuccessScreenListLayout: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return UIEdgeInsets(
                (0, sectionHorizontalInsets.leading, 0, sectionHorizontalInsets.trailing)
            )
    }


    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {

        guard let itemIdentifier = listDataSource.itemIdentifier(for: indexPath) else {
            return CGSize((collectionView.bounds.width, 0))
        }

        let calculatedContentWidth = calculateContentWidth(for: collectionView)

        switch itemIdentifier {
        case .account:
            let theme = WebImportSuccessScreenTheme()
            return CGSize(width: calculatedContentWidth, height: theme.listItemHeight)
        case .header(let importedAccountCount):
            let viewModel = WebImportSuccessHeaderViewModel(importedAccountCount: importedAccountCount)
            return WebImportSuccessHeaderView.calculatePreferredSize(
                viewModel,
                for: WebImportSuccessHeaderViewTheme(),
                fittingIn: CGSize(width: calculatedContentWidth, height: .greatestFiniteMagnitude)
            )
        case .missingAccounts(let unimportedAccountCount):
            let viewModel = WebImportSuccessInfoBoxViewModel(unimportedAccountCount: unimportedAccountCount)
            return WebImportSuccessInfoBoxCell.calculatePreferredSize(
                viewModel,
                for: WebImportSuccessInfoBoxTheme(),
                fittingIn: CGSize(width: calculatedContentWidth, height: .greatestFiniteMagnitude)
            )
        }
    }
}

extension WebImportSuccessScreenListLayout {
    private func calculateContentWidth(
        for listView: UICollectionView
    ) -> LayoutMetric {
        return listView.bounds.width - sectionHorizontalInsets.leading - sectionHorizontalInsets.trailing
    }

    private func listView(
        _ listView: UICollectionView,
        layout listViewLayout: UICollectionViewLayout,
        atSection section: Int
    ) -> CGSize {
        let width = calculateContentWidth(for: listView)
        let sectionInset = collectionView(
            listView,
            layout: listViewLayout,
            insetForSectionAt: section
        )
        let height =
            listView.bounds.height -
            sectionInset.vertical -
            listView.adjustedContentInset.bottom
        return CGSize((width, height))
    }
}
