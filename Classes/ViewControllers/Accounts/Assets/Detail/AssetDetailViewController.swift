//
//  AccountDetailViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 26.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit
import NotificationBannerSwift

class AssetDetailViewController: BaseViewController {
    
    let layout = Layout<LayoutConstants>()
    
    private var pollingOperation: PollingOperation?
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(didRefreshList), for: .valueChanged)
        return refreshControl
    }()
    
    private var account: Account
    private var assetDetail: AssetDetail?
    private var isAlgoDisplay: Bool
    
    private var currentDollarConversion: Double?
    private let viewModel: AssetDetailViewModel
    
    private var headerHeight: CGFloat {
        if isAlgoDisplay {
            return AssetDetailView.LayoutConstants.algosHeaderHeight
        }
        
        return AssetDetailView.LayoutConstants.assetHeaderHeight
    }
    
    private var transactionHistoryDataSource: TransactionHistoryDataSource
    
    var route: Screen?
    
    private lazy var assetDetailView = AssetDetailView()
    
    private lazy var emptyStateView = EmptyStateView(
        title: "accounts-tranaction-empty-text".localized,
        topImage: img("icon-transaction-empty-blue"),
        bottomImage: img("icon-transaction-empty-orange"),
        alignment: .bottom
    )
    
    init(account: Account, configuration: ViewControllerConfiguration, assetDetail: AssetDetail? = nil) {
        self.account = account
        self.assetDetail = assetDetail
        self.isAlgoDisplay = assetDetail == nil
        viewModel = AssetDetailViewModel(account: account, assetDetail: assetDetail)
        transactionHistoryDataSource = TransactionHistoryDataSource(api: configuration.api, account: account, assetDetail: assetDetail)
        super.init(configuration: configuration)
        hidesBottomBarWhenPushed = true
    }
    
    deinit {
        pollingOperation?.invalidate()
    }
    
    override func linkInteractors() {
        assetDetailView.delegate = self
        assetDetailView.transactionHistoryCollectionView.delegate = self
        assetDetailView.transactionHistoryCollectionView.dataSource = transactionHistoryDataSource
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        
        navigationItem.title = account.name
        assetDetailView.transactionHistoryCollectionView.refreshControl = refreshControl
        
        viewModel.configure(assetDetailView.headerView, with: account, and: assetDetail)
        viewModel.configure(assetDetailView.smallHeaderView, with: account, and: assetDetail)
        
        transactionHistoryDataSource.setupContacts()
        fetchTransactions()
    }
    
    override func setListeners() {
        super.setListeners()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didAccountUpdate(notification:)),
            name: Notification.Name.AccountUpdate,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didContactAdded(notification:)),
            name: Notification.Name.ContactAddition,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didContactEdited(notification:)),
            name: Notification.Name.ContactEdit,
            object: nil
        )
    }
    
    override func prepareLayout() {
        setupAssetDetaiViewLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchDollarConversion()
        startPendingTransactionPolling()
        
        if let route = route {
            switch route {
            case .assetDetail:
                self.route = nil
                updateAccount()
            default:
                self.route = nil
                open(route, by: .push, animated: false)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        pollingOperation?.invalidate()
    }
    
    @objc
    private func didRefreshList() {
        transactionHistoryDataSource.clear()
        assetDetailView.transactionHistoryCollectionView.reloadData()
        fetchTransactions()
    }
}

extension AssetDetailViewController {
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
                
                strongSelf.assetDetailView.transactionHistoryCollectionView.contentState = .none
                strongSelf.assetDetailView.transactionHistoryCollectionView.reloadData()
            }
        }
        
        pollingOperation?.start()
    }
    
    private func fetchTransactions(witRefresh refresh: Bool = true) {
        if !refreshControl.isRefreshing {
            assetDetailView.transactionHistoryCollectionView.contentState = .loading
        }
        
        transactionHistoryDataSource.loadData(for: account, withRefresh: refresh) { transactions, error in
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
            
            if let error = error {
                switch error {
                case .cancelled:
                    break
                default:
                    self.assetDetailView.transactionHistoryCollectionView.contentState = .empty(self.emptyStateView)
                }
                
                self.assetDetailView.transactionHistoryCollectionView.reloadData()
                return
            }
            
            guard let transactions = transactions else {
                self.assetDetailView.transactionHistoryCollectionView.contentState = .none
                return
            }
            
            if transactions.isEmpty {
                self.assetDetailView.transactionHistoryCollectionView.contentState = .empty(self.emptyStateView)
                return
            }
            
            self.assetDetailView.transactionHistoryCollectionView.contentState = .none
            self.assetDetailView.transactionHistoryCollectionView.reloadData()
        }
    }
    
    private func fetchDollarConversion() {
        api?.fetchDollarValue { response in
            switch response {
            case let .success(result):
                if let price = result.price,
                    let doubleValue = Double(price) {
                    self.currentDollarConversion = doubleValue
                }
            case .failure:
                break
            }
        }
    }
}

extension AssetDetailViewController {
    fileprivate func updateLayout() {
        guard let account = session?.authenticatedUser?.account(address: account.address) else {
            return
        }
        
        viewModel.configure(assetDetailView.headerView, with: account, and: assetDetail)
        viewModel.configure(assetDetailView.smallHeaderView, with: account, and: assetDetail)
    }
    
    private func updateAccount() {
        transactionHistoryDataSource.clear()
        assetDetailView.transactionHistoryCollectionView.reloadData()
        assetDetailView.transactionHistoryCollectionView.contentState = .loading
        
        fetchTransactions()
        
        adjustDefaultHeaderViewLayout(withContentInsetUpdate: true)
        
        updateLayout()
    }
}

extension AssetDetailViewController {
    @objc
    fileprivate func didAccountUpdate(notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: Account],
            let updatedAccount = userInfo["account"] else {
            return
        }
        
        if account == updatedAccount {
            account = updatedAccount
            updateLayout()
            transactionHistoryDataSource.clear()
            assetDetailView.transactionHistoryCollectionView.reloadData()
            assetDetailView.transactionHistoryCollectionView.contentState = .loading
            fetchTransactions()
        }
    }
    
    @objc
    fileprivate func didContactAdded(notification: Notification) {
        transactionHistoryDataSource.setupContacts()
        assetDetailView.transactionHistoryCollectionView.reloadData()
    }
    
    @objc
    fileprivate func didContactEdited(notification: Notification) {
        transactionHistoryDataSource.setupContacts()
        assetDetailView.transactionHistoryCollectionView.reloadData()
    }
}

extension AssetDetailViewController: AssetDetailViewDelegate {
    func assetDetailViewDidTapSendButton(_ assetDetailView: AssetDetailView) {
        if isAlgoDisplay {
            open(.sendAlgosTransactionPreview(account: account, receiver: .initial), by: .push)
        } else {
            guard let assetDetail = assetDetail else {
                return
            }
            open(.sendAssetTransactionPreview(account: account, receiver: .initial, assetDetail: assetDetail), by: .push)
        }
    }
    
    func assetDetailViewDidTapReceiveButton(_ assetDetailView: AssetDetailView) {
        open(.requestTransactionPreview(account: account, assetDetail: assetDetail, isAlgoTransaction: isAlgoDisplay), by: .push)
    }
    
    func assetDetailView(_ assetDetailView: AssetDetailView, didTrigger dollarValueGestureRecognizer: UILongPressGestureRecognizer) {
        guard let currentDollarAmount = currentDollarConversion else {
            return
        }
        
        let dollarAmountForAccount = account.amount.toAlgos * currentDollarAmount
        
        if dollarValueGestureRecognizer.state != .ended {
            viewModel.setDollarValue(visible: true, in: assetDetailView.headerView, for: dollarAmountForAccount)
        } else {
            viewModel.setDollarValue(visible: false, in: assetDetailView.headerView, for: dollarAmountForAccount)
        }
    }
    
    func assetDetailViewDidTapRewardView(_ assetDetailView: AssetDetailView) {
        tabBarController?.open(
            .rewardDetail(account: account),
            by: .customPresentWithoutNavigationController(
                presentationStyle: .overCurrentContext,
                transitionStyle: .crossDissolve,
                transitioningDelegate: nil
            )
        )
    }
    
    func assetDetailView(_ assetDetailView: AssetDetailView, didTriggerAssetIdCopyValue gestureRecognizer: UILongPressGestureRecognizer) {
        if let id = assetDetail?.id {
            displaySimpleAlertWith(title: "asset-id-copied-title".localized, message: "")
            UIPasteboard.general.string = "\(id)"
        }
    }
}

extension AssetDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let transaction = transactionHistoryDataSource.transaction(at: indexPath) else {
                return
        }
        
        if let payment = transaction.payment,
            payment.toAddress == account.address {
            open(
                .transactionDetail(
                    account: account,
                    transaction: transaction,
                    transactionType: .received,
                    assetDetail: assetDetail
                ),
                by: .push
            )
        } else {
            open(
                .transactionDetail(
                    account: account,
                    transaction: transaction,
                    transactionType: .sent,
                    assetDetail: assetDetail
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
        if transactionHistoryDataSource.transaction(at: indexPath) == nil {
            return layout.current.rewardCellSize
        }
        
        return layout.current.transactionCellSize
    }
}

extension AssetDetailViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if transactionHistoryDataSource.transactionCount() == 0 {
            return
        }
        
        let translation = scrollView.panGestureRecognizer.translation(in: view)
        
        if translation.y < 0 {
            let offset = scrollView.contentOffset.y + headerHeight
            
            let offsetDifference = headerHeight - offset
            
            if offsetDifference <= AssetDetailView.LayoutConstants.smallHeaderHeight {
                adjustSmallHeaderViewLayout()
                
                assetDetailView.transactionHistoryCollectionView.contentInset.top = AssetDetailView.LayoutConstants.smallHeaderHeight
            } else {
                assetDetailView.accountsHeaderContainerView.snp.updateConstraints { make in
                    make.height.equalTo(offsetDifference)
                }
                
                assetDetailView.transactionHistoryCollectionView.contentInset.top = offsetDifference
                
                let progress: CGFloat = offsetDifference / headerHeight
                
                UIView.animate(withDuration: 0.0) {
                    self.assetDetailView.headerView.alpha = progress
                    self.view.layoutIfNeeded()
                }
            }
        } else {
            let offset = -scrollView.contentOffset.y
            
            let offsetTotal = AssetDetailView.LayoutConstants.smallHeaderHeight + offset
            
            if offsetTotal >= headerHeight {
                adjustDefaultHeaderViewLayout()
                
                assetDetailView.transactionHistoryCollectionView.contentInset.top = headerHeight
            } else {
                let offset = max(-scrollView.contentOffset.y, AssetDetailView.LayoutConstants.smallHeaderHeight)
                
                let progress: CGFloat = offset / headerHeight
                
                assetDetailView.accountsHeaderContainerView.snp.updateConstraints { make in
                    make.height.equalTo(offset)
                }
                
                assetDetailView.transactionHistoryCollectionView.contentInset.top = offset
                
                UIView.animate(withDuration: 0.33) {
                    self.assetDetailView.headerView.alpha = progress
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if transactionHistoryDataSource.transactionCount() == 0 {
            return
        }
        
        let translation = scrollView.panGestureRecognizer.translation(in: view)
        
        if translation.y < 0 {
            let offset = scrollView.contentOffset.y + headerHeight
            
            let offsetDifference = headerHeight - offset
            
            if offsetDifference <= AssetDetailView.LayoutConstants.smallHeaderHeight {
                return
            }
            
            adjustSmallHeaderViewLayout(withContentInsetUpdate: true)
            
        } else {
            let offset = scrollView.contentInset.top + scrollView.contentOffset.y + AssetDetailView.LayoutConstants.smallHeaderHeight
            
            if offset > headerHeight {
                return
            }
            
            adjustDefaultHeaderViewLayout(withContentInsetUpdate: true)
        }
        
    }
    
    private func adjustSmallHeaderViewLayout(withContentInsetUpdate shouldUpdateContentInset: Bool = false) {
        assetDetailView.accountsHeaderContainerView.snp.updateConstraints { make in
            make.height.equalTo(AssetDetailView.LayoutConstants.smallHeaderHeight)
        }
        
        UIView.animate(withDuration: 0.33) {
            self.assetDetailView.headerView.alpha = 0.0
            self.assetDetailView.smallHeaderView.alpha = 1.0
            
            if shouldUpdateContentInset {
                self.assetDetailView.transactionHistoryCollectionView.contentInset.top = AssetDetailView.LayoutConstants.smallHeaderHeight
                self.assetDetailView.transactionHistoryCollectionView.contentOffset.y = -AssetDetailView.LayoutConstants.smallHeaderHeight
            }
            
            self.view.layoutIfNeeded()
        }
    }
    
    private func adjustDefaultHeaderViewLayout(withContentInsetUpdate shouldUpdateContentInset: Bool = false) {
        assetDetailView.accountsHeaderContainerView.snp.updateConstraints { make in
            make.height.equalTo(headerHeight)
        }
        
        UIView.animate(withDuration: 0.33) {
            self.assetDetailView.smallHeaderView.alpha = 0.0
            self.assetDetailView.headerView.alpha = 1.0
            
            if shouldUpdateContentInset {
                self.assetDetailView.transactionHistoryCollectionView.contentInset.top = self.headerHeight
                self.assetDetailView.transactionHistoryCollectionView.contentOffset.y = -self.headerHeight
            }
            
            self.view.layoutIfNeeded()
        }
    }
}

extension AssetDetailViewController {
    private func setupAssetDetaiViewLayout() {
        view.addSubview(assetDetailView)
        
        assetDetailView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.topInset)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        assetDetailView.accountsHeaderContainerView.snp.updateConstraints { make in
            make.height.equalTo(headerHeight)
        }
        
        assetDetailView.transactionHistoryCollectionView.contentInset.top = headerHeight
    }
}

extension AssetDetailViewController {
    struct LayoutConstants: AdaptiveLayoutConstants {
        let optionsModalHeight: CGFloat = 348.0
        let topInset: CGFloat = 20.0
        let transactionCellSize = CGSize(width: UIScreen.main.bounds.width, height: 72.0)
        let rewardCellSize = CGSize(width: UIScreen.main.bounds.width, height: 50.0)
        let editAccountModalHeight: CGFloat = 158.0
    }
}
