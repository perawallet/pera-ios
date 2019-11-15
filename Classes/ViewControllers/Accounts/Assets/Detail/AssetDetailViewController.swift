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
    
    struct LayoutConstants: AdaptiveLayoutConstants {
        let optionsModalHeight: CGFloat = 348.0
        let transactionCellSize = CGSize(width: UIScreen.main.bounds.width, height: 72.0)
        let rewardCellSize = CGSize(width: UIScreen.main.bounds.width, height: 50.0)
        let editAccountModalHeight: CGFloat = 158.0
    }
    
    let layout = Layout<LayoutConstants>()
    
    private lazy var pushNotificationController: PushNotificationController = {
        guard let api = api else {
            fatalError("Api must be set before accessing this view controller.")
        }
        return PushNotificationController(api: api)
    }()
    
    private var pollingOperation: PollingOperation?
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(didRefreshList), for: .valueChanged)
        return refreshControl
    }()
    
    private lazy var fadeTextAnimation: CATransition = {
        let animation = CATransition()
        animation.duration = 0.5
        animation.type = .fade
        return animation
    }()
    
    var selectedAccount: Account? {
        didSet {
            session?.currentAccount = self.selectedAccount
        }
    }
    
    var newAccount: Account? {
        didSet {
            guard let account = newAccount else {
                return
            }
            
            updateSelectedAccount(account)
        }
    }
    
    private var currentDollarConversion: Double?
    private let viewModel = AssetDetailViewModel()
    
    private var transactionHistoryDataSource: TransactionHistoryDataSource
    
    var route: Screen?
    
    // MARK: Components
    
    private lazy var assetDetailView: AssetDetailView = {
        let view = AssetDetailView()
        return view
    }()
    
    private lazy var emptyStateView = EmptyStateView(
        title: "accounts-tranaction-empty-text".localized,
        topImage: img("icon-transaction-empty-blue"),
        bottomImage: img("icon-transaction-empty-orange"),
        alignment: .bottom
    )
    
    // MARK: Initialization
    
    override init(configuration: ViewControllerConfiguration) {
        transactionHistoryDataSource = TransactionHistoryDataSource(api: configuration.api)
        
        super.init(configuration: configuration)
    }
    
    deinit {
        pollingOperation?.invalidate()
    }
    
    override func linkInteractors() {
        assetDetailView.delegate = self
        assetDetailView.transactionHistoryCollectionView.delegate = self
        assetDetailView.transactionHistoryCollectionView.dataSource = transactionHistoryDataSource
        assetDetailView.delegate = self
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        
        view.backgroundColor = .white
        
        assetDetailView.transactionHistoryCollectionView.refreshControl = refreshControl
        
        guard let account = selectedAccount else {
            return
        }
        
        self.navigationItem.title = selectedAccount?.name
        
        viewModel.configure(assetDetailView.headerView, with: account)
        viewModel.configure(assetDetailView.smallHeaderView, with: account)
        
        transactionHistoryDataSource.setupContacts()
        
        fetchTransactions()
        
        pushNotificationController.requestAuthorization()
        pushNotificationController.registerDevice()
    }
    
    private func addTitleFadeAnimation() {
        navigationController?.navigationBar.layer.add(fadeTextAnimation, forKey: "fadeText")
    }
    
    override func setListeners() {
        super.setListeners()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didUpdateAuthenticatedUser(notification:)),
            name: Notification.Name.AuthenticatedUserUpdate,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didApplicationWillEnterForeground(notification:)),
            name: Notification.Name.ApplicationWillEnterForeground,
            object: nil
        )
        
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
    
    // MARK: Layout
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchDollarConversion()
        
        DispatchQueue.main.async {
            UIApplication.shared.appDelegate?.validateAccountManagerFetchPolling()
        }
        
        startPendingTransactionPolling()
    
        newAccount = nil
        
        if let route = route {
            switch route {
            case let .assetDetail(account):
                self.route = nil
                self.updateSelectedAccount(account)
            default:
                self.route = nil
                open(route, by: .push, animated: false)
            }
        }
    }
    
    private func startPendingTransactionPolling() {
        pollingOperation = PollingOperation(interval: 0.8) { [weak self] in
            guard let strongSelf = self,
                let account = strongSelf.selectedAccount else {
                return
            }
            
            strongSelf.transactionHistoryDataSource.fetchPendingTransactions(for: account) { pendingTransactions, error in
                if error != nil {
                    return
                }
                
                guard let pendingTransactions = pendingTransactions, !pendingTransactions.isEmpty else {
                    return
                }
                
                strongSelf.accountsView.transactionHistoryCollectionView.contentState = .none
                strongSelf.accountsView.transactionHistoryCollectionView.reloadData()
            }
        }
        
        pollingOperation?.start()
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        DispatchQueue.main.async {
            UIApplication.shared.appDelegate?.invalidateAccountManagerFetchPolling()
        }
        
        pollingOperation?.invalidate()
    }
    
    override func prepareLayout() {
        setupAssetDetaiViewLayout()
    }
    
    private func setupAssetDetaiViewLayout() {
        view.addSubview(assetDetailView)
        
        assetDetailView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func fetchTransactions(witRefresh refresh: Bool = true) {
        guard let account = selectedAccount else {
            return
        }
        
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
    
    @objc
    private func didRefreshList() {
        transactionHistoryDataSource.clear()
        assetDetailView.transactionHistoryCollectionView.reloadData()
        fetchTransactions()
    }
}

// MARK: - Helpers
extension AssetDetailViewController {
    fileprivate func updateLayout() {
        guard let address = selectedAccount?.address,
            let account = session?.authenticatedUser?.account(address: address) else {
            return
        }
        
        self.navigationItem.title = account.name
        
        viewModel.configure(assetDetailView.headerView, with: account)
        viewModel.configure(assetDetailView.smallHeaderView, with: account)
    }
}

// MARK: - Notification
extension AssetDetailViewController {
    @objc
    fileprivate func didUpdateAuthenticatedUser(notification: Notification) {
        updateLayout()
    }
    
    @objc
    fileprivate func didApplicationWillEnterForeground(notification: Notification) {
        DispatchQueue.main.async {
            UIApplication.shared.appDelegate?.validateAccountManagerFetchPolling()
        }
    }
    
    @objc
    fileprivate func didAccountUpdate(notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: Account],
            let account = userInfo["account"] else {
            return
        }
        
        if selectedAccount == account {
            self.selectedAccount = account
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

// MARK: AccountSelectionViewControllerDelegate

extension AssetDetailViewController: AccountSelectionViewControllerDelegate {
    
    func accountSelectionViewController(_ accountSelectionViewController: AccountSelectionViewController, didSelect account: Account) {
        updateSelectedAccount(account)
    }
    
    func updateSelectedAccount(_ account: Account) {
        selectedAccount = account
        
        transactionHistoryDataSource.clear()
        assetDetailView.transactionHistoryCollectionView.reloadData()
        assetDetailView.transactionHistoryCollectionView.contentState = .loading
        
        fetchTransactions()
        
        adjustDefaultHeaderViewLayout(withContentInsetUpdate: true)
        
        addTitleFadeAnimation()
        
        updateLayout()
    }
    
    func accountSelectionViewControllerDidTapAddAccount(_ accountSelectionViewController: AccountSelectionViewController) {
        if let account = selectedAccount {
            accountSelectionViewController.configure(selected: account)
        }
        
        open(
            .introduction(mode: .new),
            by: .customPresent(presentationStyle: .fullScreen, transitionStyle: nil, transitioningDelegate: nil)
        )
    }
}

// MARK: AssetDetailViewDelegate

extension AssetDetailViewController: AssetDetailViewDelegate {
    func assetDetailViewDidTapSendButton(_ assetDetailView: AssetDetailView) {
        guard let account = selectedAccount else {
            return
        }
        
        open(.sendAlgos(account: account, receiver: .initial), by: .push)
    }
    
    func assetDetailViewDidTapReceiveButton(_ assetDetailView: AssetDetailView) {
        guard let account = selectedAccount else {
            return
        }
        
        open(.requestAlgos(account: account), by: .push)
    }
    
    func assetDetailView(_ assetDetailView: AssetDetailView, didTrigger dollarValueGestureRecognizer: UILongPressGestureRecognizer) {
        guard let currentDollarAmount = currentDollarConversion,
            let selectedAccount = selectedAccount else {
                return
        }
        
        let dollarAmountForAccount = selectedAccount.amount.toAlgos * currentDollarAmount
        
        if dollarValueGestureRecognizer.state != .ended {
            viewModel.setDollarValue(visible: true, in: assetDetailView.headerView, for: dollarAmountForAccount)
        } else {
            viewModel.setDollarValue(visible: false, in: assetDetailView.headerView, for: dollarAmountForAccount)
        }
    }
    
    func assetDetailViewDidTapRewardView(_ assetDetailView: AssetDetailView) {
        guard let selectedAccount = selectedAccount else {
            return
        }
        
        let viewController = RewardDetailViewController(account: selectedAccount, configuration: configuration)
        viewController.modalPresentationStyle = .overCurrentContext
        viewController.modalTransitionStyle = .crossDissolve
        
        tabBarController?.present(viewController, animated: true, completion: nil)
    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension AssetDetailViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let transaction = transactionHistoryDataSource.transaction(at: indexPath),
            let account = selectedAccount else {
                return
        }
        
        if let payment = transaction.payment,
            payment.toAddress == account.address {
            
            open(.transactionDetail(account: account, transaction: transaction, transactionType: .received), by: .push)
        } else {
            open(.transactionDetail(account: account, transaction: transaction, transactionType: .sent), by: .push)
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if transactionHistoryDataSource.transactionCount() == 0 {
            return
        }
        
        let translation = scrollView.panGestureRecognizer.translation(in: view)
        
        if translation.y < 0 {
            let offset = scrollView.contentOffset.y + AssetDetailView.LayoutConstants.headerHeight
            
            let offsetDifference = AssetDetailView.LayoutConstants.headerHeight - offset
            
            if offsetDifference <= AssetDetailView.LayoutConstants.smallHeaderHeight {
                adjustSmallHeaderViewLayout()
                
                assetDetailView.transactionHistoryCollectionView.contentInset.top = AssetDetailView.LayoutConstants.smallHeaderHeight
            } else {
                assetDetailView.accountsHeaderContainerView.snp.updateConstraints { make in
                    make.height.equalTo(offsetDifference)
                }
                
                assetDetailView.transactionHistoryCollectionView.contentInset.top = offsetDifference
                
                let progress: CGFloat = offsetDifference / AssetDetailView.LayoutConstants.headerHeight
                
                UIView.animate(withDuration: 0.0) {
                    self.assetDetailView.headerView.alpha = progress
                    self.view.layoutIfNeeded()
                }
            }
        } else {
            let offset = -scrollView.contentOffset.y
            
            let offsetTotal = AssetDetailView.LayoutConstants.smallHeaderHeight + offset
            
            if offsetTotal >= AssetDetailView.LayoutConstants.headerHeight {
                adjustDefaultHeaderViewLayout()
                
                assetDetailView.transactionHistoryCollectionView.contentInset.top = AssetDetailView.LayoutConstants.headerHeight
            } else {
                let offset = max(-scrollView.contentOffset.y, AssetDetailView.LayoutConstants.smallHeaderHeight)
                
                let progress: CGFloat = offset / AssetDetailView.LayoutConstants.headerHeight
                
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
            let offset = scrollView.contentOffset.y + AssetDetailView.LayoutConstants.headerHeight
            
            let offsetDifference = AssetDetailView.LayoutConstants.headerHeight - offset
            
            if offsetDifference <= AssetDetailView.LayoutConstants.smallHeaderHeight {
                return
            }
            
            adjustSmallHeaderViewLayout(withContentInsetUpdate: true)
            
        } else {
            let offset = scrollView.contentInset.top + scrollView.contentOffset.y + AssetDetailView.LayoutConstants.smallHeaderHeight
            
            if offset > AssetDetailView.LayoutConstants.headerHeight {
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
            make.height.equalTo(AssetDetailView.LayoutConstants.headerHeight)
        }
        
        UIView.animate(withDuration: 0.33) {
            self.assetDetailView.smallHeaderView.alpha = 0.0
            self.assetDetailView.headerView.alpha = 1.0
            
            if shouldUpdateContentInset {
                self.assetDetailView.transactionHistoryCollectionView.contentInset.top = AssetDetailView.LayoutConstants.headerHeight
                self.assetDetailView.transactionHistoryCollectionView.contentOffset.y = -AssetDetailView.LayoutConstants.headerHeight
            }
            
            self.view.layoutIfNeeded()
        }
    }
}
