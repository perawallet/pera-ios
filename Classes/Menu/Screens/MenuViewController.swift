// Copyright 2025 Pera Wallet, LDA

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

final class MenuViewController: BaseViewController {
    
    private lazy var theme = Theme()
    private lazy var menuListView = MenuListView()
    
    private lazy var dataSource = MenuDataSource(
        sharedDataController: sharedDataController,
        session: session
    )
    
    private lazy var receiveTransactionFlowCoordinator = ReceiveTransactionFlowCoordinator(presentingScreen: self)
    private lazy var transitionToBuySellOptions = BottomSheetTransition(presentingViewController: self)
    private lazy var meldFlowCoordinator = MeldFlowCoordinator(
        analytics: analytics,
        presentingScreen: self
    )
    private lazy var bidaliFlowCoordinator = BidaliFlowCoordinator(presentingScreen: self, api: api!)
    
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
        menuListView.collectionView.dataSource = dataSource
    }
    
    override func configureAppearance() {
        title = String(localized: "title-menu")
    }
    
    override func prepareLayout() {
        addMenuListView()
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
        let notificationBarButtonItem = ALGBarButtonItem(kind: .settings) { [weak self] in
            guard let self = self else {
                return
            }

            self.open(
                .settings,
                by: .push
            )
        }

        rightBarButtonItems = [notificationBarButtonItem]
    }
}

extension MenuViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        if let option = dataSource.menuOptions[safe: indexPath.row] {
            let width = collectionView.frame.width - theme.listItemTheme.collectionViewEdgeInsets.leading - theme.listItemTheme.collectionViewEdgeInsets.trailing
            switch option {
            case .cards:
                return CGSize(width: width, height: theme.cardsCellHeight)
            case .nfts, .transfer, .buyAlgo, .receive, .inviteFriends:
                return CGSize(width: width, height: theme.cellHeight)
            }
        }
        return .zero
    }
}

extension MenuViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let option = dataSource.menuOptions[safe: indexPath.row] {
            switch option {
            case .cards:
                print("cards pressed")
            case .nfts:
                open(.collectibleList, by: .push)
            case .transfer:
                print("transfer pressed")
            case .buyAlgo:
                openBuySellOptions()
            case .receive:
                receiveTransactionFlowCoordinator.launch()
            case .inviteFriends:
                print("inviteFriends pressed")
            }
            return
        }
        
        fatalError("Index path is out of bounds")
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

        transitionToBuySellOptions.perform(
            .buySellOptions(eventHandler: eventHandler),
            by: .presentWithoutNavigationController
        )
    }

    private func openBuyWithMeld() {
        analytics.track(.recordHomeScreen(type: .buyAlgo))

        meldFlowCoordinator.launch()
    }
}

extension MenuViewController {
    private func openBuyGiftCardsWithBidali() {
        bidaliFlowCoordinator.launch()
    }
}
