//
//  AccountListViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 27.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AccountListViewController: BaseViewController {
    
    // MARK: Components
    
    private lazy var accountListView: AccountListView = {
        let view = AccountListView()
        return view
    }()
    
    override var shouldShowNavigationBar: Bool {
        return false
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
        
    }
    
    func accountListViewDidTapAddButton(_ accountListView: AccountListView) {
        
    }
}
