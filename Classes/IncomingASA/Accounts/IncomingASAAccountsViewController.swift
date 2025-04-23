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

//   IncomingASAAccountsViewController.swift

import Foundation
import UIKit
import MacaroonUIKit
import MacaroonUtils

final class IncomingASAAccountsViewController: BaseViewController {
    typealias EventHandler = (Event) -> Void
    var eventHandler: EventHandler?

    private lazy var theme = Theme()
    
    private lazy var listLayout = IncomingASAAccountsListLayout(listDataSource: listDataSource)
    private lazy var listDataSource = IncomingASAAccountsDataSource(listView)
    private lazy var transitionToMinimumBalanceInfo = BottomSheetTransition(presentingViewController: self)

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
    
    private var positionYForVisibleAccountActionsMenuAction: CGFloat?
    private let dataController: IncomingASAAccountsDataController

    init(
        dataController: IncomingASAAccountsDataController,
        configuration: ViewControllerConfiguration
    ) {
        self.dataController = dataController
        super.init(configuration: configuration)
    }

    override func configureNavigationBarAppearance() {
        addBarButtons()
        bindNavigationItemTitle()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dataController.load()

        dataController.eventHandler = {
            [weak self] event in
            guard let self else { return }
            
            switch event {
            case .didUpdate(let update):
                switch update.operation {
                    
                case .refresh:
                    break
                }
                self.listDataSource.apply(update.snapshot, animatingDifferences: true)
            }
        }
    }

    override func prepareLayout() {
        super.prepareLayout()
        
        addUI()
        view.layoutIfNeeded()
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
    }
}

extension IncomingASAAccountsViewController {
    private func addBarButtons() {
        let infoBarButton = ALGBarButtonItem(kind: .info) {
            [unowned self] in
            let uiSheet = UISheet(
                title: String(localized: "incoming-asa-account-inbox-screen-title")
                    .bodyLargeMedium(),
                body: UISheetBodyTextProvider(text: String(localized: "incoming-asa-account-inbox-screen-info-description-title")
                    .bodyRegular())
            )

            let closeAction = UISheetAction(
                title: String(localized: "title-close"),
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
        title = String(localized: "incoming-asa-account-inbox-screen-title")
    }
}

extension IncomingASAAccountsViewController {
    
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
            $0.edges.equalToSuperview()
        }

        listView.showsVerticalScrollIndicator = false
        listView.showsHorizontalScrollIndicator = false
        listView.alwaysBounceVertical = true
        listView.delegate = self
    }
}

extension IncomingASAAccountsViewController: UICollectionViewDelegateFlowLayout {
    
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
}

extension IncomingASAAccountsViewController {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let vm = getIncomingASAAccountCellViewModel(at: indexPath),
                let address = vm.address,
                let requestCount = vm.requestCount else {
            return
        }
        
        let screen = open(
            .incomingASA(
                address: address,
                requestsCount: requestCount
            ),
            by: .push
        ) as? IncomingASAAccountInboxViewController
        
        screen?.eventHandler = {
            [weak self, weak screen] event in
            guard let self,
                  let screen else {
                return
            }
            
            switch event {
            case .didCompleteTransaction:
                screen.closeScreen(by: .pop, animated: false)
                self.eventHandler?(.didCompleteTransaction)
            }
        }
    }
    
    private func getIncomingASAAccountCellViewModel(
        at indexPath: IndexPath
    ) -> IncomingASAAccountCellViewModel? {
        
        guard let itemIdentifier = listDataSource.itemIdentifier(for: indexPath) else {
            return nil
        }
        if case let .account(item) = itemIdentifier {
            return item
        }
        return nil
    }
}

extension IncomingASAAccountsViewController {
    enum Event {
        case didCompleteTransaction
    }
}
