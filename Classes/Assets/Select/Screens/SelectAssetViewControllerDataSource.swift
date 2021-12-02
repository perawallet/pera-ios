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
//   SelectAssetViewControllerDataSource.swift


import Foundation
import UIKit

final class SelectAssetViewControllerDataSource: NSObject {
    private var assetDetails: [AssetDetail] = []
    private let account: Account

    init(account: Account) {
        self.account = account
        super.init()

        assetDetails = account.assetDetails
    }
}

extension SelectAssetViewControllerDataSource:
UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assetDetails.count.advanced(by: 1)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(AssetPreviewCell.self, at: indexPath)
        cell.customize(AssetPreviewViewCommonTheme())

        if indexPath.item == 0 {
            cell.bindData(
                AssetPreviewViewModel(AssetPreviewModelAdapter.adapt(account))
            )
        } else {
            if let assetDetail = assetDetails[safe: indexPath.item.advanced(by: -1)], let asset = account.assets?.first(matching: (\.id, assetDetail.id)) {
                cell.bindData(
                    AssetPreviewViewModel(AssetPreviewModelAdapter.adaptAssetSelection((assetDetail, asset)))
                )
            }
        }

        return cell
    }

}
