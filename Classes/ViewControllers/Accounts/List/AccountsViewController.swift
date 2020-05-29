//
//  AccountsViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 11.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit
import Magpie

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
    
    private(set) lazy var termsServiceModalPresenter = CardModalPresenter(
        config: ModalConfiguration(
            animationMode: .normal(duration: 0.25),
            dismissMode: .none
        ),
        initialModalSize: .custom(CGSize(width: view.frame.width, height: layout.current.termsAndServiceHeight))
    )
    
    private(set) lazy var passphraseModalPresenter = CardModalPresenter(
        config: ModalConfiguration(
            animationMode: .normal(duration: 0.25),
            dismissMode: .scroll
        ),
        initialModalSize: .custom(CGSize(width: view.frame.width, height: layout.current.passphraseModalHeight))
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
    
    private var isConnectedToInternet = true {
        didSet {
            if isConnectedToInternet == oldValue {
                return
            }
            
            if isConnectedToInternet {
                refreshAccounts()
            } else {
                accountsDataSource.accounts.removeAll()
                accountsView.accountsCollectionView.contentState = .empty(noConnectionView)
                accountsView.setHeaderButtonsHidden(true)
                accountsView.accountsCollectionView.reloadData()
            }
        }
    }
    
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
    
    override func customizeTabBarAppearence() {
        isTabBarHidden = false
    }
    
    override func beginTracking() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didChangedNetwork(notification:)),
            name: .NetworkChanged,
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
        addTestNetBanner()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if accountsDataSource.hasPendingAssetAction {
            accountsView.accountsCollectionView.reloadData()
        }
        
        displayTestNetBannerIfNeeded()
        presentTermsAndServicesIfNeeded()
        api?.addDelegate(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.presentQRTooltipIfNeeded()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        api?.removeDelegate(self)
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
            make.leading.trailing.bottom.equalToSuperview()
            make.top.safeEqualToTop(of: self)
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
        let draft = QRCreationDraft(address: account.address, mode: .address)
        open(.qrGenerator(title: "qr-creation-sharing-title".localized, draft: draft), by: .present)
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
    private func didUpdateAuthenticatedUser(notification: Notification) {
        if !isConnectedToInternet {
            return
        }
        
        accountsDataSource.reload()
        setAccountsCollectionViewContentState()
        accountsView.accountsCollectionView.reloadData()
    }
    
    @objc
    private func didRefreshList() {
        if !isConnectedToInternet {
            if refreshControl.isRefreshing {
                refreshControl.endRefreshing()
            }
            return
        }
        
        refreshAccounts()
        
        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
    }
    
    private func refreshAccounts() {
        accountsDataSource.refresh()
        setAccountsCollectionViewContentState()
        accountsView.accountsCollectionView.reloadData()
    }
    
    @objc
    private func didChangedNetwork(notification: Notification) {
        guard let isTestNet = api?.isTestNet else {
            return
        }
        
        if isTestNet {
            addTestNetBanner()
        } else {
            removeTestNetBanner()
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
        accountsView.setHeaderButtonsHidden(accountsDataSource.accounts.isEmpty)
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
    func qrScannerViewController(_ controller: QRScannerViewController, didRead qrText: QRText, completionHandler: EmptyHandler?) {
        switch qrText.mode {
        case .address:
            open(.addContact(mode: .new(address: qrText.address, name: qrText.label)), by: .push)
        case .algosRequest:
            guard let address = qrText.address,
                let amount = qrText.amount else {
                return
            }
            open(
                .sendAlgosTransactionPreview(
                    account: nil,
                    receiver: .address(address: address, amount: "\(amount)"),
                    isSenderEditable: true
                ),
                by: .customPresent(
                    presentationStyle: .fullScreen,
                    transitionStyle: nil,
                    transitioningDelegate: nil
                )
            )
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
                
                open(
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
                    isSenderEditable: false,
                    isMaxTransaction: false
                ),
                by: .push
            )
        case .mnemonic:
            break
        }
    }
    
    func qrScannerViewController(_ controller: QRScannerViewController, didFail error: QRScannerError, completionHandler: EmptyHandler?) {
        displaySimpleAlertWith(title: "title-error".localized, message: "qr-scan-should-scan-valid-qr".localized) { _ in
            if let handler = completionHandler {
                handler()
            }
        }
    }
}

extension AccountsViewController {
    func presentQRTooltipIfNeeded() {
        guard let isAccountQRTooltipDisplayed = session?.isAccountQRTooltipDisplayed(),
            !isAccountQRTooltipDisplayed else {
            return
        }
 
        // Needs to set presentationController before calling present. So it's not initialized from the Router.
        let tooltipViewController = TooltipViewController(title: "accounts-qr-tooltip".localized, configuration: configuration)
        tooltipViewController.presentationController?.delegate = self
        present(tooltipViewController, animated: true)
        
        guard let headerView = accountsView.accountsCollectionView.supplementaryView(
            forElementKind: UICollectionView.elementKindSectionHeader,
            at: IndexPath(item: 0, section: 0)
        ) as? AccountHeaderSupplementaryView else {
            return
        }
        
        tooltipViewController.setSourceView(headerView.contextView.qrButton)
        session?.setAccountQRTooltipDisplayed()
    }
}

extension AccountsViewController: MagpieDelegate {
    func magpie(
        _ magpie: Magpie,
        networkMonitor: NetworkMonitor,
        didConnectVia connection: NetworkConnection,
        from oldConnection: NetworkConnection
    ) {
        isConnectedToInternet = networkMonitor.isConnected
    }
    
    func magpie(_ magpie: Magpie, networkMonitor: NetworkMonitor, didDisconnectFrom oldConnection: NetworkConnection) {
        isConnectedToInternet = networkMonitor.isConnected
    }
}

extension AccountsViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(
        for controller: UIPresentationController,
        traitCollection: UITraitCollection
    ) -> UIModalPresentationStyle {
        return .none
    }
}

extension AccountsViewController {
    struct LayoutConstants: AdaptiveLayoutConstants {
        let optionsModalHeight: CGFloat = 384.0
        let removeAccountModalHeight: CGFloat = 402.0
        let editAccountModalHeight: CGFloat = 158.0
        let passphraseModalHeight: CGFloat = 470.0
        let termsAndServiceHeight: CGFloat = 300
    }
}
