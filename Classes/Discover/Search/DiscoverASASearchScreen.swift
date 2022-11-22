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

//   DiscoverASASearchScreen.swift

import Foundation
import MacaroonForm
import MacaroonUIKit
import UIKit

final class DiscoverASASearchScreen:
    BaseViewController,
    MacaroonForm.KeyboardControllerDataSource,
    UICollectionViewDelegateFlowLayout {

    typealias EventHandler = (Event, DiscoverASASearchScreen) -> Void
    
    var eventHandler: EventHandler?

    override var shouldShowNavigationBar: Bool { false }

    private lazy var searchInputView: SearchInputView = .init()
    private lazy var searchInputBackgroundView: EffectView = .init()
    private lazy var cancelActionView: UIButton = .init()
    private lazy var listView: UICollectionView =
        .init(frame: .zero, collectionViewLayout: DiscoverASASearchScreenLayout.build())

    private lazy var dataSource = DiscoveryASASearchDataSource(
        collectionView: listView,
        assetListItemViewModelProvider: findAssetListItemViewModel
    )
    private lazy var listLayout = DiscoverASASearchScreenLayout(
        listDataSource: dataSource,
        assetListItemViewModelProvider: findAssetListItemViewModel
    )

    private lazy var currencyFormatter = CurrencyFormatter()

    private lazy var keyboardController =
        MacaroonForm.KeyboardController(scrollView: listView, screen: self)

    private var isViewLayoutLoaded = false

    private let dataController: DiscoveryASASearchDataController

    private let theme = DiscoverASASearchScreenTheme()

    init(
        dataController: DiscoveryASASearchDataController,
        configuration: ViewControllerConfiguration
    ) {
        self.dataController = dataController
        super.init(configuration: configuration)

        startObservingDataChanges()

        keyboardController.activate()
    }

    deinit {
        keyboardController.deactivate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addUI()
        updateUIWhenKeyboardDidToggle()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if view.bounds.isEmpty { return }

        if !isViewLayoutLoaded {
            loadInitialData()
            isViewLayoutLoaded = true
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startAnimatingLoadingIfNeededWhenViewDidAppear()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopAnimatingLoadingIfNeededWhenViewDidDisappear()
    }
}

/// <mark>
/// SearchInputViewDelegate
extension DiscoverASASearchScreen: SearchInputViewDelegate {
    func searchInputViewDidEdit(_ view: SearchInputView) {
        loadRequestedData()
    }

    func searchInputViewDidReturn(_ view: SearchInputView) {
        view.endEditing()
    }
}

/// <mark>
/// UICollectionViewDelegateFlowLayout
extension DiscoverASASearchScreen {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return listLayout.listView(
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
        return listLayout.listView(
            collectionView,
            layout: collectionViewLayout,
            sizeForItemAt: indexPath
        )
    }
}

/// <mark>
/// UICollectionViewDelegate
extension DiscoverASASearchScreen {
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard let itemIdentifier = dataSource.itemIdentifier(for: indexPath) else { return }

        switch itemIdentifier {
        case .loading:
            startAnimatingListLoadingIfNeeded(cell)
        case .error:
            startObservingListErrorEvents(cell)
        case .nextLoading:
            startAnimatingNextListLoadingIfNeeded(cell)
        case .nextError:
            startObservingNextListErrorEvents(cell)
        default:
            break
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplaying cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard let itemIdentifier = dataSource.itemIdentifier(for: indexPath) else { return }

        switch itemIdentifier {
        case .loading:
            stopAnimatingListLoadingIfNeeded(cell)
        case .nextLoading:
            stopAnimatingNextListLoadingIfNeeded(cell)
        default:
            break
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let itemIdentifier = dataSource.itemIdentifier(for: indexPath) else { return }

        switch itemIdentifier {
        case .asset(let assetItem):
            handleSelectionOfCellForAssetItem(assetItem)
        default:
            break
        }
    }
}

/// <mark>
/// UIScrollViewDelegate
extension DiscoverASASearchScreen {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentHeight = scrollView.contentSize.height
        let scrollHeight = scrollView.bounds.height

        if contentHeight <= scrollHeight ||
           contentHeight - scrollView.contentOffset.y < 2 * scrollHeight {
            loadNextData()
        }
    }
}

extension DiscoverASASearchScreen {
    private func addUI() {
        addBackground()
        addSearchInput()
        addCancelAction()
        addList()
    }

    private func updateUIWhenKeyboardDidToggle() {
        keyboardController.performAlongsideWhenKeyboardIsShowing(animated: true) {
            [unowned self] _ in
            if self.dataSource.isEmpty() {
                self.listView.collectionViewLayout.invalidateLayout()
                self.listView.layoutIfNeeded()
            }
        }
        keyboardController.performAlongsideWhenKeyboardIsHiding(animated: true) {
            [unowned self] _ in
            if self.dataSource.isEmpty() {
                self.listView.collectionViewLayout.invalidateLayout()
                self.listView.layoutIfNeeded()
            }
        }
    }

    private func addBackground() {
        view.customizeAppearance(theme.background)
    }

    private func addSearchInput() {
        searchInputView.customize(theme.searchInput)

        view.addSubview(searchInputView)
        searchInputView.snp.makeConstraints {
            $0.top == view.safeAreaLayoutGuide.snp.top + theme.contentTopEdgeInset
            $0.leading == theme.contentHorizontalEdgeInsets.leading
        }

        searchInputView.delegate = self

        searchInputBackgroundView.effect = theme.searchInputBackground
        searchInputBackgroundView.isUserInteractionEnabled = false

        view.insertSubview(
            searchInputBackgroundView,
            belowSubview: searchInputView
        )
        searchInputBackgroundView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.bottom == searchInputView + theme.spacingBetweenSearchInputAndSearchInputBackground
            $0.trailing == 0
        }
    }

    private func addCancelAction() {
        cancelActionView.customizeAppearance(theme.cancelAction)

        view.addSubview(cancelActionView)
        cancelActionView.contentEdgeInsets = theme.cancelActionContentEdgeInsets
        cancelActionView.fitToHorizontalIntrinsicSize()
        cancelActionView.snp.makeConstraints {
            $0.height == searchInputView
            $0.centerY == searchInputView
            $0.leading == searchInputView.snp.trailing + theme.spacingBetweenSearchInputAndCancelAction
            $0.trailing ==
                theme.contentHorizontalEdgeInsets.trailing -
                theme.cancelActionContentEdgeInsets.right
        }

        cancelActionView.addTouch(
            target: self,
            action: #selector(cancel)
        )
    }

    private func addList() {
        listView.customizeAppearance(theme.list)

        view.insertSubview(
            listView,
            belowSubview: searchInputBackgroundView
        )
        listView.snp.makeConstraints {
            $0.top == searchInputView.snp.bottom
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }

        listView.showsVerticalScrollIndicator = false
        listView.showsHorizontalScrollIndicator = false
        listView.alwaysBounceVertical = true
        listView.keyboardDismissMode = .interactive
        listView.delegate = self
    }
}

extension DiscoverASASearchScreen {
    private func startObservingListErrorEvents(_ cell: UICollectionViewCell) {
        let errorCell = cell as? DiscoverErrorCell
        errorCell?.startObserving(event: .retry) {
            [unowned self] in
            self.loadRequestedData()
        }
    }

    private func startObservingNextListErrorEvents(_ cell: UICollectionViewCell) {
        let errorCell = cell as? DiscoverSearchNextListErrorCell
        errorCell?.startObserving(event: .retry) {
            [unowned self] in
            self.loadNextData()
        }
    }
}

extension DiscoverASASearchScreen {
    private func startAnimatingLoadingIfNeededWhenViewDidAppear() {
        if isViewFirstAppeared { return }

        for cell in listView.visibleCells {
            if let listLoadingCell = cell as? DiscoverSearchListLoadingCell {
                listLoadingCell.restartAnimating()
                break
            }

            if let nextListLoadingCell = cell as? DiscoverSearchNextListLoadingCell {
                nextListLoadingCell.startAnimating()
                break
            }
        }
    }

    private func startAnimatingListLoadingIfNeeded(_ cell: UICollectionViewCell) {
        let loadingCell = cell as? DiscoverSearchListLoadingCell
        loadingCell?.startAnimating()
    }

    private func startAnimatingNextListLoadingIfNeeded(_ cell: UICollectionViewCell) {
        let loadingCell = cell as? DiscoverSearchNextListLoadingCell
        loadingCell?.startAnimating()
    }

    private func stopAnimatingLoadingIfNeededWhenViewDidDisappear() {
        for cell in listView.visibleCells {
            if let listLoadingCell = cell as? DiscoverSearchListLoadingCell {
                listLoadingCell.stopAnimating()
                break
            }

            if let nextListLoadingCell = cell as? DiscoverSearchNextListLoadingCell {
                nextListLoadingCell.stopAnimating()
                break
            }
        }
    }

    private func stopAnimatingListLoadingIfNeeded(_ cell: UICollectionViewCell) {
        let loadingCell = cell as? DiscoverSearchListLoadingCell
        loadingCell?.stopAnimating()
    }

    private func stopAnimatingNextListLoadingIfNeeded(_ cell: UICollectionViewCell) {
        let loadingCell = cell as? DiscoverSearchNextListLoadingCell
        loadingCell?.stopAnimating()
    }
}

extension DiscoverASASearchScreen {
    @objc
    private func cancel() {
        closeScreen(by: .dismiss)
    }
}

extension DiscoverASASearchScreen {
    private func startObservingDataChanges() {
        dataController.eventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .didReload(let snapshot):
                self.dataSource.reload(snapshot) {
                    [weak self] in
                    guard let self = self else { return }

                    self.listView.scrollToTop(animated: true)
                }
            case .didUpdate(let snapshot):
                self.dataSource.apply(
                    snapshot,
                    animatingDifferences: self.isViewAppeared
                )
            }
        }
    }

    private func loadInitialData() {
        dataController.loadListData(query: nil)
    }

    private func loadRequestedData() {
        let keyword = searchInputView.text
        let query = keyword.unwrap(DiscoverSearchQuery.init)
        dataController.loadListData(query: query)
    }

    private func loadNextData() {
        dataController.loadNextListData()
    }
}

extension DiscoverASASearchScreen {
    private func handleSelectionOfCellForAssetItem(_ item: DiscoverSearchAssetListItem) {
        let tokenDetail = DiscoverTokenDetail(tokenId: String(item.assetID))

        eventHandler?(.selectAsset(tokenDetail), self)
    }
}

extension DiscoverASASearchScreen {
    private func findAssetListItemViewModel(forID assetID: AssetID) -> DiscoverSearchAssetListItemViewModel? {
        return dataController[assetID]
    }
}

extension DiscoverASASearchScreen {
    enum Event {
        case selectAsset(DiscoverTokenDetail)
    }
}
