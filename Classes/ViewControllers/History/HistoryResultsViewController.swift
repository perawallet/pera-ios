//
//  HistoryResultsViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 11.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class HistoryResultsViewController: BaseViewController {
    
    private var transactionHistoryDataSource: TransactionHistoryDataSource
    
    private lazy var historyResultsView = HistoryResultsView()
    
    private lazy var emptyStateView = EmptyStateView(
        title: "tranaction-empty-text".localized,
        topImage: img("icon-transaction-empty-blue"),
        bottomImage: img("icon-transaction-empty-orange")
    )
    
    private let viewModel = HistoryResultsViewModel()
    private let draft: HistoryDraft
    
    init(draft: HistoryDraft, configuration: ViewControllerConfiguration) {
        self.draft = draft
        transactionHistoryDataSource = TransactionHistoryDataSource(
            api: configuration.api,
            account: draft.account,
            assetDetail: draft.assetDetail
        )
        
        super.init(configuration: configuration)
        hidesBottomBarWhenPushed = true
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        
        title = "history-title".localized
        
        viewModel.configure(historyResultsView, with: draft)
        transactionHistoryDataSource.setupContacts()
        fetchTransactions()
    }
    
    override func linkInteractors() {
        historyResultsView.transactionHistoryCollectionView.delegate = self
        historyResultsView.transactionHistoryCollectionView.dataSource = transactionHistoryDataSource
    }
    
    override func setListeners() {
        super.setListeners()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didContactAdded(notification:)),
            name: Notification.Name.ContactAddition,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didContactAdded(notification:)),
            name: Notification.Name.ContactEdit,
            object: nil
        )
    }
    
    override func prepareLayout() {
        setupHistoryResultsViewLayout()
    }
}

extension HistoryResultsViewController {
    private func setupHistoryResultsViewLayout() {
        view.addSubview(historyResultsView)
        
        historyResultsView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension HistoryResultsViewController {
    private func fetchTransactions(witRefresh refresh: Bool = true) {
        historyResultsView.transactionHistoryCollectionView.contentState = .loading
        
        transactionHistoryDataSource.loadData(
            for: draft.account,
            withRefresh: refresh,
            between: (draft.startDate, draft.endDate)
        ) { transactions, error in
                
                if error != nil {
                    self.historyResultsView.transactionHistoryCollectionView.contentState = .empty(self.emptyStateView)
                    self.historyResultsView.transactionHistoryCollectionView.reloadData()
                    return
                }
            
                guard let transactions = transactions else {
                    self.historyResultsView.transactionHistoryCollectionView.contentState = .none
                    return
                }
            
                if transactions.isEmpty {
                    self.historyResultsView.transactionHistoryCollectionView.contentState = .empty(self.emptyStateView)
                    return
                }
            
                self.historyResultsView.transactionHistoryCollectionView.contentState = .none
                self.historyResultsView.transactionHistoryCollectionView.reloadData()
        }
    }
}

extension HistoryResultsViewController {
    @objc
    fileprivate func didContactAdded(notification: Notification) {
        transactionHistoryDataSource.setupContacts()
    }
}

extension HistoryResultsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let transaction = transactionHistoryDataSource.transaction(at: indexPath) else {
            return
        }
        
        if let payment = transaction.payment,
            payment.toAddress == draft.account.address {
            
            open(
                .transactionDetail(
                    account: draft.account,
                    transaction: transaction,
                    transactionType: .received,
                    assetDetail: draft.assetDetail
                ),
                by: .push
            )
        } else {
            open(
                .transactionDetail(
                    account: draft.account,
                    transaction: transaction,
                    transactionType: .sent,
                    assetDetail: draft.assetDetail
                ),
                by: .push
            )
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 80.0)
    }
}
