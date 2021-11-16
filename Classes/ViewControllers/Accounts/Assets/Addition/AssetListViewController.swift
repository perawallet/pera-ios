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
//   AssetListViewController.swift

import Foundation

final class AssetListViewController: BaseViewController {
    weak var delegate: AssetListViewControllerDelegate?

    private lazy var theme = Theme()
    private lazy var assetListView = AssetListView()
    private lazy var emptyStateView = SearchEmptyView()
    private lazy var assetListViewLayoutBuilder = AssetListViewLayoutBuilder(theme: theme)
    private lazy var assetListViewDataSource = AssetListViewDataSource()

    var assetResults = [AssetSearchResult]() {
        didSet {
            assetListViewDataSource.assetResults = assetResults
            assetListView.updateContentStateView(assetResults.isEmpty)
            assetListView.collectionView.reloadData()
        }
    }

    override func prepareLayout() {
        super.prepareLayout()
        assetListView.customize(theme.assetListViewTheme)
        view.addSubview(assetListView)
        assetListView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    override func linkInteractors() {
        super.linkInteractors()
        assetListView.collectionView.delegate = assetListViewLayoutBuilder
        assetListView.collectionView.dataSource = assetListViewDataSource
        assetListViewLayoutBuilder.delegate = self
    }
}

extension AssetListViewController: AssetListViewLayoutBuilderDelegate {
    func assetListViewLayoutBuilder(_ assetListViewLayoutBuilder: AssetListViewLayoutBuilder, willDisplayItemAt indexPath: IndexPath) {
        delegate?.assetListViewController(self, willDisplayItemAt: indexPath)
    }

    func assetListViewLayoutBuilder(_ assetListViewLayoutBuilder: AssetListViewLayoutBuilder, didSelectItemAt indexPath: IndexPath) {
        delegate?.assetListViewController(self, didSelectItemAt: indexPath)
    }
}

protocol AssetListViewControllerDelegate: AnyObject {
    func assetListViewController(_ assetListViewController: AssetListViewController, willDisplayItemAt indexPath: IndexPath)
    func assetListViewController(_ assetListViewController: AssetListViewController, didSelectItemAt indexPath: IndexPath)
}
