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
//   HomeListDataSource.swift

import Foundation
import MacaroonUIKit
import UIKit

final class HomeListDataSource: UICollectionViewDiffableDataSource<HomeSection, HomeItem> {
    init(
        _ collectionView: UICollectionView
    ) {
        super.init(collectionView: collectionView) {
            collectionView, indexPath, itemIdentifier in
            
            switch itemIdentifier {
            case .empty(let item):
                switch item {
                case .loading:
                    return collectionView.dequeue(
                        HomeLoadingCell.self,
                        at: indexPath
                    )
                case .noContent:
                    let cell = collectionView.dequeue(
                        NoContentWithActionCell.self,
                        at: indexPath
                    )
                    cell.bindData(
                        HomeNoContentViewModel()
                    )
                    return cell
                }
            case .portfolio(let item):
                let cell = collectionView.dequeue(
                    HomePortfolioCell.self,
                    at: indexPath
                )
                cell.bindData(item)
                return cell
            case .announcement(let item):
                if item.isGeneric {
                    let cell = collectionView.dequeue(
                        GenericAnnouncementCell.self,
                        at: indexPath
                    )
                    cell.bindData(item)
                    return cell
                } else {
                    let cell = collectionView.dequeue(
                        GovernanceAnnouncementCell.self,
                        at: indexPath
                    )
                    cell.bindData(item)
                    return cell
                }
            case .account(let item):
                switch item {
                case .header(let headerItem):
                    let cell = collectionView.dequeue(
                        TitleWithAccessorySupplementaryCell.self,
                        at: indexPath
                    )
                    cell.bindData(headerItem)
                    return cell
                case .cell(let cellItem):
                    let cell = collectionView.dequeue(
                        AccountPreviewCell.self,
                        at: indexPath
                    )
                    cell.bindData(cellItem)
                    return cell
                }

            case .buyAlgo:
                return collectionView.dequeue(
                    BuyAlgoCell.self,
                    at: indexPath
                )
            }
        }

        [
            HomeLoadingCell.self,
            NoContentWithActionCell.self,
            HomePortfolioCell.self,
            GovernanceAnnouncementCell.self,
            GenericAnnouncementCell.self,
            BuyAlgoCell.self,
            TitleWithAccessorySupplementaryCell.self,
            AccountPreviewCell.self
        ].forEach {
            collectionView.register($0)
        }
    }
}
