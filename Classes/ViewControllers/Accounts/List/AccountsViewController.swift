//
//  AccountsViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 11.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AccountsViewController: BaseViewController {
    
    override var shouldShowNavigationBar: Bool {
        return false
    }
    
    let layout = Layout<LayoutConstants>()
    
    private lazy var optionsModalPresenter = CardModalPresenter(
        config: ModalConfiguration(
            animationMode: .normal(duration: 0.25),
            dismissMode: .scroll
        ),
        initialModalSize: .custom(CGSize(width: view.frame.width, height: layout.current.optionsModalHeight))
    )
    
    private(set) lazy var removeAccountModalPresenter = CardModalPresenter(
        config: ModalConfiguration(
            animationMode: .normal(duration: 0.25),
            dismissMode: .scroll
        ),
        initialModalSize: .custom(CGSize(width: view.frame.width, height: layout.current.removeAccountModalHeight))
    )
    
    private(set) lazy var editAccountModalPresenter = CardModalPresenter(
        config: ModalConfiguration(
            animationMode: .normal(duration: 0.25),
            dismissMode: .backgroundTouch
        ),
        initialModalSize: .custom(CGSize(width: view.frame.width, height: layout.current.editAccountModalHeight))
    )
    
    private(set) lazy var termsServiceModalPresenter = CardModalPresenter(
        config: ModalConfiguration(
            animationMode: .normal(duration: 0.25),
            dismissMode: .none
        ),
        initialModalSize: .custom(CGSize(width: view.frame.width, height: layout.current.termsAndServiceHeight))
    )
    
    private lazy var pushNotificationController: PushNotificationController = {
        guard let api = api else {
            fatalError("Api must be set before accessing this view controller.")
        }
        return PushNotificationController(api: api)
    }()
    
    private(set) lazy var accountsView = AccountsView()
    private lazy var noConnectionView = NoInternetConnectionView()
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
            name: .AuthenticatedUserUpdate,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didUpdateAuthenticatedUser(notification:)),
            name: .AccountUpdate,
            object: nil
        )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async {
            UIApplication.shared.appDelegate?.validateAccountManagerFetchPolling()
        }
        
        pushNotificationController.requestAuthorization()
        pushNotificationController.registerDevice()
        
        setAccountsCollectionViewContentState()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if accountsDataSource.hasPendingAssetAction {
            accountsView.accountsCollectionView.reloadData()
        }
        
        displayTestNetBannerIfNeeded()
        presentTermsAndServicesIfNeeded()
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        navigationItem.title = "tabbar-item-accounts".localized
        accountsView.accountsCollectionView.refreshControl = refreshControl
    }
    
    override func setListeners() {
        accountsLayoutBuilder.delegate = self
        accountsDataSource.delegate = self
        accountsView.delegate = self
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
    
    func accountsDataSource(_ accountsDataSource: AccountsDataSource, didTapQRButtonFor account: Account) {
        open(.qrGenerator(title: "qr-creation-sharing-title".localized, address: account.address, mode: .address), by: .present)
    }
}

extension AccountsViewController: AccountsViewDelegate {
    func accountsViewDidTapQRButton(_ accountsView: AccountsView) {
        let qrScannerViewController = open(.qrScanner, by: .push) as? QRScannerViewController
        qrScannerViewController?.delegate = self
    }
    
    func accountsViewDidTapAddButton(_ accountsView: AccountsView) {
        open(.addNewAccount, by: .customPresent(presentationStyle: .fullScreen, transitionStyle: nil, transitioningDelegate: nil))
    }
}

extension AccountsViewController: AssetAdditionViewControllerDelegate {
    func assetAdditionViewController(
        _ assetAdditionViewController: AssetAdditionViewController,
        didAdd assetSearchResult: AssetSearchResult,
        to account: Account
    ) {
        guard let section = accountsDataSource.section(for: account) else {
            return
        }
        
        let index = accountsView.accountsCollectionView.numberOfItems(inSection: section)
        accountsDataSource.add(assetDetail: AssetDetail(searchResult: assetSearchResult), to: account)
        accountsView.accountsCollectionView.insertItems(at: [IndexPath(item: index, section: section)])
    }
}

extension AccountsViewController {
    @objc
    fileprivate func didUpdateAuthenticatedUser(notification: Notification) {
        accountsDataSource.reload()
        setAccountsCollectionViewContentState()
        accountsView.accountsCollectionView.reloadData()
    }
    
    @objc
    private func didRefreshList() {
        accountsDataSource.refresh()
        setAccountsCollectionViewContentState()
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
    
    private func setAccountsCollectionViewContentState() {
        accountsView.accountsCollectionView.contentState = accountsDataSource.accounts.isEmpty ? .empty(noConnectionView) : .none
    }
    
    private func presentTermsAndServicesIfNeeded() {
        guard let session = self.session, !session.isTermsAndServicesAccepted() else {
            return
        }
        
        let transitionStyle = Screen.Transition.Open.customPresent(
            presentationStyle: .custom,
            transitionStyle: nil,
            transitioningDelegate: termsServiceModalPresenter
        )
        
        open(.termsAndServices, by: transitionStyle)
    }
    
    private func displayTestNetBannerIfNeeded() {
        guard let isTestNet = api?.isTestNet else {
            return
        }
        
        accountsView.setTestNetLabelHidden(!isTestNet)
    }
}

extension AccountsViewController: QRScannerViewControllerDelegate {
    func qrScannerViewController(_ controller: QRScannerViewController, didRead qrText: QRText, then handler: EmptyHandler?) {
        switch qrText.mode {
        case .address:
            open(.addContact(mode: .new(address: qrText.address, name: qrText.label)), by: .push)
        case .algosRequest:
            guard let address = qrText.address,
                let amount = qrText.amount else {
                return
            }
            open(.sendAlgosTransactionPreview(account: nil, receiver: .address(address: address, amount: "\(amount)")), by: .push)
        case .assetRequest:
            guard let address = qrText.address,
                let amount = qrText.amount,
                let assetId = qrText.asset else {
                return
            }
            
            var asset: AssetDetail?
            
            for account in accountsDataSource.accounts {
                for assetDetail in account.assetDetails where assetDetail.id == assetId {
                    asset = assetDetail
                    break
                }
            }
            
            guard let assetDetail = asset else {
                let assetAlertDraft = AssetAlertDraft(
                    account: nil,
                    assetIndex: assetId,
                    assetDetail: nil,
                    title: "asset-support-your-add-title".localized,
                    detail: "asset-support-your-add-message".localized,
                    actionTitle: "title-ok".localized
                )
                
                tabBarController?.open(
                    .assetSupport(assetAlertDraft: assetAlertDraft),
                    by: .customPresentWithoutNavigationController(
                        presentationStyle: .custom,
                        transitionStyle: nil,
                        transitioningDelegate: optionsModalPresenter
                    )
                )
                return
            }
            
            open(
                .sendAssetTransactionPreview(
                    account: nil,
                    receiver: .address(
                        address: address,
                        amount: amount
                            .assetAmount(fromFraction: assetDetail.fractionDecimals)
                            .toFractionStringForLabel(fraction: assetDetail.fractionDecimals)
                    ),
                    assetDetail: assetDetail,
                    isMaxTransaction: false
                ),
                by: .push
            )
        case .mnemonic:
            break
        }
    }
    
    func qrScannerViewController(_ controller: QRScannerViewController, didFail error: QRScannerError, then handler: EmptyHandler?) {
        displaySimpleAlertWith(title: "title-error".localized, message: "qr-scan-should-scan-valid-qr".localized) { _ in
            if let handler = handler {
                handler()
            }
        }
    }
}

extension AccountsViewController {
    struct LayoutConstants: AdaptiveLayoutConstants {
        let optionsModalHeight: CGFloat = 384.0
        let removeAccountModalHeight: CGFloat = 402.0
        let editAccountModalHeight: CGFloat = 158.0
        let termsAndServiceHeight: CGFloat = 300
    }
}
