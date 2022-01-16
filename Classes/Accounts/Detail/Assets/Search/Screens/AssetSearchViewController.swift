// Copyright 2019 Algorand, Inc.

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
//   AssetSearchViewController.swift

import Foundation
import UIKit
import MacaroonUtils
import MacaroonUIKit

final class AssetSearchViewController: BaseViewController {
    private lazy var theme = Theme()
    lazy var handlers = Handlers()

    typealias DataSource = UICollectionViewDiffableDataSource<AssetSearchSection, AssetSearchItem>
    typealias Snapshot = NSDiffableDataSourceSnapshot<AssetSearchSection, AssetSearchItem>

    private lazy var listLayout = AssetSearchListLayout(searchResults: searchResults)
    private lazy var searchThrottler = Throttler(intervalInSeconds: 0.3)

    private lazy var searchInputView = SearchInputView()

    private var searchResults: [AssetInformation] = []

    private lazy var listView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = theme.listBackgroundColor.uiColor
        collectionView.contentInset = UIEdgeInsets(theme.collectionViewEdgeInsets)
        collectionView.register(AssetPreviewCell.self)
        collectionView.register(header: SingleLineTitleActionHeaderView.self)
        return collectionView
    }()

    private let account: Account

    init(
        account: Account,
        configuration: ViewControllerConfiguration
    ) {
        self.account = account
        super.init(configuration: configuration)
        searchResults = account.assetInformations
    }

    private lazy var dataSource: DataSource = {
        let dataSource = DataSource(collectionView: listView) {
            [weak self] collectionView, indexPath, identifier in
                guard let self = self else {
                    return nil
                }

                switch identifier {
                case let .asset(assetDetail):
                    let cell = collectionView.dequeue(AssetPreviewCell.self, at: indexPath)

                    if let assetDetail = assetDetail,
                       let asset = self.account.assets?.first(matching: (\.id, assetDetail.id)) {
                        cell.bindData(
                            AssetPreviewViewModel(
                                AssetPreviewModelAdapter.adaptAssetSelection(
                                    (assetDetail, asset)
                                )
                            )
                        )
                    }

                    return cell
                }
        }

        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard let section = AssetSearchSection(rawValue: indexPath.section),
                  section == .assets,
                  kind == UICollectionView.elementKindSectionHeader else {
                return nil
            }

            let view = collectionView.dequeueHeader(SingleLineTitleActionHeaderView.self, at: indexPath)
            view.bindData(
                SingleLineTitleActionViewModel(
                    item: SingleLineIconTitleItem(
                        icon: nil,
                        title: .string("accounts-title-assets".localized)
                    )
                )
            )
            return view
        }

        return dataSource
    }()

    override func configureNavigationBarAppearance() {
        super.configureNavigationBarAppearance()
        addBarButtons()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        applySnapshot(animatingDifferences: false)
    }

    override func setListeners() {
        listView.dataSource = dataSource
        listView.delegate = listLayout
        setListListeners()
    }

    override func linkInteractors() {
        searchInputView.delegate = self
    }

    override func configureAppearance() {
        view.customizeBaseAppearance(backgroundColor: theme.listBackgroundColor)
    }

    override func prepareLayout() {
        addSearchInputView()
        addListView()
    }
}

extension AssetSearchViewController {
    private func addBarButtons() {
        let closeBarButtonItem = ALGBarButtonItem(kind: .close) { [weak self] in
            self?.closeScreen(by: .dismiss, animated: true)
        }

        leftBarButtonItems = [closeBarButtonItem]
    }
}

extension AssetSearchViewController {
    private func addSearchInputView() {
        searchInputView.customize(theme.searchInputViewTheme)

        view.addSubview(searchInputView)
        searchInputView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(theme.topInset)
            $0.top.equalToSuperview().inset(theme.topInset).priority(.low)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }
    }

    private func addListView() {
        view.addSubview(listView)
        listView.snp.makeConstraints {
            $0.top.equalTo(searchInputView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}

extension AssetSearchViewController: SearchInputViewDelegate {
    func searchInputViewDidEdit(_ view: SearchInputView) {
        guard let query = view.text else {
            return
        }

        if query.isEmpty {
            resetSearch()
            return
        }

        searchAssets(for: query)
    }

    private func searchAssets(for query: String) {
        searchThrottler.performNext {
            [weak self] in

            guard let self = self else {
                return
            }

            self.searchResults = self.account.assetInformations.filter {
                String($0.id).contains(query) ||
                    $0.name.unwrap(or: "").contains(query) ||
                    $0.unitName.unwrap(or: "").contains(query)
            }

            asyncMain { [weak self] in
                guard let self = self else {
                    return
                }

                self.applySnapshot()
            }
        }
    }

    func searchInputViewDidReturn(_ view: SearchInputView) {
        view.endEditing()
    }
    
    func searchInputViewDidTapRightAccessory(_ view: SearchInputView) {
        resetSearch()
    }

    private func resetSearch() {
        searchResults = account.assetInformations
        applySnapshot()
    }
}

extension AssetSearchViewController {
    private func applySnapshot(
        animatingDifferences: Bool = true
    ) {
        listLayout.updateSearchResults(searchResults)
        
        var snapshot = Snapshot()
        snapshot.appendSections([.assets])

        var searchSectionItems: [AssetSearchItem] = []

        searchResults.forEach {
            searchSectionItems.append(.asset(asset: $0))
        }

        snapshot.appendItems(
            searchSectionItems,
            toSection: .assets
        )

        dataSource.apply(
            snapshot,
            animatingDifferences: animatingDifferences
        )
    }

    private func setListListeners() {
        listLayout.handlers.didSelectAssetDetail = { [weak self] assetDetail in
            guard let self = self else {
                return
            }

            self.closeScreen(by: .dismiss, animated: false)
            self.handlers.didSelectAssetDetail?(assetDetail)
        }
    }
}

extension AssetSearchViewController {
    struct Handlers {
        var didSelectAssetDetail: ((AssetInformation) -> Void)?
    }
}

enum AssetSearchSection: Int, Hashable {
    case assets
}

enum AssetSearchItem: Hashable {
    case asset(asset: AssetInformation?)
}
