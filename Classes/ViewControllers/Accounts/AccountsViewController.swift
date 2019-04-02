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
    
    private let viewModel = AccountsViewModel()
    
    private var transactionHistoryLayoutBuilder: TransactionHistoryLayoutBuilder
    private var transactionHistoryDataSource: TransactionHistoryDataSource
    
    // TODO: Will remove mock after real connection
    private let account = Account(address: "1")
    
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
        
        // TODO: Will remove mock after real connection
        account.amount = 123456789
        account.name = "Account Name"
        
        if let accountName = account.name {
            title = "\(accountName)".localized
        }
        
        viewModel.configure(accountsView.accountsHeaderView, with: account)
        
        accountsView.transactionHistoryCollectionView.contentState = .loading
        transactionHistoryDataSource.setupMockData()
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
        open(
            .accountList,
            by: .customPresent(
                presentationStyle: .custom,
                transitionStyle: nil,
                transitioningDelegate: accountListModalPresenter
            )
        )
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
