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
    
    private(set) lazy var accountsView = AccountsView()
    private lazy var refreshControl = UIRefreshControl()
    
    private(set) var selectedAccount: Account?
    private(set) var localAuthenticator = LocalAuthenticator()
    
    private var accountsLayoutBuilder: AccountsLayoutBuilder
    private(set) var accountsDataSource: AccountsDataSource
    
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
        setupLeftBarButtonItems()
    }
    
    private func setupLeftBarButtonItems() {
        let addAccountBarButtonItem = ALGBarButtonItem(kind: .add) { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.open(
                .introduction(mode: .new),
                by: .customPresent(presentationStyle: .fullScreen, transitionStyle: nil, transitioningDelegate: nil)
            )
        }
        
        leftBarButtonItems = [addAccountBarButtonItem]
    }
    
    private func setupRightBarButtonItems() {
        let qrBarButtonItem = ALGBarButtonItem(kind: .qr) { [weak self] in
            guard let strongSelf = self else {
                return
            }
            let qrScannerViewController = strongSelf.open(.qrScanner, by: .push) as? QRScannerViewController
            qrScannerViewController?.delegate = strongSelf
        }

        rightBarButtonItems = [qrBarButtonItem]
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
        guard let section = accountsDataSource.section(for: account) else {
            return
        }
        
        let index = accountsView.accountsCollectionView.numberOfItems(inSection: section)
        accountsDataSource.add(assetDetail: assetDetail, to: account)
        accountsView.accountsCollectionView.insertItems(at: [IndexPath(item: index, section: section)])
    }
}

extension AccountsViewController {
    @objc
    fileprivate func didUpdateAuthenticatedUser(notification: Notification) {
        accountsDataSource.reload()
        accountsView.accountsCollectionView.reloadData()
    }
    
    @objc
    private func didRefreshList() {
        accountsDataSource.refresh()
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

extension AccountsViewController: QRScannerViewControllerDelegate {
    func qrScannerViewController(_ controller: QRScannerViewController, didRead qrText: QRText, then handler: EmptyHandler?) {
        switch qrText.mode {
        case .address:
            break
        case .algosRequest:
            break
        case .assetRequest:
            break
        case .mnemonic:
            break
        }
    }
    
    func qrScannerViewController(_ controller: QRScannerViewController, didFail error: QRScannerError, then handler: EmptyHandler?) {
        
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
