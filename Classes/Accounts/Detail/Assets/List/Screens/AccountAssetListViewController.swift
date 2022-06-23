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

//
//   AccountAssetListViewController.swift

import Foundation
import UIKit
import MacaroonUIKit

final class AccountAssetListViewController: BaseViewController {
    typealias EventHandler = (Event) -> Void

    var eventHandler: EventHandler?

    private lazy var theme = Theme()

    private lazy var listLayout = AccountAssetListLayout(
        isWatchAccount: accountHandle.value.isWatchAccount(),
        listDataSource: listDataSource
    )

    private lazy var listDataSource = AccountAssetListDataSource(listView)
    private lazy var dataController = AccountAssetListAPIDataController(accountHandle, sharedDataController)

    private lazy var buyAlgoResultTransition = BottomSheetTransition(presentingViewController: self)
    
    private lazy var listView: UICollectionView = {
        let collectionViewLayout = AccountAssetListLayout.build()
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: collectionViewLayout
        )
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = theme.listBackgroundColor.uiColor
        collectionView.keyboardDismissMode = .interactive
        return collectionView
    }()
    private lazy var listBackgroundView = UIView()

    private lazy var transactionActionButton = FloatingActionItemButton(hasTitleLabel: false)

    private var keyboardController = KeyboardController()

    private var accountHandle: AccountHandle

    private let copyToClipboardController: CopyToClipboardController

    init(
        accountHandle: AccountHandle,
        copyToClipboardController: CopyToClipboardController,
        configuration: ViewControllerConfiguration
    ) {
        self.accountHandle = accountHandle
        self.copyToClipboardController = copyToClipboardController

        super.init(configuration: configuration)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        dataController.eventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .didUpdate(let snapshot):
                if let accountHandle = self.sharedDataController.accountCollection[self.accountHandle.value.address] {
                    self.accountHandle = accountHandle
                    self.eventHandler?(.didUpdate(accountHandle))
                }
                self.listDataSource.apply(snapshot, animatingDifferences: self.isViewAppeared)
                self.updateUIWhenListDidReload()
            }
        }
        dataController.load()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if !listView.frame.isEmpty {
            updateUIWhenViewDidLayoutSubviews()
        }
    }

    override func prepareLayout() {
        super.prepareLayout()
        
        addUI()

        if !accountHandle.value.isWatchAccount() {
            addTransactionActionButton(theme)
        }

        view.layoutIfNeeded()
    }

    override func linkInteractors() {
        super.linkInteractors()
        listView.delegate = self
        keyboardController.dataSource = self
    }

    override func setListeners() {
        super.setListeners()
        setTransactionActionButtonAction()
        keyboardController.beginTracking()
    }

    func reload() {
        dataController.reload()
    }
}

extension AccountAssetListViewController {
    private func addUI() {
        addListBackground()
        addList()
    }

    private func updateUIWhenViewDidLayoutSubviews() {
        updateListBackgroundWhenViewDidLayoutSubviews()
    }

    private func updateUIWhenListDidReload() {
        updateListBackgroundWhenListDidReload()
    }

    private func updateUIWhenListDidScroll() {
        updateListBackgroundWhenListDidScroll()
    }

    private func addListBackground() {
        listBackgroundView.customizeAppearance(
            [
                .backgroundColor(AppColors.Shared.Helpers.heroBackground)
            ]
        )

        view.addSubview(listBackgroundView)
        listBackgroundView.snp.makeConstraints {
            $0.fitToHeight(0)
            $0.top == 0
            $0.leading == 0
            $0.trailing == 0
        }
    }

    private func updateListBackgroundWhenListDidReload() {
        updateListBackgroundWhenViewDidLayoutSubviews()
    }

    private func updateListBackgroundWhenListDidScroll() {
        updateListBackgroundWhenViewDidLayoutSubviews()
    }

    private func updateListBackgroundWhenViewDidLayoutSubviews() {
        listBackgroundView.snp.updateConstraints {
            $0.fitToHeight(max(-listView.contentOffset.y, 0))
        }
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

extension AccountAssetListViewController {
    private func addTransactionActionButton(_ theme: Theme) {
        transactionActionButton.image = "fab-swap".uiImage

        view.addSubview(transactionActionButton)
        transactionActionButton.snp.makeConstraints {
            $0.setPaddings(theme.transactionActionButtonPaddings)
        }
    }
}

extension AccountAssetListViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateUIWhenListDidScroll()
    }
}

extension AccountAssetListViewController: UICollectionViewDelegateFlowLayout {
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
            case .assetManagement:
                guard let item = cell as? ManagementItemCell else {
                    return
                }
                
                item.observe(event: .primaryAction) {
                    [weak self] in
                    guard let self = self else {
                        return
                    }
                    
                    self.eventHandler?(.manageAssets)
                }
                item.observe(event: .secondaryAction) {
                    [weak self] in
                    guard let self = self else {
                        return
                    }
                    
                    self.eventHandler?(.addAsset)
                }
            case .search:
                guard let item = cell as? SearchBarItemCell else {
                    return
                }

                item.contextView.searchInputView.delegate = self
            default:
                return
            }
        case .quickActions:
            guard let item = cell as? AccountQuickActionsCell else {
                return
            }

            item.observe(event: .buyAlgo) {
                [weak self] in
                guard let self = self else {
                    return
                }

                self.eventHandler?(.buyAlgo)
            }

            item.observe(event: .send) {
                [weak self] in
                guard let self = self else {
                    return
                }

                self.eventHandler?(.send)
            }

            item.observe(event: .address) {
                [weak self] in
                guard let self = self else {
                    return
                }

                self.eventHandler?(.address)
            }

            item.observe(event: .more) {
                [weak self] in
                guard let self = self else {
                    return
                }

                self.eventHandler?(.more)
            }
        default:
            return
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
            case .algo:
                openAlgoDetail()
            case .asset:
                let assetIndex = indexPath.item
                
                if let assetDetail = dataController[assetIndex] {
                    self.openAssetDetail(assetDetail, on: self)
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

        return UIContextMenuConfiguration { _ in
            let copyActionItem = UIAction(item: .copyAssetID) {
                [unowned self] _ in
                self.copyToClipboardController.copyID(asset)
            }
            return UIMenu(children: [ copyActionItem ])
        }
    }
}

extension AccountAssetListViewController {
    private func openAlgoDetail() {
        open(
            .algosDetail(
                draft: AlgoTransactionListing(
                    accountHandle: accountHandle
                )
            ),
            by: .push
        )
    }

    private func openAssetDetail(
        _ asset: StandardAsset,
        on screen: UIViewController
    ) {
        screen.open(
            .assetDetail(
                draft: AssetTransactionListing(
                    accountHandle: accountHandle,
                    asset: asset
                )
            ),
            by: .push
        )
    }
}

extension AccountAssetListViewController {
    private func setTransactionActionButtonAction() {
        transactionActionButton.addTarget(
            self,
            action: #selector(didTapTransactionActionButton),
            for: .touchUpInside
        )
    }

    @objc
    private func didTapTransactionActionButton() {
        self.eventHandler?(.transactionOption)
    }
}

extension AccountAssetListViewController: SearchInputViewDelegate {
    func searchInputViewDidEdit(_ view: SearchInputView) {
        dataController.search(for: view.text)
    }

    func searchInputViewDidReturn(_ view: SearchInputView) {
        view.endEditing()
    }

    func searchInputViewDidBeginEditing(_ view: SearchInputView) {
        guard let indexPath = listDataSource.indexPath(for: .search) else {
            return
        }

        listView.scrollToItem(at: indexPath, at: .top, animated: true)
    }
}

extension AccountAssetListViewController: KeyboardControllerDataSource {
    var scrollView: UIScrollView {
        return listView
    }

    func bottomInsetWhenKeyboardPresented(for keyboardController: KeyboardController) -> CGFloat {
        return 20
    }

    func firstResponder(for keyboardController: KeyboardController) -> UIView? {
        return nil
    }

    func containerView(for keyboardController: KeyboardController) -> UIView {
        return listView
    }

    func bottomInsetWhenKeyboardDismissed(for keyboardController: KeyboardController) -> CGFloat {
        return 20
    }
}

extension AccountAssetListViewController {
    func addAsset(_ assetDetail: StandardAsset) {
        dataController.addedAssetDetails.append(assetDetail)
    }

    func removeAsset(_ assetDetail: StandardAsset) {
        dataController.removedAssetDetails.append(assetDetail)
    }
}

extension AccountAssetListViewController {
    private func getAsset(
        at indexPath: IndexPath
    ) -> StandardAsset? {
        guard let itemIdentifier = listDataSource.itemIdentifier(for: indexPath) else {
            return nil
        }

        guard case AccountAssetsItem.asset = itemIdentifier else {
            return nil
        }

        return dataController[indexPath.item]
    }
}

extension AccountAssetListViewController {
    enum Event {
        case didUpdate(AccountHandle)
        case manageAssets
        case addAsset
        case buyAlgo
        case send
        case address
        case more
        case transactionOption
    }
}
