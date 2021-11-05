// Copyright 2019 Algorand, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//  AccountListViewController.swift

import UIKit

final class AccountListViewController: BaseViewController {
    weak var delegate: AccountListViewControllerDelegate?

    override var shouldShowNavigationBar: Bool {
        return false
    }

    private lazy var theme = Theme()
    private lazy var accountListView = AccountListView()
    
    private lazy var accountListLayoutBuilder = AccountListLayoutBuilder(theme: theme)
    private lazy var accountListDataSource = AccountListDataSource(mode: mode)
    private var mode: Mode
    
    init(mode: Mode, configuration: ViewControllerConfiguration) {
        self.mode = mode
        super.init(configuration: configuration)
    }
    
    override func configureAppearance() {
        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        updateContentStateView()
    }
    
    override func setListeners() {
        accountListLayoutBuilder.delegate = self
        accountListView.accountsCollectionView.dataSource = accountListDataSource
        accountListView.accountsCollectionView.delegate = accountListLayoutBuilder
    }

    override func bindData() {
        super.bindData()
        accountListView.bindData(AccountListViewModel(mode))
    }
    
    override func prepareLayout() {
        accountListView.customize(theme.accountListViewTheme)
        view.addSubview(accountListView)
        accountListView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension AccountListViewController {
    private func updateContentStateView() {
        accountListView.updateContentStateView(isEmpty: accountListDataSource.accounts.isEmpty)
    }
}

extension AccountListViewController: AccountListLayoutBuilderDelegate {
    func accountListLayoutBuilder(_ layoutBuilder: AccountListLayoutBuilder, didSelectAt indexPath: IndexPath) {
        let accounts = accountListDataSource.accounts
        
        guard indexPath.item < accounts.count else {
            return
        }
        
        let account = accounts[indexPath.item]
        delegate?.accountListViewController(self, didSelectAccount: account)
    }
}

extension AccountListViewController {
    enum Mode {
        case walletConnect
        case contact(assetDetail: AssetDetail?)
        case transactionReceiver(assetDetail: AssetDetail?)
        case transactionSender(assetDetail: AssetDetail?)
    }
}

protocol AccountListViewControllerDelegate: AnyObject {
    func accountListViewController(_ viewController: AccountListViewController, didSelectAccount account: Account)
}
