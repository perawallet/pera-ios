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
//   AccountPortfolioViewController.swift

import Foundation
import UIKit
import MacaroonUIKit

final class AccountPortfolioViewController: BaseViewController {
    private lazy var listLayout = AccountPortfolioListLayout(session: session!)
    private lazy var portfolioDataSource = AccountPortfolioDataSource(listView: listView, session: session!)
    private lazy var accountManager = AccountManager(api: api!)
    private lazy var modalTransition = BottomSheetTransition(presentingViewController: self)
    private lazy var pushNotificationController = PushNotificationController(api: api!, bannerController: bannerController)
    
    private let onceWhenViewDidAppear = Once()

    override var name: AnalyticsScreenName? {
        return .accounts
    }

    private lazy var listView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(AccountPortfolioCell.self)
        collectionView.register(AccountPreviewCell.self)
        collectionView.register(AnnouncementBannerCell.self)
        collectionView.register(header: SingleLineTitleActionHeaderView.self)
        return collectionView
    }()

    override func configureNavigationBarAppearance() {
        addBarButtons()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchAccountsIfNeeded()

        DispatchQueue.main.async {
            UIApplication.shared.appDelegate?.validateAccountManagerFetchPolling()
        }

        portfolioDataSource.applySnapshot(animatingDifferences: false)

        pushNotificationController.requestAuthorization()
        pushNotificationController.sendDeviceDetails()

        requestAppReview()
        presentPasscodeFlowIfNeeded()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reconnectToOldWCSessions()
        connectToWCSessionRequestFromDeeplink()
    }

    private func fetchAccountsIfNeeded() {
        guard let session = session,
              let user = session.authenticatedUser,
              !session.hasPassword(),
              !user.accounts.isEmpty else {
            return
        }

        loadingController?.startLoadingWithMessage("title-loading".localized)
        accountManager.fetchAllAccounts(isVerifiedAssetsIncluded: true) {
            self.loadingController?.stopLoadingAfter(seconds: 1, on: .main) { [weak self] in
                self?.portfolioDataSource.applySnapshot()
            }
        }
    }

    override func customizeTabBarAppearence() {
        isTabBarHidden = false
    }

    override func prepareLayout() {
        super.prepareLayout()
        addListView()
    }

    override func setListeners() {
        super.setListeners()
        setListSelectionListeners()
        setSectionSelectionListeners()
    }

    override func linkInteractors() {
        super.linkInteractors()
        listView.delegate = listLayout
        listView.dataSource = portfolioDataSource.dataSource
    }
}

extension AccountPortfolioViewController {
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

        let addBarButtonItem = ALGBarButtonItem(kind: .add) { [weak self] in
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

    private func setListSelectionListeners() {
        listLayout.handlers.didSelectAccount = { [weak self] account in
            guard let self = self else {
                return
            }

            self.open(.accountDetail(account: account), by: .push)
        }
    }

    private func setSectionSelectionListeners() {
        portfolioDataSource.handlers.didTapPortfolioTitle = { [weak self] in
            guard let self = self else {
                return
            }

            self.modalTransition.perform(.portfolioDescription)
        }

        portfolioDataSource.handlers.didSelectSection = { [weak self] section in
            guard let self = self else {
                return
            }

            let accountType: AccountType = section == .watchAccount ? .watch : .standard

            let controller = self.modalTransition.perform(
                .accountListOptions(accountType: accountType)
            ) as? AccountListOptionsViewController

            controller?.handlers.didSelect = { [weak self] option, accountType in
                guard let self = self else {
                    return
                }

                switch option {
                case .add:
                    self.open(
                        .welcome(flow: .addNewAccount(mode: .none)),
                        by: .customPresent(presentationStyle: .fullScreen, transitionStyle: nil, transitioningDelegate: nil)
                    )
                case .arrange:
                    self.open(.orderAccountList(accountType: accountType), by: .present)
                }
            }
        }
    }
}

extension AccountPortfolioViewController {
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

extension AccountPortfolioViewController {
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

extension AccountPortfolioViewController: WalletConnectorDelegate {
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

        modalTransition.perform(.wcConnectionApproval(walletConnectSession: session, delegate: self, completion: completion))
    }

    func walletConnector(_ walletConnector: WalletConnector, didConnectTo session: WCSession) {
        walletConnector.saveConnectedWCSession(session)
    }
}

extension AccountPortfolioViewController: WCConnectionApprovalViewControllerDelegate {
    func wcConnectionApprovalViewControllerDidApproveConnection(_ wcConnectionApprovalViewController: WCConnectionApprovalViewController) {
        wcConnectionApprovalViewController.dismissScreen()
    }

    func wcConnectionApprovalViewControllerDidRejectConnection(_ wcConnectionApprovalViewController: WCConnectionApprovalViewController) {
        wcConnectionApprovalViewController.dismissScreen()
    }
}

extension AccountPortfolioViewController {
    private func presentOptions(for account: Account) {
       // modalTransition.perform(.options(account: account, delegate: self))
    }
}

extension AccountPortfolioViewController: QRScannerViewControllerDelegate {
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

                modalTransition.perform(.assetActionConfirmation(assetAlertDraft: assetAlertDraft))
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
