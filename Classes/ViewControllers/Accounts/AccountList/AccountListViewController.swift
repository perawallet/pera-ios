//
//  AccountListViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 27.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol AccountListViewControllerDelegate: class {
    func accountListViewControllerDidTapAddButton(_ viewController: AccountListViewController)
    func accountListViewController(_ viewController: AccountListViewController,
                                   didSelectAccount account: Account)
}

enum AccountListMode {
    case onlyList
    case addable
}

class AccountListViewController: BaseViewController {
    
    // MARK: Components
    
    private lazy var accountListView: AccountListView = {
        let view = AccountListView(mode: mode)
        view.delegate = self
        return view
    }()
    
    override var shouldShowNavigationBar: Bool {
        return false
    }

    weak var delegate: AccountListViewControllerDelegate?
    
    private let mode: AccountListMode
    
    // MARK: Initialization
    
    init(mode: AccountListMode, configuration: ViewControllerConfiguration) {
        self.mode = mode
        
        super.init(configuration: configuration)
    }
    
    // MARK: Setup
    
    override func configureAppearance() {
        view.backgroundColor = .white
    }
    
    override func prepareLayout() {
        view.addSubview(accountListView)
        
        accountListView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.bottom.safeEqualToBottom(of: self)
        }
    }
}

// MARK: AccountListViewDelegate

extension AccountListViewController: AccountListViewDelegate {
    
    func accountListView(_ accountListView: AccountListView, didSelect account: Account) {
        dismissScreen()
        
        delegate?.accountListViewController(self, didSelectAccount: account)
    }
    
    func accountListViewDidTapAddButton(_ accountListView: AccountListView) {
        dismissScreen()
        
        delegate?.accountListViewControllerDidTapAddButton(self)
    }
}
