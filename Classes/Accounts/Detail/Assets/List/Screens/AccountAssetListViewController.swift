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
    private lazy var listLayout = AccountAssetListLayout(accountHandle: accountHandle)
    private lazy var dataSource = AccountAssetListDataSource(listView)
    private lazy var dataController = AccountAssetListLocalDataController(sharedDataController)

    typealias DataSource = UICollectionViewDiffableDataSource<AccountAssetsSection, AccountAssetsItem>
    typealias Snapshot = NSDiffableDataSourceSnapshot<AccountAssetsSection, AccountAssetsItem>

    private lazy var listView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = theme.listBackgroundColor.uiColor
        return collectionView
    }()

    private lazy var transactionActionButton = FloatingActionItemButton(hasTitleLabel: false)
    
    private let accountHandle: AccountHandle

    init(accountHandle: AccountHandle, configuration: ViewControllerConfiguration) {
        self.accountHandle = accountHandle
        super.init(configuration: configuration)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        dataController.eventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .didUpdate(let snapshot):
                self.dataSource.apply(snapshot, animatingDifferences: self.isViewAppeared)
            }
        }
        dataController.load()
        dataController.deliverContentSnapshot(for: accountHandle)
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
                .assetSearch(account: self.accountHandle.value),
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
        _ assetDetail: AssetInformation?
    ) {
        let screen: Screen
        if let assetDetail = assetDetail {
            screen = .assetDetail(draft: AssetTransactionListing(account: accountHandle.value, assetDetail: assetDetail))
        } else {
            screen = .algosDetail(draft: AlgoTransactionListing(account: accountHandle.value))
        }

        open(screen, by: .push)
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
        log(SendAssetDetailEvent(address: accountHandle.value.address))
        let controller = open(.assetSelection(account: accountHandle.value), by: .present) as? SelectAssetViewController
        let closeBarButtonItem = ALGBarButtonItem(kind: .close) {
            controller?.closeScreen(by: .dismiss, animated: true)
        }
        controller?.leftBarButtonItems = [closeBarButtonItem]
    }

    func transactionFloatingActionButtonViewControllerDidReceive(_ viewController: TransactionFloatingActionButtonViewController) {
        log(ReceiveAssetDetailEvent(address: accountHandle.value.address))
        let draft = QRCreationDraft(address: accountHandle.value.address, mode: .address, title: accountHandle.value.name)
        open(.qrGenerator(title: accountHandle.value.name ?? accountHandle.value.address.shortAddressDisplay(), draft: draft, isTrackable: true), by: .present)
    }
}

extension AccountAssetListViewController: AddAssetItemFooterViewDelegate {
    func addAssetItemFooterViewDidTapAddAsset(_ addAssetItemFooterView: AddAssetItemFooterView) {
        let controller = open(.addAsset(account: accountHandle.value), by: .push)
        (controller as? AssetAdditionViewController)?.delegate = self
    }
}

extension AccountAssetListViewController {
    func addAsset(_ assetDetail: AssetInformation) {
        dataController.addedAssetDetails.append(assetDetail)
        // dataSource.apply(snapshot, animatingDifferences: true)
    }

    func removeAsset(_ assetDetail: AssetInformation) {
        dataController.removedAssetDetails.append(assetDetail)
        // dataSource.apply(snapshot, animatingDifferences: true)
    }
}

extension AccountAssetListViewController: AssetAdditionViewControllerDelegate {
    func assetAdditionViewController(
        _ assetAdditionViewController: AssetAdditionViewController,
        didAdd assetSearchResult: AssetInformation,
        to account: Account
    ) {
        assetSearchResult.isRecentlyAdded = true
        addAsset(assetSearchResult)
    }
}
