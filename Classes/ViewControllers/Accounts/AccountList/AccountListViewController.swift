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

class AccountListViewController: BaseViewController {
    
    // MARK: Components
    
    private lazy var accountListView: AccountListView = {
        let view = AccountListView()
        view.delegate = self
        return view
    }()
    
    weak var delegate: AccountListViewControllerDelegate?
    
    // MARK: Setup
    
    override func configureAppearance() {
        view.backgroundColor = .white
    }
    
    override func prepareLayout() {
        view.addSubview(accountListView)
        
        accountListView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
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
