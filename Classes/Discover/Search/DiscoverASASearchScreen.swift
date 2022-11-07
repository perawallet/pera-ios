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
import UIKit
import MagpieHipo
import MagpieExceptions

final class DiscoverASASearchScreen:
    BaseViewController,
    UICollectionViewDelegateFlowLayout {
    private lazy var theme = Theme()

    private lazy var dataSource = DiscoveryASASearchDataSource(assetListView.collectionView)
    private lazy var listLayout = DiscoverASASearchScreenLayout(listDataSource: dataSource)

    private lazy var assetSearchInput = SearchInputView()
    private lazy var assetListView = AssetListView()

    private lazy var currencyFormatter = CurrencyFormatter()

    private let dataController: DiscoveryASASearchDataController

    init(
        dataController: DiscoveryASASearchDataController,
        configuration: ViewControllerConfiguration
    ) {
        self.dataController = dataController
        super.init(configuration: configuration)
    }

    override func configureAppearance() {
        super.configureAppearance()

        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        title = "title-add-asset".localized
    }

    override func prepareLayout() {
        super.prepareLayout()

        addAssetSearchInput()
        addAssetList()
    }

    override func linkInteractors() {
        super.linkInteractors()

        assetSearchInput.delegate = self

        assetListView.collectionView.dataSource = dataSource
        assetListView.collectionView.delegate = self
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
                if #available(iOS 15, *) {
                    self.dataSource.applySnapshotUsingReloadData(snapshot) {
                        [weak self] in
                        guard let self = self else { return }

                        self.assetListView.collectionView.scrollToTop(animated: true)
                    }
                } else {
                    self.dataSource.apply(
                        snapshot,
                        animatingDifferences: self.isViewAppeared
                    ) { [weak self] in
                        guard let self = self else { return }

                        self.assetListView.collectionView.scrollToTop(animated: true)
                    }
                }
            case .didUpdateNext(let snapshot):
                self.dataSource.apply(
                    snapshot,
                    animatingDifferences: self.isViewAppeared
                )
            }
        }

        dataController.load()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        assetListView.collectionView.visibleCells.forEach {
            let loadingCell = $0 as? PreviewLoadingCell
            loadingCell?.stopAnimating()
        }
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

/// <mark>
/// UICollectionViewDelegate
extension DiscoverASASearchScreen {
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        defer {
            dataController.loadNextPageIfNeeded(for: indexPath)
        }

        guard let itemIdentifier = dataSource.itemIdentifier(for: indexPath) else {
            return
        }

        switch itemIdentifier {
        case .asset(let item):
            break
        case .loading:
            let loadingCell = cell as? PreviewLoadingCell
            loadingCell?.startAnimating()
        default:
            break
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplaying cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard let itemIdentifier = dataSource.itemIdentifier(for: indexPath) else {
            return
        }

        switch itemIdentifier {
        case .loading:
            let loadingCell = cell as? PreviewLoadingCell
            loadingCell?.stopAnimating()
        default:
            break
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard case .asset(let item) = dataSource.itemIdentifier(for: indexPath) else { return }

        let asset = item.model
    }
}

extension DiscoverASASearchScreen {
    private func addAssetSearchInput() {
        assetSearchInput.customize(theme.searchInputViewTheme)
        view.addSubview(assetSearchInput)
        assetSearchInput.snp.makeConstraints {
            $0.top.equalToSuperview().inset(theme.searchInputTopPadding)
            $0.leading.trailing.equalToSuperview().inset(theme.searchInputHorizontalPadding)
        }
    }

    private func addAssetList() {
        assetListView.customize(AssetListViewTheme())
        view.addSubview(assetListView)
        assetListView.snp.makeConstraints {
            $0.top.equalTo(assetSearchInput.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}

extension DiscoverASASearchScreen: SearchInputViewDelegate {
    func searchInputViewDidEdit(_ view: SearchInputView) {
        let query = view.text
        dataController.search(for: query)
    }

    func searchInputViewDidReturn(_ view: SearchInputView) {
        view.endEditing()
    }
}
