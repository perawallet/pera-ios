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
    
    private lazy var pushNotificationController: PushNotificationController = {
        guard let api = api else {
            fatalError("Api must be set before accessing this view controller.")
        }
        return PushNotificationController(api: api)
    }()
    
    private lazy var accountsView = AccountsView()
    private lazy var refreshControl = UIRefreshControl()
    
    private(set) var selectedAccount: Account?
    private(set) var localAuthenticator = LocalAuthenticator()
    
    private var accountsLayoutBuilder: AccountsLayoutBuilder
    private var accountsDataSource: AccountsDataSource
    
    override init(configuration: ViewControllerConfiguration) {
        accountsLayoutBuilder = AccountsLayoutBuilder()
        accountsDataSource = AccountsDataSource()
        super.init(configuration: configuration)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didUpdateAuthenticatedUser(notification:)),
            name: Notification.Name.AuthenticatedUserUpdate,
            object: nil
        )
    }
    
    override func configureNavigationBarAppearance() {
        let addAccountBarButtonItem = ALGBarButtonItem(kind: .add) { [unowned self] in
            self.open(
                .introduction(mode: .new),
                by: .customPresent(presentationStyle: .fullScreen, transitionStyle: nil, transitioningDelegate: nil)
            )
        }
        
        rightBarButtonItems = [addAccountBarButtonItem]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async {
            UIApplication.shared.appDelegate?.validateAccountManagerFetchPolling()
        }
        
        pushNotificationController.requestAuthorization()
        pushNotificationController.registerDevice()
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        navigationItem.title = "tabbar-item-accounts".localized
        accountsView.accountsCollectionView.refreshControl = refreshControl
    }
    
    override func setListeners() {
        accountsLayoutBuilder.delegate = self
        accountsDataSource.delegate = self
        accountsView.accountsCollectionView.delegate = accountsLayoutBuilder
        accountsView.accountsCollectionView.dataSource = accountsDataSource
    }
    
    override func linkInteractors() {
        refreshControl.addTarget(self, action: #selector(didRefreshList), for: .valueChanged)
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
        selectedAccount = accountsDataSource.accounts[indexPath.section]
        guard let account = selectedAccount else {
            return
        }
        
        if indexPath.item == 0 {
            open(.assetDetail(account: account, assetDetail: nil), by: .push)
        } else {
            let assetDetail = account.assetDetails[indexPath.item - 1]
            open(.assetDetail(account: account, assetDetail: assetDetail), by: .push)
        }
    }
}

extension AccountsViewController: AccountsDataSourceDelegate {
    func accountsDataSource(_ accountsDataSource: AccountsDataSource, didTapOptionsButtonFor account: Account) {
        selectedAccount = account
        presentOptions(for: account)
    }
    
    func accountsDataSource(_ accountsDataSource: AccountsDataSource, didTapAddAssetButtonFor account: Account) {
        selectedAccount = account
        let controller = open(.addAsset(account: account), by: .push)
        (controller as? AssetAdditionViewController)?.delegate = self
    }
}

extension AccountsViewController: AssetAdditionViewControllerDelegate {
    func assetAdditionViewController(
        _ assetAdditionViewController: AssetAdditionViewController,
        didAdd assetDetail: AssetDetail,
        to account: Account
    ) {
        
    }
}

extension AccountsViewController {
    @objc
    fileprivate func didUpdateAuthenticatedUser(notification: Notification) {
        accountsView.accountsCollectionView.reloadData()
    }
    
    @objc
    private func didRefreshList() {
        accountsView.accountsCollectionView.reloadData()
        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
    }
}

extension AccountsViewController {
    private func presentOptions(for account: Account) {
        let transitionStyle = Screen.Transition.Open.customPresent(
            presentationStyle: .custom,
            transitionStyle: nil,
            transitioningDelegate: optionsModalPresenter
        )
        
        let optionsViewController = open(.options(account: account), by: transitionStyle) as? OptionsViewController
        
        optionsViewController?.delegate = self
    }
}

extension AccountsViewController {
    struct LayoutConstants: AdaptiveLayoutConstants {
        let optionsModalHeight: CGFloat = 384.0
        let transactionCellSize = CGSize(width: UIScreen.main.bounds.width, height: 72.0)
        let rewardCellSize = CGSize(width: UIScreen.main.bounds.width, height: 50.0)
        let editAccountModalHeight: CGFloat = 158.0
    }
}
