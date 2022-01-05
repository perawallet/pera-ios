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
//  TransactionListView.swift

import UIKit
import MacaroonUIKit

final class TransactionListView: View {
    weak var delegate: TransactionListViewDelegate?

    private lazy var theme = TransactionListViewTheme()
    
    private lazy var refreshControl = UIRefreshControl()
    
    private lazy var emptyStateView = EmptyStateView(
        image: img("icon-transactions-empty"),
        title: "accounts-tranaction-empty-text".localized,
        subtitle: ""
    )
    private lazy var otherErrorView = ListErrorView()
    private lazy var internetConnectionErrorView = ListErrorView()
    
    private(set) lazy var transactionsCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = theme.cellSpacing
        flowLayout.sectionHeadersPinToVisibleBounds = true
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = theme.backgroundColor.uiColor
        collectionView.register(TransactionHistoryCell.self)
        collectionView.register(PendingTransactionCell.self)
        collectionView.register(TransactionHistoryTitleCell.self)
        collectionView.register(header: TransactionHistoryHeaderSupplementaryView.self)
        return collectionView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        customize(TransactionListViewTheme())
        linkInteractors()
    }

    func linkInteractors() {
        otherErrorView.delegate = self
        internetConnectionErrorView.delegate = self
        refreshControl.addTarget(self, action: #selector(didRefreshList), for: .valueChanged)
    }

    func customize(_ theme: TransactionListViewTheme) {
        internetConnectionErrorView.setImage(img("icon-no-internet-connection"))
        internetConnectionErrorView.setTitle("internet-connection-error-title".localized)
        internetConnectionErrorView.setSubtitle("internet-connection-error-detail".localized)
        otherErrorView.setImage(img("icon-warning-error"))
        otherErrorView.setTitle("transaction-filter-error-title".localized)
        otherErrorView.setSubtitle("transaction-filter-error-subtitle".localized)
        emptyStateView.titleLabel.textColor = Colors.Text.tertiary
        emptyStateView.titleLabel.font = UIFont.font(withWeight: .medium(size: 16))

        addTransactionHistoryCollectionView()
    }

    func prepareLayout(_ layoutSheet: LayoutSheet) {}

    func customizeAppearance(_ styleSheet: ViewStyle) { }
}

extension TransactionListView {
    private func addTransactionHistoryCollectionView() {
        addSubview(transactionsCollectionView)
        transactionsCollectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        transactionsCollectionView.backgroundView = ContentStateView()
        transactionsCollectionView.refreshControl = refreshControl
    }
}

extension TransactionListView {
    @objc
    private func didRefreshList() {
        delegate?.transactionListViewDidRefreshList(self)
    }
}

extension TransactionListView {
    func reloadData() {
        transactionsCollectionView.reloadData()
    }
    
    func setCollectionViewDelegate(_ delegate: UICollectionViewDelegate?) {
        transactionsCollectionView.delegate = delegate
    }
    
    func setCollectionViewDataSource(_ dataSource: UICollectionViewDataSource?) {
        transactionsCollectionView.dataSource = dataSource
    }
    
    var isListRefreshing: Bool {
        return refreshControl.isRefreshing
    }
    
    func endRefreshing() {
        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
    }
    
    func setEmptyState() {
        transactionsCollectionView.contentState = .empty(emptyStateView)
    }
    
    func setOtherErrorState() {
        transactionsCollectionView.contentState = .error(otherErrorView)
    }
    
    func setInternetConnectionErrorState() {
        transactionsCollectionView.contentState = .error(internetConnectionErrorView)
    }
    
    func setLoadingState() {
        if !refreshControl.isRefreshing {
            transactionsCollectionView.contentState = .loading
        }
    }
    
    func setNormalState() {
        transactionsCollectionView.contentState = .none
    }
    
    func headerView() -> TransactionHistoryHeaderSupplementaryView? {
        return transactionsCollectionView.supplementaryView(
            forElementKind: UICollectionView.elementKindSectionHeader,
            at: IndexPath(item: 0, section: 0)
        ) as? TransactionHistoryHeaderSupplementaryView
    }
}

extension TransactionListView: ListErrorViewDelegate {
    func listErrorViewDidTryAgain(_ listErrorView: ListErrorView) {
        delegate?.transactionListViewDidTryAgain(self)
    }
}

protocol TransactionListViewDelegate: AnyObject {
    func transactionListViewDidRefreshList(_ transactionListView: TransactionListView)
    func transactionListViewDidTryAgain(_ transactionListView: TransactionListView)
}
