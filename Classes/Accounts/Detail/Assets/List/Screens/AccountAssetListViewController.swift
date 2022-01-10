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
//   AccountAssetListViewController.swift

import Foundation
import UIKit
import MacaroonUIKit

final class AccountAssetListViewController: BaseViewController {
    private lazy var theme = Theme()

    typealias DataSource = UICollectionViewDiffableDataSource<AccountAssetsSection, AccountAssetsItem>
    typealias Snapshot = NSDiffableDataSourceSnapshot<AccountAssetsSection, AccountAssetsItem>

    private lazy var listLayout = AccountAssetListLayout(account: account)

    private lazy var listView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = theme.listBackgroundColor.uiColor
        collectionView.register(AssetPortfolioItemCell.self)
        collectionView.register(SearchBarItemCell.self)
        collectionView.register(AssetPreviewCell.self)
        collectionView.register(header: SingleLineTitleActionHeaderView.self)
        collectionView.register(footer: AddAssetItemFooterView.self)
        return collectionView
    }()

    private let account: Account

    init(account: Account, configuration: ViewControllerConfiguration) {
        self.account = account
        super.init(configuration: configuration)
    }

    private lazy var dataSource: DataSource = {
        let dataSource = DataSource(collectionView: listView) {
            [weak self] collectionView, indexPath, identifier in
                guard let self = self else {
                    return nil
                }

                switch identifier {
                case .portfolio:
                    let cell = collectionView.dequeue(AssetPortfolioItemCell.self, at: indexPath)
                    cell.bindData(PortfolioValueViewModel(.singleAccount(value: .value(self.account.amount.toAlgos))))
                    return cell
                case .search:
                    return collectionView.dequeue(SearchBarItemCell.self, at: indexPath)
                case let .asset(assetDetail):
                    let cell = collectionView.dequeue(AssetPreviewCell.self, at: indexPath)

                    /// Algo preview
                    if assetDetail == nil {
                        cell.bindData(AssetPreviewViewModel(AssetPreviewModelAdapter.adapt(self.account)))
                        return cell
                    }

                    if let assetDetail = assetDetail,
                       let asset = self.account.assets?.first(matching: (\.id, assetDetail.id)) {
                        cell.bindData(
                            AssetPreviewViewModel(
                                AssetPreviewModelAdapter.adaptAssetSelection(
                                    (assetDetail, asset)
                                )
                            )
                        )
                    }

                    return cell
                }
        }

        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard let section = AccountAssetsSection(rawValue: indexPath.section),
                  section == .assets else {
                return nil
            }

            if kind == UICollectionView.elementKindSectionHeader {
                let view = collectionView.dequeueHeader(SingleLineTitleActionHeaderView.self, at: indexPath)
                view.bindData(
                    SingleLineTitleActionViewModel(
                        item: SingleLineIconTitleItem(
                            icon: nil,
                            title: .string("accounts-title-assets".localized)
                        )
                    )
                )
                return view
            }

            let view = collectionView.dequeueFooter(AddAssetItemFooterView.self, at: indexPath)
            view.delegate = self
            return view
        }

        return dataSource
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        applySnapshot(animatingDifferences: false)
    }

    override func prepareLayout() {
        super.prepareLayout()
        addListView()
        view.layoutIfNeeded()
    }

    override func linkInteractors() {
        super.linkInteractors()
        listView.dataSource = dataSource
        listView.delegate = listLayout
    }

    override func setListeners() {
        super.setListeners()
        setListActions()
    }
}

extension AccountAssetListViewController {
    private func addListView() {
        view.addSubview(listView)
        listView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension AccountAssetListViewController {
    private func setListActions() {
        listLayout.handlers.didSelectSearch = { [weak self] in
            guard let self = self else {
                return
            }

            let searchScreen = self.open(
                .assetSearch(account: self.account),
                by: .present
            ) as? AssetSearchViewController
            
            searchScreen?.handlers.didSelectAssetDetail = { [weak self] assetDetail in
                guard let self = self else {
                    return
                }

                self.openAssetDetail(assetDetail)
            }
        }

        listLayout.handlers.didSelectAlgoDetail = { [weak self] in
            guard let self = self else {
                return
            }

            self.openAssetDetail(nil)
        }

        listLayout.handlers.didSelectAssetDetail = { [weak self] assetDetail in
            guard let self = self else {
                return
            }

            self.openAssetDetail(assetDetail)
        }
    }

    private func openAssetDetail(
        _ assetDetail: AssetDetail?
    ) {
        open(
            .assetDetail(
                account: account,
                assetDetail: assetDetail
            ),
            by: .push
        )
    }

    private func applySnapshot(
        animatingDifferences: Bool = true
    ) {
        var snapshot = Snapshot()
        snapshot.appendSections([.portfolio, .assets])

        let portfolioSectionItems: [AccountAssetsItem] = [.portfolio]

        snapshot.appendItems(
            portfolioSectionItems,
            toSection: .portfolio
        )

        var assetSectionItems: [AccountAssetsItem] = []
        assetSectionItems.append(.search)
        assetSectionItems.append(.asset(asset: nil))
        account.assetDetails.forEach {
            assetSectionItems.append(.asset(asset: $0))
        }

        snapshot.appendItems(
            assetSectionItems,
            toSection: .assets
        )

        dataSource.apply(
            snapshot,
            animatingDifferences: animatingDifferences
        )
    }
}

extension AccountAssetListViewController: AddAssetItemFooterViewDelegate {
    func addAssetItemFooterViewDidTapAddAsset(_ addAssetItemFooterView: AddAssetItemFooterView) {
        let controller = open(.addAsset(account: account), by: .push)
        (controller as? AssetAdditionViewController)?.delegate = self
    }
}

extension AccountAssetListViewController: AssetAdditionViewControllerDelegate {
    func assetAdditionViewController(
        _ assetAdditionViewController: AssetAdditionViewController,
        didAdd assetSearchResult: AssetInformation,
        to account: Account
    ) {
        let assetDetail = AssetDetail(assetInformation: assetSearchResult)
        assetDetail.isRecentlyAdded = true
    }
}


enum AccountAssetsSection: Int, Hashable {
    case portfolio
    case assets
}

enum AccountAssetsItem: Hashable {
    case portfolio
    case search
    case asset(asset: AssetDetail?)
}
