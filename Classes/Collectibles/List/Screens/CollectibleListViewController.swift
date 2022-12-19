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

    private lazy var modalTransition = BottomSheetTransition(presentingViewController: self)

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
        collectionView.contentInset.bottom = theme.listContentBottomInset
        collectionView.backgroundColor = .clear
        return collectionView
    }()

    private lazy var listLayout = CollectibleListLayout(listDataSource: listDataSource)
    private lazy var listDataSource = CollectibleListDataSource(listView)

    private var positionYForDisplayingListHeader: CGFloat?

    private var collectibleGalleryUIStyleStore: CollectibleGalleryUIStyleStore = .init()

    private let dataController: CollectibleListDataController
    private let copyToClipboardController: CopyToClipboardController

    private let theme: CollectibleListViewControllerTheme

    init(
        dataController: CollectibleListDataController,
        copyToClipboardController: CopyToClipboardController,
        theme: CollectibleListViewControllerTheme = .common,
        configuration: ViewControllerConfiguration
    ) {
        self.dataController = dataController
        self.copyToClipboardController = copyToClipboardController
        self.theme = theme

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
                self.eventHandler?(.didUpdateSnapshot)
                self.listDataSource.apply(snapshot, animatingDifferences: self.isViewAppeared)
            case .didFinishRunning(let hasError):
                self.eventHandler?(.didFinishRunning(hasError: hasError))
            }
        }

        dataController.load()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        restartLoadingOfVisibleCellsIfNeeded()
    }

    private func build() {
        addListView()
    }
}

extension CollectibleListViewController {
    private func restartLoadingOfVisibleCellsIfNeeded() {
        for cell in listView.visibleCells {
            if let pendingCollectibleGridItemCell = cell as? PendingCollectibleGridItemCell,
               pendingCollectibleGridItemCell.isLoading {
                pendingCollectibleGridItemCell.isLoading = true
                return
            }

            if let pendingCollectibleListItemCell = cell as? PendingCollectibleAssetListItemCell,
               pendingCollectibleListItemCell.isLoading {
                pendingCollectibleListItemCell.isLoading = true
                return
            }

            if let listLoadingCell = cell as? CollectibleListLoadingViewCell {
                listLoadingCell.restartAnimating()
                return
            }
        }
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
        case .header:
            positionYForDisplayingListHeader = cell.frame.maxY
            linkInteractors(cell as! ManagementItemWithSecondaryActionCell)
        case .watchAccountHeader:
            linkInteractors(cell as! ManagementItemCell)
        case .uiActions:
            linkInteractors(cell as! CollectibleGalleryUIActionsCell)
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
        case .pendingCollectibleAsset(let item):
            switch item {
            case .grid:
                let cell = cell as? PendingCollectibleGridItemCell
                cell?.isLoading = true
            case .list:
                let cell = cell as? PendingCollectibleAssetListItemCell
                cell?.isLoading = true
            }
        default: break
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
        case .pendingCollectibleAsset(let item):
            switch item {
            case .grid:
                let cell = cell as? PendingCollectibleGridItemCell
                cell?.isLoading = false
            case .list:
                let cell = cell as? PendingCollectibleAssetListItemCell
                cell?.isLoading = false
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

        endEditing()

        switch itemIdentifier {
        case .collectibleAsset(let item):
            var currentImage: UIImage?

            if let gridItemCell = collectionView.cellForItem(at: indexPath) as? CollectibleListItemCell {
                currentImage = gridItemCell.contextView.currentImage
            } else if let listItemCell = collectionView.cellForItem(at: indexPath) as? NFTListItemCell {
                currentImage = listItemCell.contextView.currentImage
            }

            openCollectibleDetail(
                account: item.account,
                asset: item.asset,
                thumbnailImage: currentImage
            )
        default:
            break
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard let asset = getCollectibleAsset(at: indexPath) else {
            return nil
        }

        return UIContextMenuConfiguration(
            identifier: indexPath as NSIndexPath
        ) { _ in
            let copyActionItem = UIAction(item: .copyAssetID) {
                [unowned self] _ in
                self.copyToClipboardController.copyID(asset)
            }
            return UIMenu(children: [ copyActionItem ])
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        return makeTargetedPreview(
            collectionView,
            configuration: configuration
        )
    }

    func collectionView(
        _ collectionView: UICollectionView,
        previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        return makeTargetedPreview(
            collectionView,
            configuration: configuration
        )
    }

    private func makeTargetedPreview(
        _ collectionView: UICollectionView,
        configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        guard
            let indexPath = configuration.identifier as? IndexPath,
            let itemIdentifier = listDataSource.itemIdentifier(for: indexPath)
        else {
            return nil
        }

        switch itemIdentifier {
        case .collectibleAsset(let item):
            switch item {
            case .grid:
                let cell = collectionView.cellForItem(at: indexPath) as! CollectibleListItemCell
                return cell.getTargetedPreview()
            case .list:
                let cell = collectionView.cellForItem(at: indexPath) as! NFTListItemCell
                return cell.getTargetedPreview()
            }
        default:
            return nil
        }
    }
}

/// <mark>
/// UIScrollViewDelegate
extension CollectibleListViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let positionY = positionYForDisplayingListHeader else { return }

        let currentContentOffset = listView.contentOffset
        let isDisplayingListHeader = currentContentOffset.y < positionY
        let event: Event = isDisplayingListHeader ? .willDisplayListHeader : .didEndDisplayingListHeader
        eventHandler?(event)
    }
}

extension CollectibleListViewController {
    private func linkInteractors(
        _ cell: NoContentWithActionIllustratedCell
    ) {
        cell.startObserving(event: .performPrimaryAction) {
            [weak self] in
            guard let self = self else {
                return
            }
            
            let isWatchAccount =
            self.dataController.galleryAccount.singleAccount?.value.isWatchAccount() ?? false
            
            if isWatchAccount {
                self.clearFiltersAndReload()
                return
            }
            
            self.openReceiveCollectibleAccountList()
        }
        
        cell.startObserving(event: .performSecondaryAction) {
            [weak self] in
            guard let self = self else {
                return
            }
            self.clearFiltersAndReload()
        }
    }
    
    private func clearFiltersAndReload() {
        var store = CollectibleFilterStore()
        store.displayWatchAccountCollectibleAssetsInCollectibleList = true
        store.displayOptedInCollectibleAssetsInCollectibleList = true

        reload()
    }

    private func linkInteractors(
        _ cell: ManagementItemWithSecondaryActionCell
    ) {
        cell.startObserving(event: .primaryAction) {
            [weak self] in
            guard let self = self else {
                return
            }

            self.endEditing()
            
            self.openCollectiblesManagementScreen()
        }

        cell.startObserving(event: .secondaryAction) {
            [weak self] in
            guard let self = self else {
                return
            }

            self.endEditing()

            self.openReceiveCollectibleAccountList()
        }
    }

    private func linkInteractors(
        _ cell: ManagementItemCell
    ) {
        cell.startObserving(event: .primaryAction) {
            [weak self] in
            guard let self = self else {
                return
            }

            self.endEditing()

            self.openCollectiblesManagementScreen()
        }
    }

    private func linkInteractors(
        _ cell: CollectibleGalleryUIActionsCell
    ) {
        cell.delegate = self

        if collectibleGalleryUIStyleStore.galleryUIStyle == CollectibleGalleryUIActionsView.gridUIStyleIndex {
            cell.setGridUIStyleSelected()
        } else {
            cell.setListUIStyleSelected()
        }
    }
}

extension CollectibleListViewController {
    private func openCollectibleDetail(
        account: Account,
        asset: CollectibleAsset,
        thumbnailImage: UIImage?
    ) {
        let screen = Screen.collectibleDetail(
            asset: asset,
            account: account,
            thumbnailImage: thumbnailImage
        ) { [weak self] event in
            guard let self = self else { return }

            switch event {
            case .didOptOutAssetFromAccount: self.popScreen()
            case .didOptOutFromAssetWithQuickAction: break
            case .didOptInToAsset: break
            }
        }

        open(
            screen,
            by: .push
        )
    }

    private func openReceiveCollectibleAccountList() {
        eventHandler?(.didTapReceive)
    }

    private func openCollectiblesManagementScreen() {
        modalTransition.perform(
            .managementOptions(
                managementType: .collectibles,
                delegate: self
            ),
            by: .present
        )
    }
}

extension CollectibleListViewController: CollectibleGalleryUIActionsCellDelegate {
    func collectibleGalleryUIActionsViewDidSelectGridUIStyle(_ cell: CollectibleGalleryUIActionsCell) {
        collectibleGalleryUIStyleStore.galleryUIStyle = CollectibleGalleryUIActionsView.gridUIStyleIndex
        listView.setCollectionViewLayout(CollectibleListLayout.gridFlowLayout, animated: true)
        dataController.reload()
    }

    func collectibleGalleryUIActionsViewDidSelectListUIStyle(_ cell: CollectibleGalleryUIActionsCell) {
        collectibleGalleryUIStyleStore.galleryUIStyle = CollectibleGalleryUIActionsView.listUIStyleIndex
        listView.setCollectionViewLayout(CollectibleListLayout.listFlowLayout, animated: true)
        dataController.reload()
    }

    func collectibleGalleryUIActionsViewDidEditSearchInput(_ cell: CollectibleGalleryUIActionsCell, input: String?) {
        guard let query = input else {
            return
        }

        if query.isEmpty {
            dataController.resetSearch()
            return
        }

        dataController.search(for: query)
    }

    func collectibleGalleryUIActionsViewDidReturnSearchInput(_ cell: CollectibleGalleryUIActionsCell) {
        cell.endEditing()
    }
}

extension CollectibleListViewController: ManagementOptionsViewControllerDelegate {
    func managementOptionsViewControllerDidTapSort(
        _ managementOptionsViewController: ManagementOptionsViewController
    ) {
        let eventHandler: SortCollectibleListViewController.EventHandler = {
            [weak self] event in
            guard let self = self else { return }
            
            self.dismiss(animated: true) {
                [weak self] in
                guard let self = self else { return }

                switch event {
                case .didComplete: self.reload()
                }
            }
        }

        open(
            .sortCollectibleList(
                dataController: SortCollectibleListLocalDataController(
                    session: session!,
                    sharedDataController: sharedDataController
                ),
                eventHandler: eventHandler
            ),
            by: .present
        )
    }

    func managementOptionsViewControllerDidTapFilterCollectibles(
        _ managementOptionsViewController: ManagementOptionsViewController
    ) {
        eventHandler?(.didTapFilter)
    }

    func managementOptionsViewControllerDidTapRemove(
        _ managementOptionsViewController: ManagementOptionsViewController
    ) {}
    
    func managementOptionsViewControllerDidTapFilterAssets(
        _ managementOptionsViewController: ManagementOptionsViewController
    ) {}
}

extension CollectibleListViewController {
    private func getCollectibleAsset(
        at indexPath: IndexPath
    ) -> CollectibleAsset? {
        guard let itemIdentifier = listDataSource.itemIdentifier(for: indexPath) else {
            return nil
        }

        if case CollectibleListItem.collectibleAsset(let item) = itemIdentifier {
            return item.asset
        }

        return nil
    }
}

extension CollectibleListViewController {
    func reload() {
        dataController.reload()
    }
}

extension CollectibleListViewController {
    enum Event {
        case didUpdateSnapshot
        case didTapReceive
        case willDisplayListHeader
        case didEndDisplayingListHeader
        case didFinishRunning(hasError: Bool)
        case didTapFilter
    }
}
