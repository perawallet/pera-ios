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
//   AccountPortfolioViewController.swift

import Foundation
import UIKit
import MacaroonUIKit

final class AccountPortfolioViewController: BaseViewController {

    typealias DataSource = UICollectionViewDiffableDataSource<AccountPortfolioSection, AccountPortfolioItem>
    typealias Snapshot = NSDiffableDataSourceSnapshot<AccountPortfolioSection, AccountPortfolioItem>

    private lazy var listView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(AccountPortfolioCell.self)
        collectionView.register(AccountPreviewCell.self)
        collectionView.register(AnnouncementBannerCell.self)
        collectionView.register(header: SingleLineTitleActionHeaderView.self)
        return collectionView
    }()

    private lazy var dataSource: DataSource = {
        let dataSource = DataSource(collectionView: listView) {
            [weak self] collectionView, indexPath, identifier in
                guard let self = self else {
                    return nil
                }

                switch identifier {
                case .empty:
                    let cell = collectionView.dequeue(AccountPreviewCell.self, at: indexPath)
                    return cell
                case .portfolio:
                    let cell = collectionView.dequeue(AccountPortfolioCell.self, at: indexPath)
                    return cell
                case .announcement:
                    let cell = collectionView.dequeue(AnnouncementBannerCell.self, at: indexPath)
                    return cell
                case .standardAccount,
                        .watchAccount:
                    let cell = collectionView.dequeue(AccountPreviewCell.self, at: indexPath)
                    return cell
                }
            }

        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionHeader,
                  let section = AccountPortfolioSection(rawValue: indexPath.section),
                  section == .standardAccount || section == .watchAccount else {
                return nil
            }

            let view = collectionView.dequeueHeader(SingleLineTitleActionHeaderView.self, at: indexPath)
            return view
        }

        return dataSource
    }()

    override func prepareLayout() {
        super.prepareLayout()
        addListView()
    }
}

extension AccountPortfolioViewController {
    private func addListView() {
        view.addSubview(listView)
        listView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension AccountPortfolioViewController {
    private func applySnapshot(animatingDifferences: Bool = true) {
      let snapshot = Snapshot()
      // snapshot.appendSections(sections)
      // sections.forEach { section in
        // snapshot.appendItems(section.videos, toSection: section)
      // }
      dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
}

enum AccountPortfolioSection: Int, Hashable {
    case portfolio
    case announcement
    case standardAccount
    case watchAccount
}

enum AccountPortfolioItem: Hashable {
    case empty
    case portfolio
    case announcement
    case standardAccount
    case watchAccount
}
