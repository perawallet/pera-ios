//
//  AccountsViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 26.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AccountsViewController: BaseViewController {
    
    struct LayoutConstants: AdaptiveLayoutConstants {
        let optionsModalHeight: CGFloat = 348.0
        let editAccountModalHeight: CGFloat = 158.0
    }
    
    let layout = Layout<LayoutConstants>()
    
    // MARK: Variables
    
    private lazy var accountListModalPresenter = CardModalPresenter(
        config: ModalConfiguration(
            animationMode: .normal(duration: 0.25),
            dismissMode: .backgroundTouch
        )
    )
    
    private lazy var optionsModalPresenter = CardModalPresenter(
        config: ModalConfiguration(
            animationMode: .normal(duration: 0.25),
            dismissMode: .backgroundTouch
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
    
    private(set) var localAuthenticator = LocalAuthenticator()
    
    var selectedAccount: Account?
    
    var newAccount: Account? {
        didSet {
            guard let account = newAccount else {
                return
            }
            
            selectedAccount = account
            
            transactionHistoryDataSource.clear()
            accountsView.transactionHistoryCollectionView.reloadData()
            accountsView.transactionHistoryCollectionView.contentState = .loading
            
            fetchTransactions()
            
            adjustDefaultHeaderViewLayout()
            
            updateLayout()
        }
    }
    
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
        topImage: img("icon-transaction-empty-green"),
        bottomImage: img("icon-transaction-empty-blue"),
        alignment: .bottom
    )
    
    // MARK: Initialization
    
    override init(configuration: ViewControllerConfiguration) {
        transactionHistoryDataSource = TransactionHistoryDataSource(api: configuration.api)
        
        super.init(configuration: configuration)
    }
    
    // MARK: Setup
    
    override func configureNavigationBarAppearance() {
        let accountListBarButtonItem = ALGBarButtonItem(kind: .menu) { [unowned self] in
            self.presentAccountList()
        }
        
        let optionsBarButtonItem = ALGBarButtonItem(kind: .options) { [unowned self] in
            self.presentOptions()
        }
        
        leftBarButtonItems = [accountListBarButtonItem]
        rightBarButtonItems = [optionsBarButtonItem]
    }
    
    override func linkInteractors() {
        accountsView.delegate = self
        accountsView.transactionHistoryCollectionView.delegate = self
        accountsView.transactionHistoryCollectionView.dataSource = transactionHistoryDataSource
        accountsView.delegate = self
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        
        view.backgroundColor = .white
        
        selectedAccount = session?.authenticatedUser?.defaultAccount()
        
        guard let account = selectedAccount else {
            return
        }
        
        self.navigationItem.title = selectedAccount?.name
        
        viewModel.configure(accountsView.accountsHeaderView, with: account)
        viewModel.configure(accountsView.accountsSmallHeaderView, with: account)
        
        transactionHistoryDataSource.setupContacts()
        
        fetchTransactions()
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
    }
    
    // MARK: Layout
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.main.async {
            UIApplication.shared.appDelegate?.validateAccountManagerFetchPolling()
        }
    
        newAccount = nil
        
        if let route = route {
            self.route = nil
            
            open(route, by: .push, animated: false)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        DispatchQueue.main.async {
            UIApplication.shared.appDelegate?.invalidateAccountManagerFetchPolling()
        }
    }
    
    override func prepareLayout() {
        setupAccountsViewLayout()
    }
    
    private func setupAccountsViewLayout() {
        view.addSubview(accountsView)
        
        accountsView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func fetchTransactions(witRefresh refresh: Bool = true) {
        guard let account = selectedAccount else {
            return
        }
        
        accountsView.transactionHistoryCollectionView.contentState = .loading
        
        transactionHistoryDataSource.loadData(for: account, withRefresh: refresh) { transactions, error in
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
}

// MARK: Navigation Actions

extension AccountsViewController {
    
    private func presentAccountList() {
        let accountListViewController = open(
            .accountList(mode: .addable),
            by: .customPresent(
                presentationStyle: .custom,
                transitionStyle: nil,
                transitioningDelegate: accountListModalPresenter
            )
        ) as? AccountListViewController
        
        accountListViewController?.delegate = self
    }
    
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
        
        if selectedAccount == account {
            transactionHistoryDataSource.clear()
            accountsView.transactionHistoryCollectionView.reloadData()
            accountsView.transactionHistoryCollectionView.contentState = .loading
            
            fetchTransactions()
        }
    }
    
    @objc
    fileprivate func didContactAdded(notification: Notification) {
        transactionHistoryDataSource.setupContacts()
    }
}

// MARK: AccountListViewControllerDelegate
extension AccountsViewController: AccountListViewControllerDelegate {
    func accountListViewControllerDidTapAddButton(_ viewController: AccountListViewController) {
        open(.introduction(mode: .new), by: .present)
    }
    
    func accountListViewController(_ viewController: AccountListViewController, didSelectAccount account: Account) {
        selectedAccount = account
        
        transactionHistoryDataSource.clear()
        accountsView.transactionHistoryCollectionView.reloadData()
        accountsView.transactionHistoryCollectionView.contentState = .loading
        
        fetchTransactions()
        
        adjustDefaultHeaderViewLayout()
        
        updateLayout()
    }
}

// MARK: AccountsViewDelegate

extension AccountsViewController: AccountsViewDelegate {
    
    func accountsViewDidTapSendButton(_ accountsView: AccountsView) {
        open(.sendAlgos(receiver: .initial), by: .push)
    }
    
    func accountsViewDidTapReceiveButton(_ accountsView: AccountsView) {
        open(.receiveAlgos, by: .push)
    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension AccountsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let transaction = transactionHistoryDataSource.transaction(at: indexPath) else {
            return
        }
        
        open(.transactionDetail(transaction: transaction), by: .push)
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
                
                let heightDifference = AccountsView.LayoutConstants.headerHeight - AccountsView.LayoutConstants.smallHeaderHeight
                
                UIView.animate(withDuration: 0.33) {
                    self.accountsView.accountsHeaderView.alpha = 1.0 - (heightDifference / offsetDifference)
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
                accountsView.accountsHeaderContainerView.snp.updateConstraints { make in
                    make.height.equalTo(offsetTotal)
                }
                
                accountsView.transactionHistoryCollectionView.contentInset.top = offsetTotal
                
                UIView.animate(withDuration: 0.33) {
                    self.accountsView.accountsHeaderView.alpha = 1.0 - (offsetTotal / AccountsView.LayoutConstants.headerHeight)
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    private func adjustSmallHeaderViewLayout() {
        accountsView.accountsHeaderContainerView.snp.updateConstraints { make in
            make.height.equalTo(AccountsView.LayoutConstants.smallHeaderHeight)
        }
        
        UIView.animate(withDuration: 0.33) {
            self.accountsView.accountsHeaderView.alpha = 0.0
            self.accountsView.accountsSmallHeaderView.alpha = 1.0
            self.view.layoutIfNeeded()
        }
    }
    
    private func adjustDefaultHeaderViewLayout() {
        accountsView.accountsHeaderContainerView.snp.updateConstraints { make in
            make.height.equalTo(AccountsView.LayoutConstants.headerHeight)
        }
        
        UIView.animate(withDuration: 0.33) {
            self.accountsView.accountsSmallHeaderView.alpha = 0.0
            self.accountsView.accountsHeaderView.alpha = 1.0
            self.view.layoutIfNeeded()
        }
    }
}
