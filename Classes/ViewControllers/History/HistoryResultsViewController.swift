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
    
    private let draft: HistoryDraft
    
    // MARK: Initialization
    
    init(draft: HistoryDraft, configuration: ViewControllerConfiguration) {
        self.draft = draft
        transactionHistoryLayoutBuilder = TransactionHistoryLayoutBuilder()
        transactionHistoryDataSource = TransactionHistoryDataSource()
        
        super.init(configuration: configuration)
        
        hidesBottomBarWhenPushed = true
    }
    
    // MARK: Setup
    
    override func configureAppearance() {
        super.configureAppearance()
        
        title = "history-title".localized
        
        historyResultsView.accountNameLabel.text = draft.account.name
        historyResultsView.startDateLabel.text = draft.startDate.toFormat("dd MMMM yyyy")
        historyResultsView.endDateLabel.text = draft.endDate.toFormat("dd MMMM yyyy")
    }
    
    override func linkInteractors() {
        transactionHistoryDataSource.delegate = self
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
}

// MARK: TransactionHistoryDataSourceDelegate

extension HistoryResultsViewController: TransactionHistoryDataSourceDelegate {
    
    func transactionHistoryDataSource(_ transactionHistoryDataSource: TransactionHistoryDataSource, didFetch transactions: [Transaction]) {
        
        if !transactions.isEmpty {
            historyResultsView.transactionHistoryCollectionView.contentState = .none
            return
        }
        
        historyResultsView.transactionHistoryCollectionView.contentState = .empty(emptyStateView)
    }
}
