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
    
    // MARK: Components
    
    private lazy var historyResultsView: HistoryResultsView = {
        let view = HistoryResultsView()
        return view
    }()
    
    private lazy var emptyStateView = EmptyStateView(
        title: "tranaction-empty-text".localized,
        topImage: img("icon-transaction-empty-green"),
        bottomImage: img("icon-transaction-empty-blue")
    )
    
    private let viewModel = HistoryResultsViewModel()
    
    private let draft: HistoryDraft
    
    // MARK: Initialization
    
    init(draft: HistoryDraft, configuration: ViewControllerConfiguration) {
        self.draft = draft
        transactionHistoryDataSource = TransactionHistoryDataSource(api: configuration.api)
        
        super.init(configuration: configuration)
        
        hidesBottomBarWhenPushed = true
    }
    
    // MARK: Setup
    
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
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupHistoryResultsViewLayout()
    }
    
    private func setupHistoryResultsViewLayout() {
        view.addSubview(historyResultsView)
        
        historyResultsView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    // MARK: Data
    
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
    
    @objc
    fileprivate func didContactAdded(notification: Notification) {
        transactionHistoryDataSource.setupContacts()
    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension HistoryResultsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let transaction = transactionHistoryDataSource.transaction(at: indexPath) else {
            return
        }
        
        if let payment = transaction.payment,
            payment.toAddress == draft.account.address {
            
            open(.transactionDetail(account: draft.account, transaction: transaction, transactionType: .received), by: .push)
        } else {
            open(.transactionDetail(account: draft.account, transaction: transaction, transactionType: .sent), by: .push)
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        
        return CGSize(width: UIScreen.main.bounds.width, height: 80.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        if transactionHistoryDataSource.transactionCount() == indexPath.row - 3 {
//            fetchTransactions(witRefresh: false)
//        }
    }
}
