//
//  AccountsViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 26.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AccountsViewController: BaseViewController {
    
    private lazy var cardModalPresenter = CardModalPresenter(
        config: ModalConfiguration(
            animationMode: .normal(duration: 0.25),
            dismissMode: .backgroundTouch
        )
    )
    
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
    
    override func configureAppearance() {
        super.configureAppearance()
        
        view.backgroundColor = .white
        
        // TODO: Should be updated with selected or default account
        title = "Account Name".localized
    }
    
    // MARK: Navigation Actions
    
    private func presentAccountList() {
        open(.accountList, by: .customPresent(presentationStyle: .custom, transitionStyle: nil, transitioningDelegate: cardModalPresenter))
    }
    
    private func presentOptions() {
        open(.options, by: .customPresent(presentationStyle: .custom, transitionStyle: nil, transitioningDelegate: cardModalPresenter))
    }
}
