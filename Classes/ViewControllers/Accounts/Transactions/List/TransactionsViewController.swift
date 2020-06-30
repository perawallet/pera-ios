//
//  TransactionsViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 19.05.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class TransactionsViewController: BaseViewController {
    
    let layout = Layout<LayoutConstants>()
    
    private var pollingOperation: PollingOperation?
    private var account: Account
    private var assetDetail: AssetDetail?
    
    private let viewModel = TransactionsViewModel()
    
    weak var delegate: TransactionsViewControllerDelegate?
    
    private var filterOption = TransactionFilterViewController.FilterOption.allTime
    
    private lazy var filterOptionsPresenter = CardModalPresenter(
        config: ModalConfiguration(
            animationMode: .normal(duration: 0.25),
            dismissMode: .scroll
        ),
        initialModalSize: .custom(CGSize(width: view.frame.width, height: layout.current.filterOptionsModalHeight))
    )
    
    private var transactionHistoryDataSource: TransactionHistoryDataSource
    
    private lazy var transactionListView = TransactionListView()
    
    init(account: Account, configuration: ViewControllerConfiguration, assetDetail: AssetDetail? = nil) {
        self.account = account
        self.assetDetail = assetDetail
        transactionHistoryDataSource = TransactionHistoryDataSource(api: configuration.api, account: account, assetDetail: assetDetail)
        super.init(configuration: configuration)
    }
    
    deinit {
        pollingOperation?.invalidate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        transactionHistoryDataSource.setupContacts()
        fetchTransactions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startPendingTransactionPolling()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        pollingOperation?.invalidate()
    }
    
    override func setListeners() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didContactAdded(notification:)),
            name: .ContactAddition,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didContactEdited(notification:)),
            name: .ContactEdit,
            object: nil
        )
        
        transactionHistoryDataSource.openFilterOptionsHandler = { [weak self] dataSource -> Void in
            guard let strongSelf = self else {
                return
            }
            
            let controller = strongSelf.open(
                .transactionFilter(filterOption: strongSelf.filterOption),
                by: .customPresent(
                    presentationStyle: .custom,
                    transitionStyle: nil,
                    transitioningDelegate: strongSelf.filterOptionsPresenter
                )
            ) as? TransactionFilterViewController
            
            controller?.delegate = self
        }
        
        transactionHistoryDataSource.shareHistoryHandler = { [weak self] dataSource -> Void in
            guard let strongSelf = self else {
                return
            }
        }
    }
    
    override func linkInteractors() {
        transactionListView.delegate = self
        transactionListView.setDelegate(self)
        transactionListView.setDataSource(transactionHistoryDataSource)
    }
    
    override func prepareLayout() {
        setupTransactionListViewLayout()
    }
}

extension TransactionsViewController: TransactionListViewDelegate {
    func transactionListViewDidRefreshList(_ transactionListView: TransactionListView) {
        transactionHistoryDataSource.clear()
        transactionListView.reloadData()
        fetchTransactions()
    }
}

extension TransactionsViewController {
    private func startPendingTransactionPolling() {
        pollingOperation = PollingOperation(interval: 0.8) { [weak self] in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.transactionHistoryDataSource.fetchPendingTransactions(for: strongSelf.account) { pendingTransactions, error in
                if error != nil {
                    return
                }
                
                guard let pendingTransactions = pendingTransactions, !pendingTransactions.isEmpty else {
                    return
                }
                
                strongSelf.transactionListView.setNormalState()
                strongSelf.transactionListView.reloadData()
            }
        }
        
        pollingOperation?.start()
    }
    
    private func fetchTransactions(witRefresh refresh: Bool = true) {
        transactionListView.setLoadingState()
        
        transactionHistoryDataSource.loadData(for: account, withRefresh: refresh) { transactions, error in
            self.transactionListView.endRefreshing()
            
            if let error = error {
                switch error {
                case .cancelled:
                    break
                default:
                    self.transactionListView.setEmptyState()
                }
                
                self.transactionListView.reloadData()
                return
            }
            
            guard let transactions = transactions else {
                self.transactionListView.setNormalState()
                return
            }
            
            if transactions.isEmpty {
                self.transactionListView.setEmptyState()
                return
            }
            
            self.transactionListView.setNormalState()
            self.transactionListView.reloadData()
        }
    }
}

extension TransactionsViewController: UICollectionViewDelegateFlowLayout {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.transactionsViewController(self, didScroll: scrollView)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        delegate?.transactionsViewController(self, didStopScrolling: scrollView)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        delegate?.transactionsViewController(self, didStopScrolling: scrollView)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let transaction = transactionHistoryDataSource.transaction(at: indexPath),
            !transaction.isAssetAdditionTransaction(for: account.address) else {
            return
        }
        
        openTransactionDetail(transaction)
    }
    
    private func openTransactionDetail(_ transaction: Transaction) {
        if transaction.sender == account.address {
            open(
                .transactionDetail(
                    account: account,
                    transaction: transaction,
                    transactionType: .sent,
                    assetDetail: assetDetail
                ),
                by: .present
            )
        } else {
            open(
                .transactionDetail(
                    account: account,
                    transaction: transaction,
                    transactionType: .received,
                    assetDetail: assetDetail
                ),
                by: .present
            )
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return layout.current.transactionCellSize
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        if transactionHistoryDataSource.transactionCount() == 0 {
            return .zero
        }
        return layout.current.headerSize
    }
}

extension TransactionsViewController {
    private func setupTransactionListViewLayout() {
        view.addSubview(transactionListView)
        
        transactionListView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension TransactionsViewController {
    @objc
    private func didContactAdded(notification: Notification) {
        transactionHistoryDataSource.setupContacts()
        transactionListView.reloadData()
    }
    
    @objc
    private func didContactEdited(notification: Notification) {
        transactionHistoryDataSource.setupContacts()
        transactionListView.reloadData()
    }
}

extension TransactionsViewController {
    func updateList() {
        transactionHistoryDataSource.clear()
        transactionListView.reloadData()
        transactionListView.setLoadingState()
        fetchTransactions()
    }
    
    var isTransactionListEmpty: Bool {
        return transactionHistoryDataSource.isEmpty
    }
}

extension TransactionsViewController: TransactionFilterViewControllerDelegate {
    func transactionFilterViewController(
        _ transactionFilterViewController: TransactionFilterViewController,
        didSelect filterOption: TransactionFilterViewController.FilterOption
    ) {
        if self.filterOption == filterOption {
            return
        }
        
        self.filterOption = filterOption
        viewModel.configure(transactionListView.headerView(), for: filterOption)
    }
}

extension TransactionsViewController {
    struct LayoutConstants: AdaptiveLayoutConstants {
        let transactionCellSize = CGSize(width: UIScreen.main.bounds.width, height: 72.0)
        let editAccountModalHeight: CGFloat = 158.0
        let headerSize = CGSize(width: UIScreen.main.bounds.width, height: 68.0)
        let filterOptionsModalHeight: CGFloat = 506.0
    }
}

protocol TransactionsViewControllerDelegate: class {
    func transactionsViewController(_ transactionsViewController: TransactionsViewController, didScroll scrollView: UIScrollView)
    func transactionsViewController(_ transactionsViewController: TransactionsViewController, didStopScrolling scrollView: UIScrollView)
}
