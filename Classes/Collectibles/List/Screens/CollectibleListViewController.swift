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

//   CollectibleListViewController.swift

import UIKit
import MacaroonUIKit

final class CollectibleListViewController:
    BaseViewController,
    UICollectionViewDelegateFlowLayout {
    typealias EventHandler = (Event) -> Void

    var eventHandler: EventHandler?

    private lazy var listView: UICollectionView = {
        let collectionViewLayout = CollectibleListLayout.build()
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: collectionViewLayout
        )
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .onDrag
        collectionView.backgroundColor = .clear
        return collectionView
    }()

    private lazy var listLayout = CollectibleListLayout(listDataSource: listDataSource)
    private lazy var listDataSource = CollectibleListDataSource(listView)

    private let dataController: CollectibleListDataController

    init(
        dataController: CollectibleListDataController,
        configuration: ViewControllerConfiguration
    ) {
        self.dataController = dataController
        super.init(configuration: configuration)
    }

    override func prepareLayout() {
        super.prepareLayout()
        build()
    }

    override func setListeners() {
        super.setListeners()

        listView.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        listView
            .visibleCells
            .forEach { cell in 
                switch cell {
                case is CollectibleListLoadingViewCell:
                    let loadingCell = cell as? CollectibleListLoadingViewCell
                    loadingCell?.restartAnimating()
                case is CollectibleListItemPendingCell:
                    let pendingCell = cell as? CollectibleListItemPendingCell
                    pendingCell?.startLoading()
                default:
                    break
                }
            }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        listView
            .visibleCells
            .forEach { cell in
                switch cell {
                case is CollectibleListLoadingViewCell:
                    let loadingCell = cell as? CollectibleListLoadingViewCell
                    loadingCell?.stopAnimating()
                case is CollectibleListItemPendingCell:
                    let pendingCell = cell as? CollectibleListItemPendingCell
                    pendingCell?.stopLoading()
                default:
                    break
                }
            }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.layoutIfNeeded()

        let imageWidth = listLayout.calculateGridCellWidth(
            listView,
            layout: listView.collectionViewLayout
        )
        let imageSize = CGSize((imageWidth, imageWidth))
        dataController.imageSize = imageSize

        dataController.eventHandler = {
            [weak self] event in
            guard let self = self else {
                return
            }

            switch event {
            case .didUpdate(let snapshot):
                if let accountAddress = self.dataController.galleryAccount.singleAccount?.value.address,
                    let accountHandle = self.sharedDataController.accountCollection[accountAddress] {
                    self.eventHandler?(.didUpdate(accountHandle))
                }

                self.listDataSource.apply(snapshot, animatingDifferences: self.isViewAppeared)
            }
        }

        dataController.load()
    }

    private func build() {
        addListView()
    }
}

extension CollectibleListViewController {
    private func addListView() {
        view.addSubview(listView)
        listView.snp.makeConstraints {
            $0.setPaddings()
        }
    }
}

extension CollectibleListViewController {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return listLayout.collectionView(
            collectionView,
            layout: collectionViewLayout,
            insetForSectionAt: section
        )
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return listLayout.collectionView(
            collectionView,
            layout: collectionViewLayout,
            sizeForItemAt: indexPath
        )
    }

    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard let itemIdentifier = listDataSource.itemIdentifier(for: indexPath) else {
            return
        }

        switch itemIdentifier {
        case .infoWithFilter:
            linkInteractors(cell as! CollectibleListInfoWithFilterCell)
        case .search:
            linkInteractors(cell as! CollectibleListSearchInputCell)
        case .empty(let item):
            switch item {
            case .loading:
                let loadingCell = cell as? CollectibleListLoadingViewCell
                loadingCell?.startAnimating()
            case .noContent:
                linkInteractors(cell as! NoContentWithActionIllustratedCell)
            default:
                break
            }
        case .collectible(let item):
            switch item {
            case .cell(let item):
                switch item {
                case .pending:
                    let pendingCell = cell as? CollectibleListItemPendingCell
                    pendingCell?.startLoading()
                default:
                    break
                }
            default:
                break
            }
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplaying cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard let itemIdentifier = listDataSource.itemIdentifier(for: indexPath) else {
            return
        }

        switch itemIdentifier {
        case .empty(let item):
            switch item {
            case .loading:
                let loadingCell = cell as? CollectibleListLoadingViewCell
                loadingCell?.stopAnimating()
            default:
                break
            }
        case .collectible(let item):
            switch item {
            case .cell(let item):
                switch item {
                case .pending:
                    let pendingCell = cell as? CollectibleListItemPendingCell
                    pendingCell?.stopLoading()
                default:
                    break
                }
            default:
                break
            }
        default:
            break
        }
    }
}

extension CollectibleListViewController {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let itemIdentifier = listDataSource.itemIdentifier(for: indexPath) else {
            return
        }

        view.endEditing(true)

        switch itemIdentifier {
        case .collectible(let item):
            switch item {
            case .cell(let cell):
                switch cell {
                case .owner(let item):
                    let cell = collectionView.cellForItem(at: indexPath) as? CollectibleListItemCell
                    openCollectibleDetail(
                        account: item.account,
                        asset: item.asset,
                        thumbnailImage: cell?.contextView.currentImage
                    )
                case .optedIn(let item):
                    let cell = collectionView.cellForItem(at: indexPath) as? CollectibleListItemOptedInCell
                    openCollectibleDetail(
                        account: item.account,
                        asset: item.asset,
                        thumbnailImage: cell?.contextView.currentImage
                    )
                default:
                    break
                }
            case .footer:
                openReceiveCollectibleAccountList()
            }
        default:
            break
        }
    }
}

extension CollectibleListViewController {
    private func linkInteractors(
        _ cell: NoContentWithActionIllustratedCell
    ) {
        cell.handlers.didTapActionView = {
            [weak self] in
            guard let self = self else {
                return
            }

            self.openReceiveCollectibleAccountList()
        }
    }

    private func linkInteractors(
        _ cell: CollectibleListInfoWithFilterCell
    ) {
        cell.observe(event: .showFilterSelection) {
            [weak self] in
            guard let self = self else {
                return
            }

            let controller = self.open(
                .collectiblesFilterSelection(
                    filter: self.dataController.currentFilter
                ),
                by: .present
            ) as? CollectiblesFilterSelectionViewController

            controller?.handlers.didTapDone = {
                [weak self] filter in
                guard let self = self else {
                    return
                }

                self.dataController.filter(
                    forFilter: filter
                )
            }
        }
    }

    private func linkInteractors(
        _ cell: CollectibleListSearchInputCell
    ) {
        cell.delegate = self
    }
}

extension CollectibleListViewController {
    private func openCollectibleDetail(
        account: Account,
        asset: CollectibleAsset,
        thumbnailImage: UIImage?
    ) {
        let controller = open(
            .collectibleDetail(
                asset: asset,
                account: account,
                thumbnailImage: thumbnailImage
            ),
            by: .push
        ) as? CollectibleDetailViewController
        controller?.eventHandlers.didOptOutAssetFromAccount = {
            [weak self] (asset, account) in
            guard let self = self else {
                return
            }

            controller?.popScreen()

            self.bannerController?.presentSuccessBanner(
                title: "collectible-detail-opt-out-success".localized(
                    params: asset.title ?? asset.name ?? .empty
                )
            )

            NotificationCenter.default.post(
                name: CollectibleListLocalDataController.didAddPendingRemovedCollectible,
                object: self,
                userInfo: [
                    CollectibleListLocalDataController.assetUserInfoKey: (account, asset)
                ]
            )
        }
    }

    private func openReceiveCollectibleAccountList() {
        eventHandler?(.didTapReceive)
    }
}

extension CollectibleListViewController: SearchInputViewDelegate {
    func searchInputViewDidEdit(_ view: SearchInputView) {
        guard let query = view.text else {
            return
        }

        if query.isEmpty {
            dataController.resetSearch()
            return
        }

        dataController.search(for: query)
    }

    func searchInputViewDidReturn(_ view: SearchInputView) {
        view.endEditing()
    }
}

extension CollectibleListViewController {
    enum Event {
        case didUpdate(AccountHandle)
        case didTapReceive
    }
}
