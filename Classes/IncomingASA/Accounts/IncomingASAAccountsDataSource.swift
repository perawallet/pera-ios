// Copyright 2022-2025 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   IncomingASAAccountsDataSource.swift

import Foundation
import MacaroonUIKit
import UIKit

final class IncomingASAAccountsDataSource: UICollectionViewDiffableDataSource<IncomingASAAccountsSection, IncomingASAAccountsItem> {
    init(
        _ collectionView: UICollectionView
    ) {
        super.init(collectionView: collectionView) {
            collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .empty:
                let cell = collectionView.dequeue(
                    NoContentCell.self,
                    at: indexPath
                )
                cell.bindData(
                    IncomingASAAccountsNoContentViewModel()
                )
                return cell
            case .account(let cellItem):
                let cell = collectionView.dequeue(
                    IncomingASAAccountCell.self,
                    at: indexPath
                )
                cell.bindData(cellItem)
                return cell
            }
        }

        [
            NoContentCell.self,
            IncomingASAAccountCell.self
        ].forEach {
            collectionView.register($0)
        }
    }
}
