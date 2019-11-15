//
//  AccountsViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 11.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AccountsViewController: BaseViewController {
    
    let layout = Layout<LayoutConstants>()
    
    private lazy var optionsModalPresenter = CardModalPresenter(
        config: ModalConfiguration(
            animationMode: .normal(duration: 0.25),
            dismissMode: .scroll
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
    
    private lazy var accountsView = AccountsView()
    
    private(set) var selectedAccount: Account?
    private(set) var localAuthenticator = LocalAuthenticator()
    
    private var accountsLayoutBuilder: AccountsLayoutBuilder
    private var accountsDataSource: AccountsDataSource
    
    override init(configuration: ViewControllerConfiguration) {
        accountsLayoutBuilder = AccountsLayoutBuilder()
        accountsDataSource = AccountsDataSource()
        super.init(configuration: configuration)
    }
    
    override func configureNavigationBarAppearance() {
        let addAccountBarButtonItem = ALGBarButtonItem(kind: .add) { [unowned self] in
        }
        
        rightBarButtonItems = [addAccountBarButtonItem]
    }
    
    override func setListeners() {
        accountsLayoutBuilder.delegate = self
        accountsDataSource.delegate = self
    }
    
    override func prepareLayout() {
        setupAccountsViewLayout()
    }
}

extension AccountsViewController {
    private func setupAccountsViewLayout() {
        view.addSubview(accountsView)
        
        accountsView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension AccountsViewController: AccountsLayoutBuilderDelegate {
    func accountsLayoutBuilder(_ layoutBuilder: AccountsLayoutBuilder, didSelectAt indexPath: IndexPath) {
        
    }
}

extension AccountsViewController: AccountsDataSourceDelegate {
    func accountsDataSource(_ accountsDataSource: AccountsDataSource, didTapOptionsButtonFor account: Account) {
        presentOptions()
    }
    
    func accountsDataSource(_ accountsDataSource: AccountsDataSource, didTapAddAssetButtonFor account: Account) {
        
    }
}

extension AccountsViewController {
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

extension AccountsViewController {
    struct LayoutConstants: AdaptiveLayoutConstants {
        let optionsModalHeight: CGFloat = 348.0
        let transactionCellSize = CGSize(width: UIScreen.main.bounds.width, height: 72.0)
        let rewardCellSize = CGSize(width: UIScreen.main.bounds.width, height: 50.0)
        let editAccountModalHeight: CGFloat = 158.0
    }
}
