//
//  TransactionListView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 19.05.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class TransactionListView: BaseView {
    
    weak var delegate: TransactionListViewDelegate?
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(didRefreshList), for: .valueChanged)
        return refreshControl
    }()
    
    private lazy var emptyStateView = EmptyStateView(
        image: img("icon-transactions-empty"),
        title: "accounts-tranaction-empty-text".localized,
        subtitle: "accounts-tranaction-empty-detail".localized
    )
    private lazy var otherErrorView = TransactionErrorView()
    private lazy var internetConnectionErrorView = TransactionErrorView()
    
    private lazy var transactionsCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 0.0
        flowLayout.minimumInteritemSpacing = 0.0
        flowLayout.sectionHeadersPinToVisibleBounds = true
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        
        collectionView.register(TransactionHistoryCell.self, forCellWithReuseIdentifier: TransactionHistoryCell.reusableIdentifier)
        collectionView.register(PendingTransactionCell.self, forCellWithReuseIdentifier: PendingTransactionCell.reusableIdentifier)
        collectionView.register(RewardCell.self, forCellWithReuseIdentifier: RewardCell.reusableIdentifier)
        collectionView.register(
            TransactionHistoryHeaderSupplementaryView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TransactionHistoryHeaderSupplementaryView.reusableIdentifier
        )
        return collectionView
    }()
    
    private lazy var contentStateView = ContentStateView()
    
    override func configureAppearance() {
        super.configureAppearance()
        internetConnectionErrorView.setImage(img("icon-no-internet-connection"))
        internetConnectionErrorView.setTitle("internet-connection-error-title".localized)
        internetConnectionErrorView.setSubtitle("internet-connection-error-detail".localized)
        otherErrorView.setImage(img("icon-warning-error"))
        otherErrorView.setTitle("transaction-filter-error-title".localized)
        otherErrorView.setSubtitle("transaction-filter-error-subtitle".localized)
    }
    
    override func linkInteractors() {
        otherErrorView.delegate = self
        internetConnectionErrorView.delegate = self
    }
    
    override func prepareLayout() {
        setupTransactionHistoryCollectionViewLayout()
    }
}

extension TransactionListView {
    private func setupTransactionHistoryCollectionViewLayout() {
        addSubview(transactionsCollectionView)
        
        transactionsCollectionView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        transactionsCollectionView.backgroundView = contentStateView
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
    
    func setDelegate(_ delegate: UICollectionViewDelegate?) {
        transactionsCollectionView.delegate = delegate
    }
    
    func setDataSource(_ dataSource: UICollectionViewDataSource?) {
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

extension TransactionListView: TransactionErrorViewDelegate {
    func transactionErrorViewDidTryAgain(_ transactionErrorView: TransactionErrorView) {
        delegate?.transactionListViewDidTryAgain(self)
    }
}

protocol TransactionListViewDelegate: class {
    func transactionListViewDidRefreshList(_ transactionListView: TransactionListView)
    func transactionListViewDidTryAgain(_ transactionListView: TransactionListView)
}
