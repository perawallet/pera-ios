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
//   AccountAssetListLayout.swift

import Foundation
import UIKit

final class AccountAssetListLayout: NSObject {
    private lazy var theme = Theme()
    lazy var handlers = Handlers()

    private let account: Account

    init(account: Account) {
        self.account = account
        super.init()
    }
}

extension AccountAssetListLayout: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        guard let section = AccountAssetsSection(rawValue: indexPath.section) else {
            return .zero
        }

        switch section {
        case .portfolio:
            return CGSize(theme.portfolioItemSize)
        case .assets:
            /// Search item size
            if indexPath.item == 0 {
                return CGSize(theme.searchItemSize)
            }

            return CGSize(theme.assetItemSize)
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        guard let section = AccountAssetsSection(rawValue: section) else {
            return .zero
        }

        switch section {
        case .portfolio:
            return .zero
        case .assets:
            return CGSize(theme.listHeaderSize)
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForFooterInSection section: Int
    ) -> CGSize {
        guard let section = AccountAssetsSection(rawValue: section) else {
            return .zero
        }

        switch section {
        case .portfolio:
            return .zero
        case .assets:
            return CGSize(theme.listFooterSize)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = AccountAssetsSection(rawValue: indexPath.section),
              section == .assets else {
            return
        }

        if indexPath.item == 0 {
            handlers.didSelectSearch?()
            return
        }

        if indexPath.item == 1 {
            handlers.didSelectAlgoDetail?()
            return
        }

        /// Reduce search and algos cells from index
        if let assetDetail = account.assetInformations[safe: indexPath.item - 2] {
            handlers.didSelectAssetDetail?(assetDetail)
        }
    }
}

extension AccountAssetListLayout {
    struct Handlers {
        var didSelectSearch: EmptyHandler?
        var didSelectAlgoDetail: EmptyHandler?
        var didSelectAssetDetail: ((AssetInformation) -> Void)?
    }
}
