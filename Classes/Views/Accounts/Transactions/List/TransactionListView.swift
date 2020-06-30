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
    
    func setLoadingState() {
        if !refreshControl.isRefreshing {
            transactionsCollectionView.contentState = .loading
        }
    }
    
    func setNormalState() {
        transactionsCollectionView.contentState = .none
    }
    
    func headerView() -> TransactionHistoryHeaderSupplementaryView {
        guard let headerView = transactionsCollectionView.supplementaryView(
            forElementKind: UICollectionView.elementKindSectionHeader,
            at: IndexPath(item: 0, section: 0)
        ) as? TransactionHistoryHeaderSupplementaryView else {
            fatalError("Unexpected element kind")
        }
        
        return headerView
    }
}

protocol TransactionListViewDelegate: class {
    func transactionListViewDidRefreshList(_ transactionListView: TransactionListView)
}
