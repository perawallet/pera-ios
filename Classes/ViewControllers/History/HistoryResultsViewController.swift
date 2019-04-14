//
//  HistoryResultsViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 11.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class HistoryResultsViewController: BaseViewController {

    private var transactionHistoryLayoutBuilder: TransactionHistoryLayoutBuilder
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
        transactionHistoryLayoutBuilder = TransactionHistoryLayoutBuilder()
        transactionHistoryDataSource = TransactionHistoryDataSource(api: configuration.api)
        
        super.init(configuration: configuration)
        
        hidesBottomBarWhenPushed = true
    }
    
    // MARK: Setup
    
    override func configureAppearance() {
        super.configureAppearance()
        
        title = "history-title".localized
        
        viewModel.configure(historyResultsView, with: draft)
        
        fetchTransactions()
    }
    
    override func linkInteractors() {
        historyResultsView.transactionHistoryCollectionView.delegate = transactionHistoryLayoutBuilder
        historyResultsView.transactionHistoryCollectionView.dataSource = transactionHistoryDataSource
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
    
    private func fetchTransactions() {
        historyResultsView.transactionHistoryCollectionView.contentState = .loading
        
        transactionHistoryDataSource.loadData(for: draft.account, between: (draft.startDate, draft.endDate)) { transactions, error in
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
