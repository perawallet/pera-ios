//
//  AccountListViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 27.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol AccountListViewControllerDelegate: class {
    func accountListViewController(_ viewController: AccountListViewController, didSelectAccount account: Account)
}

class AccountListViewController: BaseViewController {
    
    override var shouldShowNavigationBar: Bool {
        return false
    }
    
    private lazy var accountListView = AccountListView()

    weak var delegate: AccountListViewControllerDelegate?
    
    private var accountListLayoutBuilder: AccountListLayoutBuilder
    private var accountListDataSource: AccountListDataSource
    private var mode: Mode
    
    init(mode: Mode, configuration: ViewControllerConfiguration) {
        self.mode = mode
        accountListLayoutBuilder = AccountListLayoutBuilder()
        accountListDataSource = AccountListDataSource(mode: mode)
        super.init(configuration: configuration)
    }
    
    override func configureAppearance() {
        view.backgroundColor = .white
    }
    
    override func setListeners() {
        accountListLayoutBuilder.delegate = self
        accountListView.accountsCollectionView.dataSource = accountListDataSource
        accountListView.accountsCollectionView.delegate = accountListLayoutBuilder
    }
    
    override func prepareLayout() {
        setupAccountListViewLayout()
    }
}

extension AccountListViewController {
    private func setupAccountListViewLayout() {
        view.addSubview(accountListView)
        
        accountListView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension AccountListViewController: AccountListLayoutBuilderDelegate {
    func accountListLayoutBuilder(_ layoutBuilder: AccountListLayoutBuilder, didSelectAt indexPath: IndexPath) {
        let accounts = accountListDataSource.accounts
        
        guard indexPath.item < accounts.count else {
            return
        }
        
        let account = accounts[indexPath.item]
        dismissScreen()
        delegate?.accountListViewController(self, didSelectAccount: account)
    }
}

extension AccountListViewController {
    enum Mode {
        case assetCount
        case amount(assetDetail: AssetDetail?)
    }
}
