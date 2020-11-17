//
//  AccountListViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 27.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

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
        view.backgroundColor = Colors.Background.secondary
        
        switch mode {
        case .contact,
             .transactionSender:
            accountListView.titleLabel.text = "send-sending-algos-select".localized
        case .transactionReceiver:
            accountListView.titleLabel.text = "send-receiving-algos-select".localized
        default:
            accountListView.titleLabel.text = "send-algos-select".localized
        }
    }
    
    override func setListeners() {
        accountListLayoutBuilder.delegate = self
        accountListView.delegate = self
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

extension AccountListViewController: AccountListViewDelegate {
    func accountListViewDidTapCancelButton(_ accountListView: AccountListView) {
        dismissScreen()
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
        case empty
        case assetCount
        case contact(assetDetail: AssetDetail?)
        case transactionReceiver(assetDetail: AssetDetail?)
        case transactionSender(assetDetail: AssetDetail?)
    }
}

protocol AccountListViewControllerDelegate: class {
    func accountListViewController(_ viewController: AccountListViewController, didSelectAccount account: Account)
}
