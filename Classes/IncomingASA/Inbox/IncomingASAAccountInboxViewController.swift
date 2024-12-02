// Copyright 2024 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   IncomingASAAccountInboxViewController.swift

import Foundation
import MacaroonForm
import MacaroonUIKit
import MacaroonUtils
import UIKit
import WalletConnectSwift

final class IncomingASAAccountInboxViewController:
    BaseViewController,
    NotificationObserver {
    var notificationObservations: [NSObjectProtocol] = []

    typealias EventHandler = (Event) -> Void

    var eventHandler: EventHandler?

    private lazy var theme = Theme()

    private lazy var listLayout = IncomingASAAccountInboxListLayout(listDataSource: listDataSource)
    private lazy var listDataSource = IncomingASAAccountInboxListDataSource(listView)
    
    private lazy var transitionToMinimumBalanceInfo = BottomSheetTransition(presentingViewController: self)
    private lazy var transitionToApprovalScreen = BottomSheetTransition(presentingViewController: self, interactable: false)

    private lazy var listView: UICollectionView = {
        let collectionViewLayout = AccountAssetListLayout.build()
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: collectionViewLayout
        )
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = theme.backgroundColor.uiColor
        collectionView.keyboardDismissMode = .interactive
        return collectionView
    }()

    private let dataController: IncomingASAAccountInboxDataController
    private let copyToClipboardController: CopyToClipboardController

    init(
        dataController: IncomingASAAccountInboxDataController,
        copyToClipboardController: CopyToClipboardController,
        configuration: ViewControllerConfiguration
    ) {
        self.dataController = dataController
        self.copyToClipboardController = copyToClipboardController

        super.init(configuration: configuration)
    }

    deinit {
        stopObservingNotifications()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "incoming-asa-account-inbox-screen-title"
            .localized
        dataController.eventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .didUpdate(let updates):
                self.listDataSource.apply(
                    updates.snapshot,
                    animatingDifferences: true
                )
            case .didReceiveError(let error):
                self.bannerController?.presentErrorBanner(
                    title: "title-error".localized,
                    message: error
                )
            }
        }
        dataController.load()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        startAnimatingLoadingIfNeededWhenViewDidAppear()
    }

    override func viewDidAppearAfterInteractiveDismiss() {
        super.viewDidAppearAfterInteractiveDismiss()

        startAnimatingLoadingIfNeededWhenViewDidAppear()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopAnimatingLoadingIfNeededWhenViewDidDisappear()
    }

    override func prepareLayout() {
        super.prepareLayout()
        
        addUI()
        view.layoutIfNeeded()
    }

    override func linkInteractors() {
        super.linkInteractors()

        listView.delegate = self
    }

    override func configureNavigationBarAppearance() {
        addBarButtons()
        bindNavigationItemTitle()
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
    }    
}

extension IncomingASAAccountInboxViewController {
    private func addBarButtons() {
        let infoBarButton = ALGBarButtonItem(kind: .info) {
            [unowned self] in
            let uiSheet = UISheet(
                title: "incoming-asa-account-inbox-screen-info-title"
                    .localized
                    .bodyLargeMedium(),
                body: UISheetBodyTextProvider(text: "incoming-asa-account-inbox-screen-info-description-title"
                    .localized
                    .bodyRegular())
            )

            let closeAction = UISheetAction(
                title: "title-close".localized,
                style: .cancel
            ) { [unowned self] in
                self.dismiss(animated: true)
            }
            uiSheet.addAction(closeAction)

            transitionToMinimumBalanceInfo.perform(
                .sheetAction(sheet: uiSheet),
                by: .presentWithoutNavigationController
            )
        }

        rightBarButtonItems = [infoBarButton]
    }
    
    private func bindNavigationItemTitle() {
        title = "incoming-asa-account-inbox-screen-title".localized
    }
}


extension IncomingASAAccountInboxViewController {
    
    private func addUI() {
        addList()
    }

    private func addList() {
        listView.customizeAppearance(
            [
                .backgroundColor(UIColor.clear)
            ]
        )

        view.addSubview(listView)
        listView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }

        listView.showsVerticalScrollIndicator = false
        listView.showsHorizontalScrollIndicator = false
        listView.alwaysBounceVertical = true
        listView.delegate = self
    }
}

extension IncomingASAAccountInboxViewController {
    private func startAnimatingLoadingIfNeededWhenViewDidAppear() {
        if isViewFirstAppeared { return }

        for cell in listView.visibleCells {
            if let pendingAssetCell = cell as? PendingAssetListItemCell {
                pendingAssetCell.startLoading()
                return
            }

            if let pendingCollectibleAssetCell = cell as? PendingCollectibleAssetListItemCell {
                pendingCollectibleAssetCell.startLoading()
                return
            }

            if let assetLoadingCell = cell as? AccountAssetListLoadingCell {
                assetLoadingCell.startAnimating()
                return
            }
        }
    }

    private func stopAnimatingLoadingIfNeededWhenViewDidDisappear() {
        for cell in listView.visibleCells {
            if let pendingAssetCell = cell as? PendingAssetListItemCell {
                pendingAssetCell.stopLoading()
                return
            }

            if let pendingCollectibleAssetCell = cell as? PendingCollectibleAssetListItemCell {
                pendingCollectibleAssetCell.stopLoading()
                return
            }

            if let assetLoadingCell = cell as? AccountAssetListLoadingCell {
                assetLoadingCell.stopAnimating()
                return
            }
        }
    }
}

extension IncomingASAAccountInboxViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        let sectionIdentifiers = listDataSource.snapshot().sectionIdentifiers
        guard let listSection = sectionIdentifiers[safe: indexPath.section] else {
            return
        }
        
        switch listSection {
        case .assets:
            guard let itemIdentifier = listDataSource.itemIdentifier(for: indexPath) else {
                return
            }
            switch itemIdentifier {
            case .assetLoading:
                startAnimatingListLoadingIfNeeded(cell)
            default: break
            }
        default: break
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplaying cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        let sectionIdentifiers = listDataSource.snapshot().sectionIdentifiers

        guard let listSection = sectionIdentifiers[safe: indexPath.section] else {
            return
        }
        switch listSection {
        case .assets:
            guard let itemIdentifier = listDataSource.itemIdentifier(for: indexPath) else {
                return
            }
            switch itemIdentifier {
            case .assetLoading:
                stopAnimatingListLoadingIfNeeded(cell)
            default: break
            }
        default: break
        }
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
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return listLayout.collectionView(
            collectionView,
            layout: collectionViewLayout,
            insetForSectionAt: section
        )
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let sectionIdentifiers = listDataSource.snapshot().sectionIdentifiers

        guard let listSection = sectionIdentifiers[safe: indexPath.section] else {
            return
        }

        switch listSection {
        case .assets:
            guard let itemIdentifier = listDataSource.itemIdentifier(for: indexPath) else {
                return
            }

            switch itemIdentifier {
            case .asset(let item):
                let screen = open(
                    .incomingASAsDetail( draft: item),
                    by: .present
                ) as? IncomingASAsDetailScreen
                screen?.isModalInPresentation = true
                screen?.eventHandler = {
                    [weak self, weak screen] event in
                    guard let self,
                          let screen else {
                        return
                    }
                    
                    switch event {
                    case .didCompleteTransaction:
                        screen.dismissScreen()                        
                        asyncMain(
                            afterDuration: 0.2
                        ) {
                            [weak self] in
                            guard let self else { return }
                            self.eventHandler?(.didCompleteTransaction)
                        }
                    }
                }
            default:
                break
            }
        default:
            break
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard let asset = getAsset(at: indexPath) else {
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
        guard
            let indexPath = configuration.identifier as? IndexPath,
            let cell = collectionView.cellForItem(at: indexPath)
        else {
            return nil
        }

        return UITargetedPreview(
            view: cell,
            backgroundColor: Colors.Defaults.background.uiColor
        )
    }

    func collectionView(
        _ collectionView: UICollectionView,
        previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        guard
            let indexPath = configuration.identifier as? IndexPath,
            let cell = collectionView.cellForItem(at: indexPath)
        else {
            return nil
        }

        return UITargetedPreview(
            view: cell,
            backgroundColor: Colors.Defaults.background.uiColor
        )
    }
}

extension IncomingASAAccountInboxViewController {
    private func startAnimatingListLoadingIfNeeded(_ cell: PendingAssetListItemCell?) {
        cell?.startLoading()
    }

    private func stopAnimatingListLoadingIfNeeded(_ cell: PendingAssetListItemCell?) {
        cell?.stopLoading()
    }
}

extension IncomingASAAccountInboxViewController {
    private func startAnimatingListLoadingIfNeeded(_ cell: UICollectionViewCell) {
        let loadingCell = cell as? AccountAssetListLoadingCell
        loadingCell?.startAnimating()
    }

    private func stopAnimatingListLoadingIfNeeded(_ cell: UICollectionViewCell) {
        let loadingCell = cell as? AccountAssetListLoadingCell
        loadingCell?.stopAnimating()
    }
}

extension IncomingASAAccountInboxViewController {
    private func startAnimatingListLoadingIfNeeded(_ cell: PendingCollectibleAssetListItemCell?) {
        cell?.startLoading()
    }

    private func stopAnimatingListLoadingIfNeeded(_ cell: PendingCollectibleAssetListItemCell?) {
        cell?.stopLoading()
    }
}

extension IncomingASAAccountInboxViewController {
    private func getAsset(
        at indexPath: IndexPath
    ) -> Asset? {
        guard let itemIdentifier = listDataSource.itemIdentifier(for: indexPath) else {
            return nil
        }

        if case IncomingASAItem.asset(let item) = itemIdentifier {
            return item.asset
        }

        return nil
    }
}

extension IncomingASAAccountInboxViewController {
    enum Event {
        case didCompleteTransaction
    }
}
