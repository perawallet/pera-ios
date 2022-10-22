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

//   SelectAssetScreen.swift

import Foundation
import MacaroonUIKit
import UIKit

final class SelectAssetScreen:
    BaseViewController,
    UICollectionViewDelegateFlowLayout,
    SearchInputViewDelegate {
    var eventHandler: Screen.EventHandler<SelectAssetScreenEvent>?

    private lazy var searchInputView = SearchInputView()

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

    private lazy var listDataSource = SelectAssetDataSource(listView)
    private lazy var listLayout = SelectAssetListLayout(listDataSource: listDataSource)

    private let dataController: SelectAssetDataController
    private let theme: SelectAssetScreenTheme

    init(
        dataController: SelectAssetDataController,
        theme: SelectAssetScreenTheme = .init(),
        configuration: ViewControllerConfiguration
    ) {
        self.dataController = dataController
        self.theme = theme
        super.init(configuration: configuration)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        dataController.eventHandler = {
            [weak self] event in
            guard let self = self else {
                return
            }

            switch event {
            case .didUpdate(let updates):
                self.listDataSource.apply(
                    updates.snapshot,
                    animatingDifferences: true
                )
            }
        }

        dataController.load()
    }

    override func configureAppearance() {
        super.configureAppearance()
        view.backgroundColor = theme.listBackgroundColor.uiColor
    }

    override func prepareLayout() {
        super.prepareLayout()
        addSearchInput()
        addListView()
    }

    override func linkInteractors() {
        super.linkInteractors()
        searchInputView.delegate = self
        listView.delegate = self
    }
}

extension SelectAssetScreen {
    private func addSearchInput() {
        searchInputView.customize(theme.searchInputView)

        view.addSubview(searchInputView)
        searchInputView.snp.makeConstraints {
            $0.top == theme.searchInsets.top
            $0.leading == theme.searchInsets.leading
            $0.trailing == theme.searchInsets.trailing
        }
    }

    private func addListView() {
        view.addSubview(listView)
        listView.snp.makeConstraints {
            $0.top == searchInputView.snp.bottom + theme.listTopInset
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }
    }
}

extension SelectAssetScreen {
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

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
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
            case .asset(let item):
                eventHandler?(.didSelectAsset(item.model))
            default:
                break
            }
        default:
            break
        }
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
        case .empty(let item):
            if case .loading = item {
                let loadingCell = cell as? PreviewLoadingCell
                loadingCell?.stopAnimating()
            }
        default:
            break
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
            if case .loading = item {
                let loadingCell = cell as? PreviewLoadingCell
                loadingCell?.stopAnimating()
            }
        default:
            break
        }
    }
}

extension SelectAssetScreen {
    func searchInputViewDidEdit(_ view: SearchInputView) {
        guard let query = view.text else { return }

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

enum SelectAssetScreenEvent {
    case didSelectAsset(Asset)
}
