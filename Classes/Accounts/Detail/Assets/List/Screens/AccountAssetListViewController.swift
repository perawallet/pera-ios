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
    private lazy var listLayout = AccountAssetListLayout(account: account)

    typealias DataSource = UICollectionViewDiffableDataSource<AccountAssetsSection, AccountAssetsItem>
    typealias Snapshot = NSDiffableDataSourceSnapshot<AccountAssetsSection, AccountAssetsItem>

    private lazy var listView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = theme.listBackgroundColor.uiColor
        collectionView.register(AssetPortfolioItemCell.self)
        collectionView.register(SearchBarItemCell.self)
        collectionView.register(AssetPreviewCell.self)
        collectionView.register(PendingAssetPreviewCell.self)
        collectionView.register(header: SingleLineTitleActionHeaderView.self)
        collectionView.register(footer: AddAssetItemFooterView.self)
        return collectionView
    }()

    private lazy var transactionActionButton = FloatingActionItemButton(hasTitleLabel: false)

    private var addedAssetDetails = [AssetDetail]()
    private var removedAssetDetails = [AssetDetail]()

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
                    let currency = self.session?.preferredCurrencyDetails
                    if let totalPortfolioValue = self.calculatePortfolio(for: [self.account], with: currency) {
                        cell.bindData(PortfolioValueViewModel(.singleAccount(value: .value(totalPortfolioValue)), currency))
                    } else {
                        cell.bindData(PortfolioValueViewModel(.singleAccount(value: .unknown), nil))
                    }

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
                case let .pendingAsset(assetDetail):
                    let cell = collectionView.dequeue(PendingAssetPreviewCell.self, at: indexPath)

                    if let assetDetail = assetDetail {
                        cell.bindData(
                            PendingAssetPreviewViewModel(
                                AssetPreviewModelAdapter.adaptPendingAsset(
                                    assetDetail
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
        addTransactionActionButton(theme)
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
        setTransactionActionButtonAction()
    }
}

extension AccountAssetListViewController {
    private func addListView() {
        view.addSubview(listView)
        listView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    private func addTransactionActionButton(_ theme: Theme) {
        transactionActionButton.image = "fab-swap".uiImage

        view.addSubview(transactionActionButton)
        transactionActionButton.snp.makeConstraints {
            $0.setPaddings(theme.transactionActionButtonPaddings)
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
        let screen: Screen
        if let assetDetail = assetDetail {
            screen = .assetDetail(draft: AssetTransactionListing(account: account, assetDetail: assetDetail))
        } else {
            screen = .algosDetail(draft: AlgoTransactionListing(account: account))
        }

        open(screen, by: .push)
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

        clearAddedAssetDetailsIfNeeded()
        clearRemovedAssetDetailsIfNeeded()

        addedAssetDetails.forEach {
            assetSectionItems.append(.pendingAsset(asset: $0))
        }

        removedAssetDetails.forEach {
            assetSectionItems.append(.pendingAsset(asset: $0))
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

    private func clearAddedAssetDetailsIfNeeded() {
        addedAssetDetails = addedAssetDetails.filter { !account.assetDetails.contains($0) }
    }

    private func clearRemovedAssetDetailsIfNeeded() {
        removedAssetDetails = removedAssetDetails.filter { account.assetDetails.contains($0) }
    }
}

extension AccountAssetListViewController {
    private func setTransactionActionButtonAction() {
        transactionActionButton.addTarget(self, action: #selector(didTapTransactionActionButton), for: .touchUpInside)
    }

    @objc
    private func didTapTransactionActionButton() {
        let viewController = open(
            .transactionFloatingActionButton,
            by: .customPresentWithoutNavigationController(
                presentationStyle: .overCurrentContext,
                transitionStyle: nil,
                transitioningDelegate: nil
            ),
            animated: false
        ) as? TransactionFloatingActionButtonViewController

        viewController?.delegate = self
    }
}

extension AccountAssetListViewController: TransactionFloatingActionButtonViewControllerDelegate {
    func transactionFloatingActionButtonViewControllerDidSend(_ viewController: TransactionFloatingActionButtonViewController) {
        log(SendAssetDetailEvent(address: account.address))
        let controller = open(.assetSelection(account: account), by: .present) as? SelectAssetViewController
        let closeBarButtonItem = ALGBarButtonItem(kind: .close) {
            controller?.closeScreen(by: .dismiss, animated: true)
        }
        controller?.leftBarButtonItems = [closeBarButtonItem]
    }

    func transactionFloatingActionButtonViewControllerDidReceive(_ viewController: TransactionFloatingActionButtonViewController) {
        log(ReceiveAssetDetailEvent(address: account.address))
        let draft = QRCreationDraft(address: account.address, mode: .address, title: account.name)
        open(.qrGenerator(title: account.name ?? account.address.shortAddressDisplay(), draft: draft, isTrackable: true), by: .present)
    }
}

extension AccountAssetListViewController: AddAssetItemFooterViewDelegate {
    func addAssetItemFooterViewDidTapAddAsset(_ addAssetItemFooterView: AddAssetItemFooterView) {
        let controller = open(.addAsset(account: account), by: .push)
        (controller as? AssetAdditionViewController)?.delegate = self
    }
}

extension AccountAssetListViewController {
    func addAsset(_ assetDetail: AssetDetail) {
        addedAssetDetails.append(assetDetail)
        applySnapshot()
    }

    func removeAsset(_ assetDetail: AssetDetail) {
        removedAssetDetails.append(assetDetail)
        applySnapshot()
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
        addAsset(assetDetail)
    }
}

extension AccountAssetListViewController: PortfolioCalculating { }

enum AccountAssetsSection: Int, Hashable {
    case portfolio
    case assets
}

enum AccountAssetsItem: Hashable {
    case portfolio
    case search
    case asset(asset: AssetDetail?)
    case pendingAsset(asset: AssetDetail?)
}
