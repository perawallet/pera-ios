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
//   HomeViewController.swift

import Foundation
import UIKit
import MacaroonUtils
import MacaroonUIKit

final class HomeViewController:
    BaseViewController,
    UICollectionViewDelegateFlowLayout {
    private lazy var modalTransition = BottomSheetTransition(presentingViewController: self)
    private lazy var pushNotificationController = PushNotificationController(api: api!, bannerController: bannerController)
    
    private let onceWhenViewDidAppear = Once()

    override var name: AnalyticsScreenName? {
        return .accounts
    }

    private lazy var listView: UICollectionView = {
        let collectionViewLayout = HomeListLayout.build()
        let collectionView =
            UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .clear
        return collectionView
    }()

    private lazy var listLayout = HomeListLayout(listDataSource: listDataSource)
    private lazy var listDataSource = HomeListDataSource(listView)
    
    private let dataController: HomeDataController
    
    init(
        dataController: HomeDataController,
        configuration: ViewControllerConfiguration
    ) {
        self.dataController = dataController
        super.init(configuration: configuration)
    }

    override func configureNavigationBarAppearance() {
        addBarButtons()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataController.eventHandler = {
            [weak self] event in
            guard let self = self else { return }
            
            switch event {
            case .didUpdate(let snapshot):
                self.listDataSource.apply(snapshot, animatingDifferences: self.isViewAppeared)
            }
        }
        dataController.load()

        pushNotificationController.requestAuthorization()
        pushNotificationController.sendDeviceDetails()

        requestAppReview()
        presentPasscodeFlowIfNeeded()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reconnectToOldWCSessions()
        connectToWCSessionRequestFromDeeplink()
        
        let loadingCell = listView.visibleCells.first { $0 is HomeLoadingCell } as? HomeLoadingCell
        loadingCell?.startAnimating()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        let loadingCell = listView.visibleCells.first { $0 is HomeLoadingCell } as? HomeLoadingCell
        loadingCell?.stopAnimating()
    }

    override func customizeTabBarAppearence() {
        tabBarHidden = false
    }

    override func prepareLayout() {
        super.prepareLayout()
        addListView()
    }

    override func linkInteractors() {
        super.linkInteractors()

        listView.delegate = self

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didUpdateAuthenticatedUser(notification:)),
            name: .AuthenticatedUserUpdate,
            object: nil
        )
    }
}

extension HomeViewController {
    @objc
    private func didUpdateAuthenticatedUser(notification: Notification) {
        registerWCRequests()
    }
}

extension HomeViewController {
    private func addListView() {
        view.addSubview(listView)
        listView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    private func addBarButtons() {
        let notificationBarButtonItem = ALGBarButtonItem(kind: .notification) { [weak self] in
            guard let self = self else {
                return
            }

            self.open(.notifications, by: .push)
        }

        let qrBarButtonItem = ALGBarButtonItem(kind: .qr) { [weak self] in
            guard let self = self else {
                return
            }

            let qrScannerViewController = self.open(.qrScanner(canReadWCSession: true), by: .push) as? QRScannerViewController
            qrScannerViewController?.delegate = self
        }

        let addBarButtonItem = ALGBarButtonItem(kind: .circleAdd) { [weak self] in
            guard let self = self else {
                return
            }

            self.open(
                .welcome(flow: .addNewAccount(mode: .none)),
                by: .customPresent(presentationStyle: .fullScreen, transitionStyle: nil, transitioningDelegate: nil)
            )
        }

        leftBarButtonItems = [notificationBarButtonItem]
        rightBarButtonItems = [addBarButtonItem, qrBarButtonItem]
    }
}

extension HomeViewController {
    private func linkInteractors(
        _ cell: HomeNoContentCell
    ) {
        cell.observe(event: .performAction) {
            [weak self] in
            guard let self = self else { return }
            
            self.open(
                .welcome(flow: .addNewAccount(mode: .none)),
                by: .customPresent(
                    presentationStyle: .fullScreen,
                    transitionStyle: nil,
                    transitioningDelegate: nil
                )
            )
        }
    }
    
    private func linkInteractors(
        _ cell: HomePortfolioCell,
        for item: HomePortfolioViewModel
    ) {
        cell.observe(event: .showInfo) {
            [weak self] in
            guard let self = self else { return }
            
            /// <todo>
            /// How to manage it without knowing view controller. Name conventions vs. protocols???
            let eventHandler: PortfolioCalculationInfoViewController.EventHandler = {
                [weak self] event in
                guard let self = self else { return }
            
                switch event {
                case .close:
                    self.dismiss(animated: true)
                }
            }

            self.modalTransition.perform(
                .portfolioCalculationInfo(
                    result: item.totalValueResult,
                    eventHandler: eventHandler
                ),
                by: .presentWithoutNavigationController
            )
        }
    }
    
    private func linkInteractors(
        _ cell: TitleWithAccessorySupplementaryCell,
        for item: HomeAccountSectionHeaderViewModel
    ) {
        cell.observe(event: .performAccessory) {
            [weak self] in
            guard let self = self else { return }
            
            let eventHandler: AccountListOptionsViewController.EventHandler = {
                [weak self] event in
                guard let self = self else { return }
                
                self.dismiss(animated: true) {
                    [weak self] in
                    guard let self = self else { return }
                    
                    switch event {
                    case .addAccount:
                        self.open(
                            .welcome(flow: .addNewAccount(mode: .none)),
                            by: .customPresent(
                                presentationStyle: .fullScreen,
                                transitionStyle: nil,
                                transitioningDelegate: nil
                            )
                        )
                    case .arrangeAccounts(let accountType):
                        self.open(
                            .orderAccountList(accountType: accountType),
                            by: .present
                        )
                    }
                }
            }
            
            self.modalTransition.perform(
                .accountListOptions(accountType: item.type, eventHandler: eventHandler),
                by: .presentWithoutNavigationController
            )
        }
    }
}

extension HomeViewController {
    private func requestAppReview() {
        asyncMain(afterDuration: 1.0) {
            AlgorandAppStoreReviewer().requestReviewIfAppropriate()
        }
    }

    private func presentPasscodeFlowIfNeeded() {
        guard let session = session,
              !session.hasPassword() else {
            return
        }

        var passcodeSettingDisplayStore = PasscodeSettingDisplayStore()

        if !passcodeSettingDisplayStore.hasPermissionToAskAgain {
            return
        }

        passcodeSettingDisplayStore.increaseAppOpenCount()

        if passcodeSettingDisplayStore.shouldAskForPasscode {
            let controller = open(
                .tutorial(flow: .none, tutorial: .passcode),
                by: .customPresent(presentationStyle: .fullScreen, transitionStyle: nil, transitioningDelegate: nil)
            ) as? TutorialViewController
            controller?.uiHandlers.didTapDontAskAgain = { tutorialViewController in
                tutorialViewController.dismissScreen()
                var passcodeSettingDisplayStore = PasscodeSettingDisplayStore()
                passcodeSettingDisplayStore.disableAskingPasscode()
            }
        }
    }
}

extension HomeViewController {
    private func reconnectToOldWCSessions() {
        onceWhenViewDidAppear.execute {
            asyncMain(afterDuration: 2.0) { [weak self] in
                guard let self = self else {
                    return
                }

                self.walletConnector.reconnectToSavedSessionsIfPossible()
            }
        }
    }

    private func registerWCRequests() {
        let wcRequestHandler = TransactionSignRequestHandler()
        if let rootViewController = UIApplication.shared.rootViewController() {
            wcRequestHandler.delegate = rootViewController
        }
        walletConnector.register(for: wcRequestHandler)
    }

    private func connectToWCSessionRequestFromDeeplink() {
        if let appDelegate = UIApplication.shared.appDelegate,
           let incominWCSession = appDelegate.incomingWCSessionRequest {
            walletConnector.delegate = self

            asyncMain(afterDuration: 2.0) { [weak self] in
                guard let self = self else {
                    return
                }

                self.walletConnector.connect(to: incominWCSession)
            }

            appDelegate.resetWCSessionRequest()
        }
    }
}

extension HomeViewController: WalletConnectorDelegate {
    func walletConnector(
        _ walletConnector: WalletConnector,
        shouldStart session: WalletConnectSession,
        then completion: @escaping WalletConnectSessionConnectionCompletionHandler
    ) {
        guard let accounts = self.session?.accounts,
              accounts.contains(where: { $0.type != .watch }) else {
            bannerController?.presentErrorBanner(
                title: "title-error".localized,
                message: "wallet-connect-session-error-no-account".localized
            )
            return
        }

        modalTransition.perform(
            .wcConnectionApproval(walletConnectSession: session, delegate: self, completion: completion),
            by: .present
        )
    }

    func walletConnector(_ walletConnector: WalletConnector, didConnectTo session: WCSession) {
        walletConnector.saveConnectedWCSession(session)
    }
}

extension HomeViewController: WCConnectionApprovalViewControllerDelegate {
    func wcConnectionApprovalViewControllerDidApproveConnection(_ wcConnectionApprovalViewController: WCConnectionApprovalViewController) {
        wcConnectionApprovalViewController.dismissScreen()
    }

    func wcConnectionApprovalViewControllerDidRejectConnection(_ wcConnectionApprovalViewController: WCConnectionApprovalViewController) {
        wcConnectionApprovalViewController.dismissScreen()
    }
}

extension HomeViewController {
    private func presentOptions(for account: Account) {
       // modalTransition.perform(.options(account: account, delegate: self))
    }
}

extension HomeViewController: QRScannerViewControllerDelegate {
    func qrScannerViewController(_ controller: QRScannerViewController, didRead qrText: QRText, completionHandler: EmptyHandler?) {
        switch qrText.mode {
        case .address:
            open(.addContact(address: qrText.address, name: qrText.label), by: .push)
        case .algosRequest:
            guard let address = qrText.address,
                let amount = qrText.amount else {
                return
            }

            open(
                .sendAlgosTransactionPreview(
                    account: nil,
                    receiver: .address(address: address, amount: "\(amount)"),
                    isSenderEditable: true,
                    qrText: qrText
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

            for account in session!.accounts {
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
                    actionTitle: "title-approve".localized,
                    cancelTitle: "title-cancel".localized
                )

                modalTransition.perform(
                    .assetActionConfirmation(assetAlertDraft: assetAlertDraft),
                    by: .presentWithoutNavigationController
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
                    isMaxTransaction: false,
                    qrText: qrText
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

extension HomeViewController {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return listLayout.collectionView(
            collectionView,
            layout: collectionViewLayout,
            insetForSectionAt: section
        )
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return listLayout.collectionView(
            collectionView,
            layout: collectionViewLayout,
            sizeForItemAt: indexPath
        )
    }
}

extension HomeViewController {
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard let itemIdentifier = listDataSource.itemIdentifier(for: indexPath) else {
            return
        }
        
        switch itemIdentifier {
        case .empty(let item):
            switch item {
            case .loading:
                let loadingCell = cell as? HomeLoadingCell
                loadingCell?.startAnimating()
            case .noContent:
                linkInteractors(cell as! HomeNoContentCell)
            }
        case .portfolio(let item):
            linkInteractors(
                cell as! HomePortfolioCell,
                for: item
            )
        case .account(let item):
            switch item {
            case .header(let headerItem):
                linkInteractors(
                    cell as! TitleWithAccessorySupplementaryCell,
                    for: headerItem
                )
            default:
                break
            }
        default:
            break
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplaying cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard let itemIdentifier = listDataSource.itemIdentifier(for: indexPath) else {
            return
        }
        
        switch itemIdentifier {
        case .empty(let item):
            switch item {
            case .loading:
                let loadingCell = cell as? HomeLoadingCell
                loadingCell?.stopAnimating()
            default:
                break
            }
        default:
            break
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let itemIdentifier = listDataSource.itemIdentifier(for: indexPath) else {
            return
        }
        
        switch itemIdentifier {
        case .account(let item):
            switch item {
            case .cell(let cellItem):
                guard let account = dataController[cellItem.address] else {
                    return
                }
                
                if account.isReady {
                    open(
                        .accountDetail(accountHandle: account),
                        by: .push
                    )
                } else {
                    modalTransition.perform(
                        .invalidAccount(account: account),
                        by: .presentWithoutNavigationController
                    )
                }
            default:
                break
            }
        default: break
        }
    }
}

struct PasscodeSettingDisplayStore: Storable {
    typealias Object = Any

    let appOpenCountToAskPasscode = 5

    private let appOpenCountKey = "com.algorand.algorand.passcode.app.count.key"
    private let dontAskAgainKey = "com.algorand.algorand.passcode.dont.ask.again"

    var appOpenCount: Int {
        return userDefaults.integer(forKey: appOpenCountKey)
    }

    mutating func increaseAppOpenCount() {
        userDefaults.set(appOpenCount + 1, forKey: appOpenCountKey)
    }

    var hasPermissionToAskAgain: Bool {
        return !userDefaults.bool(forKey: dontAskAgainKey)
    }

    mutating func disableAskingPasscode() {
        userDefaults.set(true, forKey: dontAskAgainKey)
    }

    var shouldAskForPasscode: Bool {
        return appOpenCount % appOpenCountToAskPasscode == 0
    }
}
