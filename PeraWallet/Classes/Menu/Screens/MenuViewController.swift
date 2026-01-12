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

//   MenuViewController.swift

import UIKit
import pera_wallet_core

final class MenuViewController: BaseViewController {
    
    private lazy var theme = Theme()
    private lazy var menuListView = MenuListView()
    
    private lazy var scanQRFlowCoordinator = ScanQRFlowCoordinator(
        analytics: analytics,
        api: api!,
        bannerController: bannerController!,
        loadingController: loadingController!,
        presentingScreen: self,
        session: session!,
        sharedDataController: sharedDataController,
        appLaunchController: configuration.launchController,
        hdWalletStorage: hdWalletStorage
    )
    
    private lazy var cardsSupportedCountriesFlowCoordinator = CardsSupportedCountriesFlowCoordinator(api: api!, session: session!)
    private lazy var cardsFlowCoordinator = CardsFlowCoordinator(presentingScreen: self)
    
    private lazy var collectibleDataController = CollectibleListLocalDataController(galleryAccount: .all, sharedDataController: sharedDataController)
    
    private lazy var receiveTransactionFlowCoordinator = ReceiveTransactionFlowCoordinator(presentingScreen: self)
    private lazy var transitionToBottomSheet = BottomSheetTransition(presentingViewController: self)
    private lazy var meldFlowCoordinator = MeldFlowCoordinator(
        analytics: analytics,
        presentingScreen: self
    )
    private lazy var bidaliFlowCoordinator = BidaliFlowCoordinator(presentingScreen: self, api: api!)
    
    private(set) var menuOptions: [MenuOption] = []
    
    override var prefersLargeTitle: Bool {
        return false
    }
    
    override init(configuration: ViewControllerConfiguration) {
        super.init(configuration: configuration)
    }
    
    override func configureNavigationBarAppearance() {
        configureNotificationBarButton()
    }
    
    override func customizeTabBarAppearence() {
        tabBarHidden = false
    }
    
    override func linkInteractors() {
        menuListView.collectionView.delegate = self
        menuListView.collectionView.dataSource = self
    }
    
    override func configureAppearance() {
        title = String(localized: "title-menu")
        navigationItem.largeTitleDisplayMode = .never
    }
    
    override func prepareLayout() {
        addMenuListView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        selectMenuOptions()
        configure()
    }
    
    private func selectMenuOptions(
        cardsOption: MenuOption = .cards(state: .inactive),
        nftsOption: MenuOption = .nfts(withThumbnails: [])
    ) {
        
        let showCards = cardsOption == .cards(state: .active)
        let isXoSwapEnabled = configuration.featureFlagService.isEnabled(.xoSwapEnabled)
        
        var baseOptions: [MenuOption] = []
        
        baseOptions.append(nftsOption)
        
        baseOptions.append(contentsOf: isXoSwapEnabled ? [.buy, .receive, .stake, .inviteFriends] : [.buyAlgo, .receive, .inviteFriends])
        
        if showCards {
            baseOptions.append(cardsOption)
        }
        
        menuOptions = baseOptions
    }

}

extension MenuViewController {
    private func configure() {
        cardsSupportedCountriesFlowCoordinator.eventHandler = {
            [weak self] event in
            guard let self else { return }
            
            switch event {
            case .success(hasActiveCard: let hasActiveCard, isWaitlisted: let isWaitlisted):
                if isWaitlisted {
                    self.getNFTsThumbnails(cardsOption: .cards(state: .addedToWailist))
                } else {
                    self.getNFTsThumbnails(cardsOption: .cards(state: hasActiveCard ? .active : .inactive))
                }
            case .error:
                self.getNFTsThumbnails(cardsOption: .cards(state: .inactive))
            }
        }
        
        cardsSupportedCountriesFlowCoordinator.launch()
    }
    
    private func getNFTsThumbnails(cardsOption: MenuOption) {
        let query = CollectibleListQuery(
            filteringBy: .init(),
            sortingBy: CollectibleDescendingOptedInRoundAlgorithm()
        )
        
        collectibleDataController.eventHandler = { [weak self] event in
            guard let self else { return }
            switch event {
            case .didUpdate(let updates):
                selectMenuOptions(nftsOption: .nfts(withThumbnails: self.parseCollectionData(from: updates.snapshot.itemIdentifiers)))
            case .didFinishRunning(hasError: let hasError):
                if hasError {
                    selectMenuOptions(cardsOption: cardsOption)
                }
            }
            self.menuListView.collectionView.reloadData()
        }
        collectibleDataController.load(query: query)
    }
    
    
    private func parseCollectionData(from itemIdentifiers: [CollectibleListItem]) -> [URL] {
        let imageAssets: [CollectibleAsset] = itemIdentifiers.compactMap { item in
            if case let .collectibleAsset(viewModel) = item,
               viewModel.asset.mediaType == .image,
               !viewModel.asset.media.contains(where: { $0.isGIF })
            {
                return viewModel.asset
            }
            return nil
        }
        
        let thumbnails: [URL] = imageAssets.compactMap { asset in
            asset.media.first { $0.previewURL != nil }?.previewURL ??
            asset.media.first { $0.downloadURL != nil }?.downloadURL ?? asset.thumbnailImage
        }.prefix(3).map { $0 }
        
        return thumbnails
    }
}

extension MenuViewController {
    private func addMenuListView() {
        view.addSubview(menuListView)

        menuListView.snp.makeConstraints {
            $0.setPaddings()
        }
    }
}

extension MenuViewController {
    private func configureNotificationBarButton() {
        let qrScannerBarButtonItem = ALGBarButtonItem(kind: .qr) { [weak self] in
            guard let self else { return }
            
            self.scanQRFlowCoordinator.launch()
            analytics.track(.recordMenuScreen(type: .tapQRScan))
        }
        
        let settingsBarButtonItem = ALGBarButtonItem(kind: .settings) { [weak self] in
            guard let self = self else {
                return
            }

            self.open(
                .settings,
                by: .push
            )
            analytics.track(.recordMenuScreen(type: .tapSettings))
        }

        rightBarButtonItems = [settingsBarButtonItem, qrScannerBarButtonItem]
    }
}

extension MenuViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        if let option = menuOptions[safe: indexPath.row] {
            let width = collectionView.frame.width - theme.listItemTheme.collectionViewEdgeInsets.leading - theme.listItemTheme.collectionViewEdgeInsets.trailing
            switch option {
            case .cards:
                return CGSize(width: width, height: theme.cardsCellHeight)
            case .nfts, .transfer, .buyAlgo, .buy, .receive, .stake, .inviteFriends:
                return CGSize(width: width, height: theme.cellHeight)
            }
        }
        return .zero
    }
}

extension MenuViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let option = menuOptions[safe: indexPath.row] {
            switch option {
            case .cards:
                print("cards pressed")
            case .nfts:
                open(.collectibleList, by: .push)
                analytics.track(.recordMenuScreen(type: .tapNfts))
            case .transfer:
                fatalError("not implemented, shouldn't enter here")
            case .buyAlgo:
                openBuySellOptions()
                analytics.track(.recordMenuScreen(type: .tapBuyAlgo))
            case .buy:
                openBuyGiftCardsWithBidali()
                analytics.track(.recordMenuScreen(type: .tapBuyAlgo))
            case .receive:
                receiveTransactionFlowCoordinator.launch()
                analytics.track(.recordMenuScreen(type: .tapReceive))
            case .stake:
                open(.staking, by: .push)
                analytics.track(.recordMenuScreen(type: .tapStake))
            case .inviteFriends:
                openInviteFriends()
                analytics.track(.recordMenuScreen(type: .tapInviteFriends))
            }
            return
        }
        
        fatalError("Index path is out of bounds")
    }
}

extension MenuViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menuOptions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let option = menuOptions[safe: indexPath.row] {
            switch option {
            case .cards:
                let cell = collectionView.dequeue(MenuListCardViewCell.self, at: indexPath)
                cell.delegate = self
                cell.bindData(option)
                return cell

            case .nfts, .transfer, .buyAlgo, .buy, .receive, .stake, .inviteFriends:
                let cell = collectionView.dequeue(MenuListViewCell.self, at: indexPath)
                cell.bindData(option)
                return cell
            }
        }

        fatalError("Index path is out of bounds")
    }
}

extension MenuViewController: MenuListCardViewCellDelegate {
    func didPressActionButton(in cell: MenuListCardViewCell, with option: MenuOption) {
        cardsFlowCoordinator.launch()
        switch option {
        case .cards(state: let cardState):
            switch cardState {
            case .inactive:
                analytics.track(.recordMenuScreen(type: .tapCreateCard))
            case .active:
                analytics.track(.recordMenuScreen(type: .tapGoToCards))
            default:
                break
            }
        default:
            assertionFailure("Shouldn't enter here")
        }
    }
}

extension MenuViewController {
    private func openBuySellOptions() {
        let eventHandler: BuySellOptionsScreen.EventHandler = {
            [unowned self] event in
            switch event {
            case .performBuyWithMeld:
                self.dismiss(animated: true) {
                    [weak self] in
                    guard let self else { return }
                    self.openBuyWithMeld()
                }
            case .performBuyGiftCardsWithBidali:
                self.dismiss(animated: true) {
                    [weak self] in
                    guard let self else { return }
                    self.openBuyGiftCardsWithBidali()
                }
            }
        }

        transitionToBottomSheet.perform(
            .buySellOptions(eventHandler: eventHandler),
            by: .presentWithoutNavigationController
        )
    }

    private func openBuyWithMeld() {
        meldFlowCoordinator.launch()
    }
    
    private func openBuyGiftCardsWithBidali() {
        bidaliFlowCoordinator.launch()
    }
}

extension MenuViewController {
    private func openInviteFriends() {
        let eventHandler: InviteFriendsScreen.EventHandler = {
            [unowned self] event in
            switch event {
            case .close:
                self.dismiss(animated: true) {
                    [weak self] in
                    guard let self else { return }
                    analytics.track(.recordMenuScreen(type: .tapCloseInviteFriends))
                }
            case .share:
                self.dismiss(animated: true) {
                    [weak self] in
                    guard let self else { return }
                    openShare()
                    analytics.track(.recordMenuScreen(type: .tapShareInviteFriends))
                }
            }
        }

        transitionToBottomSheet.perform(
            .inviteFriends(eventHandler: eventHandler),
            by: .presentWithoutNavigationController
        )
    }
    
    private func openShare() {
        guard
            let urlString = Bundle.main.object(forInfoDictionaryKey: "AppDownloadURL") as? String,
            let url = URL(string: urlString)
        else {
            return
        }
        let excludedActivityTypes: [UIActivity.ActivityType] = [
            .addToReadingList,
            .assignToContact,
            .print,
            .saveToCameraRoll,
            .openInIBooks,
            .markupAsPDF
        ]
        open(
            .shareActivity(
                items: [url],
                excludedActivityTypes: excludedActivityTypes
            ),
            by: .presentWithoutNavigationController
        )
    }
}
