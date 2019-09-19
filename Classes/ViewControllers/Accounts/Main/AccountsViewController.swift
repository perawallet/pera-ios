//
//  AccountsViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 26.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit
import NotificationBannerSwift

class AccountsViewController: BaseViewController {
    
    struct LayoutConstants: AdaptiveLayoutConstants {
        let optionsModalHeight: CGFloat = 348.0
        let transactionCellSize = CGSize(width: UIScreen.main.bounds.width, height: 72.0)
        let rewardCellSize = CGSize(width: UIScreen.main.bounds.width, height: 50.0)
        let editAccountModalHeight: CGFloat = 158.0
    }
    
    let layout = Layout<LayoutConstants>()
    
    // MARK: Variables
    
    private lazy var optionsModalPresenter = CardModalPresenter(
        config: ModalConfiguration(
            animationMode: .normal(duration: 0.25),
            dismissMode: .scroll
        ),
        initialModalSize: .custom(CGSize(width: view.frame.width, height: layout.current.optionsModalHeight))
    )
    
    private(set) lazy var editAccountModalPresenter = CardModalPresenter(
        config: ModalConfiguration(
            animationMode: .normal(duration: 0.25),
            dismissMode: .backgroundTouch
        ),
        initialModalSize: .custom(CGSize(width: view.frame.width, height: layout.current.editAccountModalHeight))
    )
    
    private lazy var pushNotificationController: PushNotificationController = {
        guard let api = api else {
            fatalError("Api must be set before accessing this view controller.")
        }
        return PushNotificationController(api: api)
    }()
    
    private var pollingOperation: PollingOperation?
    
    private(set) lazy var accountSelectionViewController = AccountSelectionViewController(configuration: configuration)
    
    private(set) var localAuthenticator = LocalAuthenticator()
    
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
            if let account = selectedAccount {
                accountSelectionViewController.configure(selected: account)
            }
            session?.currentAccount = self.selectedAccount
        }
    }
    
    var newAccount: Account? {
        didSet {
            guard let account = newAccount else {
                return
            }
            
            accountSelectionViewController.selectedAccount = account
            accountSelectionViewController.accountsCollectionView.reloadData()
            updateSelectedAccount(account)
        }
    }
    
    private var currentDollarConversion: Double?
    private let viewModel = AccountsViewModel()
    
    private var transactionHistoryDataSource: TransactionHistoryDataSource
    
    var route: Screen?
    
    // MARK: Components
    
    private lazy var accountsView: AccountsView = {
        let view = AccountsView()
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
    
    // MARK: Setup
    
    override func configureNavigationBarAppearance() {
        let optionsBarButtonItem = ALGBarButtonItem(kind: .options) { [unowned self] in
            self.presentOptions()
        }
        
        rightBarButtonItems = [optionsBarButtonItem]
    }
    
    override func linkInteractors() {
        accountsView.delegate = self
        accountsView.transactionHistoryCollectionView.delegate = self
        accountsView.transactionHistoryCollectionView.dataSource = transactionHistoryDataSource
        accountsView.delegate = self
        accountSelectionViewController.delegate = self
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        
        view.backgroundColor = .white
        
        accountsView.transactionHistoryCollectionView.refreshControl = refreshControl
        selectedAccount = session?.authenticatedUser?.defaultAccount()
        
        guard let account = selectedAccount else {
            return
        }
        
        self.navigationItem.title = selectedAccount?.name
        
        viewModel.configure(accountsView.accountsHeaderView, with: account)
        viewModel.configure(accountsView.accountsSmallHeaderView, with: account)
        
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
            case let .accounts(account):
                self.route = nil
                accountSelectionViewController.selectedAccount = account
                accountSelectionViewController.accountsCollectionView.reloadData()
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
            
            strongSelf.transactionHistoryDataSource.fetchPendingTransactions(for: account) { _, error in
                if error != nil {
                    return
                }
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
        addChild(accountSelectionViewController)
        view.addSubview(accountSelectionViewController.view)
        
        accountSelectionViewController.view.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        
        accountSelectionViewController.didMove(toParent: self)
        
        setupAccountsViewLayout()
    }
    
    private func setupAccountsViewLayout() {
        view.addSubview(accountsView)
        
        accountsView.snp.makeConstraints { make in
            make.top.equalTo(accountSelectionViewController.view.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func fetchTransactions(witRefresh refresh: Bool = true) {
        guard let account = selectedAccount else {
            return
        }
        
        if !refreshControl.isRefreshing {
            accountsView.transactionHistoryCollectionView.contentState = .loading
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
                    self.accountsView.transactionHistoryCollectionView.contentState = .empty(self.emptyStateView)
                }
                
                self.accountsView.transactionHistoryCollectionView.reloadData()
                return
            }
            
            guard let transactions = transactions else {
                self.accountsView.transactionHistoryCollectionView.contentState = .none
                return
            }
            
            if transactions.isEmpty {
                self.accountsView.transactionHistoryCollectionView.contentState = .empty(self.emptyStateView)
                return
            }
            
            self.accountsView.transactionHistoryCollectionView.contentState = .none
            self.accountsView.transactionHistoryCollectionView.reloadData()
        }
    }
    
    @objc
    private func didRefreshList() {
        transactionHistoryDataSource.clear()
        accountsView.transactionHistoryCollectionView.reloadData()
        fetchTransactions()
    }
}

// MARK: Navigation Actions

extension AccountsViewController {
    
    private func presentOptions() {
        let transitionStyle = Screen.Transition.Open.customPresent(
            presentationStyle: .custom,
            transitionStyle: nil,
            transitioningDelegate: optionsModalPresenter
        )
        
        let optionsViewController = open(.options, by: transitionStyle) as? OptionsViewController
        
        optionsViewController?.delegate = self
    }
}

// MARK: - Helpers
extension AccountsViewController {
    fileprivate func updateLayout() {
        guard let address = selectedAccount?.address,
            let account = session?.authenticatedUser?.account(address: address) else {
            return
        }
        
        self.navigationItem.title = account.name
        
        viewModel.configure(accountsView.accountsHeaderView, with: account)
        viewModel.configure(accountsView.accountsSmallHeaderView, with: account)
    }
}

// MARK: - Notification
extension AccountsViewController {
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
        
        accountSelectionViewController.accountsCollectionView.reloadData()
        
        if selectedAccount == account {
            accountSelectionViewController.selectedAccount = account
            self.selectedAccount = account
            transactionHistoryDataSource.clear()
            accountsView.transactionHistoryCollectionView.reloadData()
            accountsView.transactionHistoryCollectionView.contentState = .loading
            
            fetchTransactions()
        }
    }
    
    @objc
    fileprivate func didContactAdded(notification: Notification) {
        transactionHistoryDataSource.setupContacts()
        
        accountsView.transactionHistoryCollectionView.reloadData()
    }
    
    @objc
    fileprivate func didContactEdited(notification: Notification) {
        transactionHistoryDataSource.setupContacts()
        
        accountsView.transactionHistoryCollectionView.reloadData()
    }
}

// MARK: AccountSelectionViewControllerDelegate

extension AccountsViewController: AccountSelectionViewControllerDelegate {
    
    func accountSelectionViewController(_ accountSelectionViewController: AccountSelectionViewController, didSelect account: Account) {
        updateSelectedAccount(account)
    }
    
    func updateSelectedAccount(_ account: Account) {
        selectedAccount = account
        
        transactionHistoryDataSource.clear()
        accountsView.transactionHistoryCollectionView.reloadData()
        accountsView.transactionHistoryCollectionView.contentState = .loading
        
        fetchTransactions()
        
        adjustDefaultHeaderViewLayout(withContentInsetUpdate: true)
        
        addTitleFadeAnimation()
        
        updateLayout()
    }
    
    func accountSelectionViewControllerDidTapAddAccount(_ accountSelectionViewController: AccountSelectionViewController) {
        if let account = selectedAccount {
            accountSelectionViewController.configure(selected: account)
        }
        
        open(.introduction(mode: .new), by: .present)
    }
}

// MARK: AccountsViewDelegate

extension AccountsViewController: AccountsViewDelegate {
    
    func accountsViewDidTapSendButton(_ accountsView: AccountsView) {
        guard let account = selectedAccount else {
            return
        }
        
        open(.sendAlgos(account: account, receiver: .initial), by: .push)
    }
    
    func accountsViewDidTapReceiveButton(_ accountsView: AccountsView) {
        guard let account = selectedAccount else {
            return
        }
        
        open(.requestAlgos(account: account), by: .push)
    }
    
    func accountsView(_ accountsView: AccountsView, didTrigger dollarValueGestureRecognizer: UILongPressGestureRecognizer) {
        guard let currentDollarAmount = currentDollarConversion,
            let selectedAccount = selectedAccount else {
                return
        }
        
        let dollarAmountForAccount = selectedAccount.amount.toAlgos * currentDollarAmount
        
        if dollarValueGestureRecognizer.state != .ended {
            viewModel.setDollarValue(visible: true, in: accountsView.accountsHeaderView, for: dollarAmountForAccount)
        } else {
            viewModel.setDollarValue(visible: false, in: accountsView.accountsHeaderView, for: dollarAmountForAccount)
        }
    }
    
    func accountsViewDidTapRewardView(_ accountsView: AccountsView) {
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

extension AccountsViewController: UICollectionViewDelegateFlowLayout {
    
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
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        if transactionHistoryDataSource.transactionCount() == indexPath.row - 3 {
//            fetchTransactions(witRefresh: false)
//        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if transactionHistoryDataSource.transactionCount() == 0 {
            return
        }
        
        let translation = scrollView.panGestureRecognizer.translation(in: view)
        
        if translation.y < 0 {
            let offset = scrollView.contentOffset.y + AccountsView.LayoutConstants.headerHeight
            
            let offsetDifference = AccountsView.LayoutConstants.headerHeight - offset
            
            if offsetDifference <= AccountsView.LayoutConstants.smallHeaderHeight {
                adjustSmallHeaderViewLayout()
                
                accountsView.transactionHistoryCollectionView.contentInset.top = AccountsView.LayoutConstants.smallHeaderHeight
            } else {
                accountsView.accountsHeaderContainerView.snp.updateConstraints { make in
                    make.height.equalTo(offsetDifference)
                }
                
                accountsView.transactionHistoryCollectionView.contentInset.top = offsetDifference
                
                let progress: CGFloat = offsetDifference / AccountsView.LayoutConstants.headerHeight
                
                UIView.animate(withDuration: 0.0) {
                    self.accountsView.accountsHeaderView.alpha = progress
                    self.view.layoutIfNeeded()
                }
            }
        } else {
            let offset = -scrollView.contentOffset.y
            
            let offsetTotal = AccountsView.LayoutConstants.smallHeaderHeight + offset
            
            if offsetTotal >= AccountsView.LayoutConstants.headerHeight {
                adjustDefaultHeaderViewLayout()
                
                accountsView.transactionHistoryCollectionView.contentInset.top = AccountsView.LayoutConstants.headerHeight
            } else {
                let offset = max(-scrollView.contentOffset.y, AccountsView.LayoutConstants.smallHeaderHeight)
                
                let progress: CGFloat = offset / AccountsView.LayoutConstants.headerHeight
                
                accountsView.accountsHeaderContainerView.snp.updateConstraints { make in
                    make.height.equalTo(offset)
                }
                
                accountsView.transactionHistoryCollectionView.contentInset.top = offset
                
                UIView.animate(withDuration: 0.33) {
                    self.accountsView.accountsHeaderView.alpha = progress
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
            let offset = scrollView.contentOffset.y + AccountsView.LayoutConstants.headerHeight
            
            let offsetDifference = AccountsView.LayoutConstants.headerHeight - offset
            
            if offsetDifference <= AccountsView.LayoutConstants.smallHeaderHeight {
                return
            }
            
            adjustSmallHeaderViewLayout(withContentInsetUpdate: true)
            
        } else {
            let offset = scrollView.contentInset.top + scrollView.contentOffset.y + AccountsView.LayoutConstants.smallHeaderHeight
            
            if offset > AccountsView.LayoutConstants.headerHeight {
                return
            }
            
            adjustDefaultHeaderViewLayout(withContentInsetUpdate: true)
        }
        
    }
    
    private func adjustSmallHeaderViewLayout(withContentInsetUpdate shouldUpdateContentInset: Bool = false) {
        accountsView.accountsHeaderContainerView.snp.updateConstraints { make in
            make.height.equalTo(AccountsView.LayoutConstants.smallHeaderHeight)
        }
        
        UIView.animate(withDuration: 0.33) {
            self.accountsView.accountsHeaderView.alpha = 0.0
            self.accountsView.accountsSmallHeaderView.alpha = 1.0
            
            if shouldUpdateContentInset {
                self.accountsView.transactionHistoryCollectionView.contentInset.top = AccountsView.LayoutConstants.smallHeaderHeight
                self.accountsView.transactionHistoryCollectionView.contentOffset.y = -AccountsView.LayoutConstants.smallHeaderHeight
            }
            
            self.view.layoutIfNeeded()
        }
    }
    
    private func adjustDefaultHeaderViewLayout(withContentInsetUpdate shouldUpdateContentInset: Bool = false) {
        accountsView.accountsHeaderContainerView.snp.updateConstraints { make in
            make.height.equalTo(AccountsView.LayoutConstants.headerHeight)
        }
        
        UIView.animate(withDuration: 0.33) {
            self.accountsView.accountsSmallHeaderView.alpha = 0.0
            self.accountsView.accountsHeaderView.alpha = 1.0
            
            if shouldUpdateContentInset {
                self.accountsView.transactionHistoryCollectionView.contentInset.top = AccountsView.LayoutConstants.headerHeight
                self.accountsView.transactionHistoryCollectionView.contentOffset.y = -AccountsView.LayoutConstants.headerHeight
            }
            
            self.view.layoutIfNeeded()
        }
    }
}
