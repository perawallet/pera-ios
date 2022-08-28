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

//   ExportAccountListScreen.swift

import UIKit
import MacaroonUIKit

final class ExportAccountListScreen:
    BaseViewController,
    UICollectionViewDelegateFlowLayout {
    typealias EventHandler = (Event) -> Void

    var eventHandler: EventHandler?

    private lazy var theme = ExportAccountListScreenTheme()

    private lazy var listView: UICollectionView = {
        let collectionViewLayout = ExportAccountListLayout.build()
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: collectionViewLayout
        )
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .clear
        return collectionView
    }()

    private lazy var continueActionViewGradient = GradientView()
    private lazy var continueActionView = MacaroonUIKit.Button()

    private lazy var listLayout = ExportAccountListLayout(listDataSource: listDataSource)
    private lazy var listDataSource = ExportAccountListDataSource(listView)

    private var isLayoutFinalized = false

    private let dataController: ExportAccountListDataController

    init(
        dataController: ExportAccountListDataController,
        configuration: ViewControllerConfiguration
    ) {
        self.dataController = dataController

        super.init(configuration: configuration)
    }

    override func configureNavigationBarAppearance() {
        /// <todo> Macaroon
        title = "web-export-account-list-title".localized
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        dataController.eventHandler = {
            [weak self] event in
            guard let self = self else {
                return
            }

            switch event {
            case .didUpdate(let snapshot):
                self.listDataSource.apply(
                    snapshot,
                    animatingDifferences: false
                )

                self.toggleContinueActionStateIfNeeded()
            }
        }

        dataController.load()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if isLayoutFinalized ||
           continueActionView.bounds.isEmpty {
            return
        }

        updateUIWhenViewDidLayout()

        isLayoutFinalized = true
    }

    override func setListeners() {
        super.setListeners()

        listView.delegate = self
    }

    override func prepareLayout() {
        super.prepareLayout()

        addUI()
    }

    private func addUI() {
        addList()
        addContinueActionViewGradient()
        addContinueActionView()
    }
}

extension ExportAccountListScreen {
    private func addList() {
        view.addSubview(listView)
        listView.snp.makeConstraints {
            $0.setPaddings()
        }
    }
}

extension ExportAccountListScreen {
    private func updateUIWhenViewDidLayout() {
        updateAdditionalSafeAreaInetsWhenViewDidLayout()
    }

     private func updateAdditionalSafeAreaInetsWhenViewDidLayout() {
         let inset =
            theme.spacingBetweenListAndContinueAction +
            continueActionView.frame.height +
            theme.continueAllActionMargins.bottom

         additionalSafeAreaInsets.bottom = inset
     }

     private func toggleContinueActionStateIfNeeded() {
         continueActionView.isEnabled = dataController.isContinueActionEnabled
     }

     private func addContinueActionViewGradient() {
         let color0 = Colors.Defaults.background.uiColor.withAlphaComponent(0)
         let color1 = Colors.Defaults.background.uiColor
         continueActionViewGradient.colors = [color0, color1]

         view.addSubview(continueActionViewGradient)
         continueActionViewGradient.snp.makeConstraints {
             $0.leading == 0
             $0.bottom == 0
             $0.trailing == 0
         }
     }

     private func addContinueActionView() {
         continueActionView.customizeAppearance(theme.continueAllAction)

         continueActionViewGradient.addSubview(continueActionView)
         continueActionView.contentEdgeInsets = UIEdgeInsets(theme.continueAllActionEdgeInsets)
         continueActionView.snp.makeConstraints {
             let safeAreaBottom = view.compactSafeAreaInsets.bottom
             let bottom = safeAreaBottom + theme.continueAllActionMargins.bottom

             $0.top == theme.spacingBetweenListAndContinueAction
             $0.leading == theme.continueAllActionMargins.leading
             $0.bottom == bottom
             $0.trailing == theme.continueAllActionMargins.trailing
         }

         continueActionView.addTouch(
             target: self,
             action: #selector(performContinue)
         )

         toggleContinueActionStateIfNeeded()
     }

     @objc
     private func performContinue() {
         let selectedAccounts = dataController.getSelectedAccounts()
         eventHandler?(.didContinue(with: selectedAccounts))
     }
 }

extension ExportAccountListScreen {
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
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        return listLayout.collectionView(
            collectionView,
            layout: collectionViewLayout,
            referenceSizeForHeaderInSection: section
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

extension ExportAccountListScreen {
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard let itemIdentifier = listDataSource.itemIdentifier(for: indexPath) else {
            return
        }

        switch itemIdentifier {
        case .account(let item):
            switch item {
            case .header:
                linkInteractors(cell as! ExportAccountListAccountsHeader)
            case .cell:
                linkInteractors(
                    cell as! ExportAccountListAccountCell,
                    atIndexPath: indexPath
                )
            }
        }
    }
}

extension ExportAccountListScreen {
    private func linkInteractors(
        _ cell: ExportAccountListAccountsHeader
    ) {
        cell.startObserving(event: .performAction) {
            [unowned self] in

            let snapshot = listDataSource.snapshot()
            let headerState = dataController.getAccountHeaderItemState()

            switch headerState {
            case .selectAll,
                 .partialSelection:
                dataController.selectAllAccountsItems(snapshot)
            case .unselectAll:
                dataController.unselectAllAccountsItems(snapshot)
            }
        }
    }

    private func linkInteractors(
        _ cell: ExportAccountListAccountCell,
        atIndexPath indexPath: IndexPath
    ) {
        cell.isChecked = dataController.isAccountSelected(atIndex: indexPath.row.advanced(by: -1))

        cell.startObserving(event: .check) {
            [unowned self] in

            dataController.unselectAccountItem(
                listDataSource.snapshot(),
                atIndex: indexPath.row.advanced(by: -1)
            )
        }

        cell.startObserving(event: .uncheck) {
            [unowned self] in

            dataController.selectAccountItem(
                listDataSource.snapshot(),
                atIndex: indexPath.row.advanced(by: -1)
            )
        }
    }
}

extension ExportAccountListScreen {
    enum Event {
        case didContinue(with: [AccountHandle])
    }
}
