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
//   AssetListViewLayoutBuilder.swift

import Foundation
import Macaroon

final class AssetListViewLayoutBuilder: NSObject, UICollectionViewDelegateFlowLayout {
    weak var delegate: AssetListViewLayoutBuilderDelegate?

    private let theme: AssetListViewController.Theme

    init(theme: AssetListViewController.Theme) {
        self.theme = theme
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(theme.cellSize)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        delegate?.assetListViewLayoutBuilder(self, willDisplayItemAt: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.assetListViewLayoutBuilder(self, didSelectItemAt: indexPath)
    }
}

protocol AssetListViewLayoutBuilderDelegate: AnyObject {
    func assetListViewLayoutBuilder(
        _ assetListViewLayoutBuilder: AssetListViewLayoutBuilder,
        willDisplayItemAt indexPath: IndexPath
    )
    func assetListViewLayoutBuilder(
        _ assetListViewLayoutBuilder: AssetListViewLayoutBuilder,
        didSelectItemAt indexPath: IndexPath
    )
}
