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
    
    private let viewModel = AccountsViewModel()
    
    private var transactionHistoryLayoutBuilder: TransactionHistoryLayoutBuilder
    private var transactionHistoryDataSource: TransactionHistoryDataSource
    
    // MARK: Components
    
    private lazy var accountsView: AccountsView = {
        let view = AccountsView()
        return view
    }()
    
    private lazy var emptyStateView = EmptyStateView(
        title: "accounts-tranaction-empty-text".localized,
        topImage: img("icon-transaction-empty-green"),
        bottomImage: img("icon-transaction-empty-blue")
    )
    
    // MARK: Initialization
    
    override init(configuration: ViewControllerConfiguration) {
        transactionHistoryLayoutBuilder = TransactionHistoryLayoutBuilder()
        transactionHistoryDataSource = TransactionHistoryDataSource()
        
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
        transactionHistoryDataSource.delegate = self
        accountsView.transactionHistoryCollectionView.delegate = transactionHistoryLayoutBuilder
        accountsView.transactionHistoryCollectionView.dataSource = transactionHistoryDataSource
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
        
        accountsView.transactionHistoryCollectionView.contentState = .loading
        transactionHistoryDataSource.setupMockData()
    }
    
    override func setListeners() {
        super.setListeners()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didUpdateAuthenticatedUser(notification:)),
            name: Notification.Name.AuthenticatedUserUpdate,
            object: nil)
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupAccountsViewLayout()
    }
    
    private func setupAccountsViewLayout() {
        view.addSubview(accountsView)
        
        accountsView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
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
        guard let address = selectedAccount?.address else {
            return
        }
        
        let account = session?.authenticatedUser?.account(address: address)
        
        self.navigationItem.title = account?.name
    }
}

// MARK: - Notification
extension AccountsViewController {
    @objc
    fileprivate func didUpdateAuthenticatedUser(notification: Notification) {
        updateLayout()
    }
}

// MARK: AccountListViewControllerDelegate
extension AccountsViewController: AccountListViewControllerDelegate {
    func accountListViewControllerDidTapAddButton(_ viewController: AccountListViewController) {
        open(.introduction(mode: .new), by: .present)
    }
    
    func accountListViewController(_ viewController: AccountListViewController,
                                   didSelectAccount account: Account) {
        selectedAccount = account
        
        updateLayout()
    }
}

// MARK: TransactionHistoryDataSourceDelegate

extension AccountsViewController: TransactionHistoryDataSourceDelegate {
    
    func transactionHistoryDataSource(_ transactionHistoryDataSource: TransactionHistoryDataSource, didFetch transactions: [Transaction]) {
        if !transactions.isEmpty {
            accountsView.transactionHistoryCollectionView.contentState = .none
            return
        }

        accountsView.transactionHistoryCollectionView.contentState = .empty(emptyStateView)
    }
}
