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
    
    private lazy var rewardsModalPresenter = CardModalPresenter(
        config: ModalConfiguration(
            animationMode: .normal(duration: 0.25),
            dismissMode: .scroll
        ),
        initialModalSize: .custom(CGSize(width: view.frame.width, height: 472.0))
    )
    
    private var pollingOperation: PollingOperation?
    private var account: Account
    private var assetDetail: AssetDetail?
    private var isAlgoDisplay: Bool
    private(set) var transactionHistoryDataSource: TransactionHistoryDataSource
    private var currentDollarConversion: Double?
    private let viewModel: AssetDetailViewModel
    var route: Screen?
    
    var headerHeight: CGFloat {
        if isAlgoDisplay {
            return AssetDetailView.LayoutConstants.algosHeaderHeight
        }
        return AssetDetailView.LayoutConstants.assetHeaderHeight
    }
    
    private(set) lazy var assetDetailView = AssetDetailView()
    
    private lazy var emptyStateView = EmptyStateView(
        image: img("icon-transactions-empty"),
        title: "accounts-tranaction-empty-text".localized,
        subtitle: "accounts-tranaction-empty-detail".localized
    )
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(didRefreshList), for: .valueChanged)
        return refreshControl
    }()
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        transactionHistoryDataSource.setupContacts()
        fetchTransactions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchDollarConversion()
        startPendingTransactionPolling()
        handleDeepLinkRoutingIfNeeded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        pollingOperation?.invalidate()
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        assetDetailView.transactionHistoryCollectionView.refreshControl = refreshControl
        viewModel.configure(assetDetailView.headerView, with: account, and: assetDetail)
    }
    
    override func linkInteractors() {
        assetDetailView.delegate = self
        assetDetailView.transactionHistoryCollectionView.delegate = self
        assetDetailView.transactionHistoryCollectionView.dataSource = transactionHistoryDataSource
    }
    
    override func setListeners() {
        super.setListeners()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didAccountUpdate(notification:)),
            name: .AccountUpdate,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didAccountUpdate(notification:)),
            name: .AuthenticatedUserUpdate,
            object: nil
        )
        
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
    }
    
    override func prepareLayout() {
        setupAssetDetaiViewLayout()
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
    private func handleDeepLinkRoutingIfNeeded() {
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
    
    fileprivate func updateLayout() {
        guard let account = session?.account(from: account.address) else {
            return
        }
        
        viewModel.configure(assetDetailView.headerView, with: account, and: assetDetail)
    }
    
    private func updateAccount() {
        transactionHistoryDataSource.clear()
        assetDetailView.transactionHistoryCollectionView.reloadData()
        assetDetailView.transactionHistoryCollectionView.contentState = .loading
        fetchTransactions()
        updateLayout()
    }
}

extension AssetDetailViewController {
    @objc
    private func didRefreshList() {
        transactionHistoryDataSource.clear()
        assetDetailView.transactionHistoryCollectionView.reloadData()
        fetchTransactions()
    }
    
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
            open(
                .sendAssetTransactionPreview(
                    account: account,
                    receiver: .initial,
                    assetDetail: assetDetail,
                    isMaxTransaction: false
                ),
                by: .push
            )
        }
    }
    
    func assetDetailViewDidTapReceiveButton(_ assetDetailView: AssetDetailView) {
        if isAlgoDisplay {
            open(.requestAlgosTransactionPreview(account: account), by: .push)
        } else {
            guard let assetDetail = assetDetail else {
                return
            }
            open(.requestAssetTransactionPreview(account: account, assetDetail: assetDetail), by: .push)
        }
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
        open(
            .rewardDetail(account: account),
            by: .customPresent(
                presentationStyle: .custom,
                transitionStyle: nil,
                transitioningDelegate: rewardsModalPresenter
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
        
        if transaction.from == account.address {
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
        return layout.current.headerSize
    }
}

extension AssetDetailViewController {
    private func setupAssetDetaiViewLayout() {
        view.addSubview(assetDetailView)
        
        assetDetailView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
        
        assetDetailView.transactionHistoryCollectionView.contentInset.top = headerHeight
    }
}

extension AssetDetailViewController {
    struct LayoutConstants: AdaptiveLayoutConstants {
        let transactionCellSize = CGSize(width: UIScreen.main.bounds.width, height: 72.0)
        let editAccountModalHeight: CGFloat = 158.0
        let headerSize = CGSize(width: UIScreen.main.bounds.width, height: 68.0)
    }
}
