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
//   AccountPortfolioDataSource.swift

import UIKit

final class AccountPortfolioDataSource: NSObject {
    lazy var handlers = Handlers()

    typealias DataSource = UICollectionViewDiffableDataSource<AccountPortfolioSection, AccountPortfolioItem>
    typealias Snapshot = NSDiffableDataSourceSnapshot<AccountPortfolioSection, AccountPortfolioItem>

    private lazy var currentSnapshot = Snapshot()

    private weak var listView: UICollectionView?
    private let session: Session

    init(listView: UICollectionView, session: Session) {
        self.listView = listView
        self.session = session
    }

    private(set) lazy var dataSource: DataSource = {
        guard let listView = listView else {
            fatalError()
        }

        let dataSource = DataSource(collectionView: listView) {
            [weak self] collectionView, indexPath, identifier in
                guard let self = self else {
                    return nil
                }

                switch identifier {
                case .portfolio:
                    let cell = collectionView.dequeue(AccountPortfolioCell.self, at: indexPath)
                    cell.bindData(AccountPortfolioViewModel(self.session.accounts, currency: self.session.preferredCurrencyDetails))

                    cell.contextView.handlers.didTapPortfolioTitle = { [weak self] in
                        guard let self = self else {
                            return
                        }

                        self.handlers.didTapPortfolioTitle?()
                    }

                    return cell
                case .announcement:
                    let cell = collectionView.dequeue(AnnouncementBannerCell.self, at: indexPath)
                    cell.bindData(AnnouncementBannerViewModel())
                    return cell
                case let .standardAccount(account):
                    let cell = collectionView.dequeue(AccountPreviewCell.self, at: indexPath)
                    cell.bindData(AccountPreviewViewModel(from: account))
                    return cell
                case let .watchAccount(account):
                    let cell = collectionView.dequeue(AccountPreviewCell.self, at: indexPath)
                    cell.bindData(AccountPreviewViewModel(from: account))
                    return cell
                }
            }

        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionHeader,
                  let section = AccountPortfolioSection(rawValue: indexPath.section),
                  section == .standardAccount || section == .watchAccount else {
                return nil
            }

            let title = section == .watchAccount ? "portfolio-title-watchlist".localized : "portfolio-title-accounts".localized
            let view = collectionView.dequeueHeader(SingleLineTitleActionHeaderView.self, at: indexPath)
            view.bindData(
                SingleLineTitleActionViewModel(
                    item: SingleLineIconTitleItem(
                        icon: "icon-options",
                        title: .string(title)
                    )
                )
            )

            view.handlers.didHandleAction = { [weak self] in
                guard let self = self else {
                    return
                }

                self.handlers.didSelectSection?(section)
            }

            return view
        }

        return dataSource
    }()
}

extension AccountPortfolioDataSource {
    func applySnapshot(
        animatingDifferences: Bool = true
    ) {
        guard !session.accounts.isEmpty else {
            return
        }

        var snapshot = Snapshot()

        snapshot.appendSections([.portfolio])
        snapshot.appendItems(
            [.portfolio],
            toSection: .portfolio
        )

        snapshot.appendSections([.announcement])

        /// <todo> Add Announcement Section

        let nonWatchAccounts = session.accounts.filter { $0.type != .watch }

        if !nonWatchAccounts.isEmpty {
            snapshot.appendSections([.standardAccount])

            var nonWatchAccountSectionItems: [AccountPortfolioItem] = []
            nonWatchAccounts.forEach {
                nonWatchAccountSectionItems.append(.standardAccount(account: $0))
            }

            snapshot.appendItems(
                nonWatchAccountSectionItems,
                toSection: .standardAccount
            )
        }

        let watchAccounts = session.accounts.filter { $0.type == .watch }

        if !watchAccounts.isEmpty {
            snapshot.appendSections([.watchAccount])

            var watchAccountSectionItems: [AccountPortfolioItem] = []
            watchAccounts.forEach {
                watchAccountSectionItems.append(.watchAccount(account: $0))
            }

            snapshot.appendItems(
                watchAccountSectionItems,
                toSection: .watchAccount
            )
        }

        dataSource.apply(
            snapshot,
            animatingDifferences: animatingDifferences
        )

        currentSnapshot = snapshot
    }
}

extension AccountPortfolioDataSource {
    struct Handlers {
        var didTapPortfolioTitle: EmptyHandler?
        var didSelectSection: ((AccountPortfolioSection) -> Void)?
    }
}

enum AccountPortfolioSection: Int, Hashable {
    case portfolio
    case announcement
    case standardAccount
    case watchAccount
}

enum AccountPortfolioItem: Hashable {
    case portfolio
    case announcement
    case standardAccount(account: Account)
    case watchAccount(account: Account)
}
