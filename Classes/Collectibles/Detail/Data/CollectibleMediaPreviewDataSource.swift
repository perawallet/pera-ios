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

//   CollectibleMediaPreviewDataSource.swift

import Foundation
import MacaroonUIKit
import UIKit

final class CollectibleMediaPreviewDataSource:
    NSObject,
    UICollectionViewDataSource {
    private let theme: CollectibleMediaPreviewViewController.Theme
    private let asset: CollectibleAsset
    private let account: Account?

    init(
        theme: CollectibleMediaPreviewViewController.Theme,
        asset: CollectibleAsset,
        account: Account?
    ) {
        self.theme = theme
        self.asset = asset
        self.account = account
    }
}

extension CollectibleMediaPreviewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return asset.media.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let media = asset.media[safe: indexPath.item] else {
            fatalError("Could not find the related media.")
        }

        let width = collectionView.bounds.width - theme.horizontalInset * 2

        switch media.type {
        case .image:
            let cell = collectionView.dequeue(
                CollectibleMediaImagePreviewCell.self,
                at: indexPath
            )

            cell.bindData(
                CollectibleMediaImagePreviewViewModel(
                    imageSize: CGSize((width.float(), width.float())),
                    asset: asset,
                    account: account,
                    media: media
                )
            )

            return cell
        case .video:
            let cell = collectionView.dequeue(
                CollectibleMediaVideoPreviewCell.self,
                at: indexPath
            )

            cell.bindData(
                CollectibleMediaVideoPreviewViewModel(
                    media: media,
                    account: account
                )
            )

            return cell
        default:
            let cell = collectionView.dequeue(
                CollectibleMediaImagePreviewCell.self,
                at: indexPath
            )

            cell.bindData(
                CollectibleMediaImagePreviewViewModel(
                    imageSize: CGSize((width.float(), width.float())),
                    asset: asset,
                    account: account,
                    media: nil
                )
            )

            return cell
        }
    }
}
