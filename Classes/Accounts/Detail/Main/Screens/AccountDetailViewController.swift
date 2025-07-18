// Copyright 2022-2025 Pera Wallet, LDA

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
//   AccountDetailViewController.swift

import MacaroonUIKit
import MacaroonUtils
import UIKit

final class AccountDetailViewController: PageContainer {
    typealias EventHandler = (Event) -> Void
    
    var eventHandler: EventHandler?
    
    private lazy var theme = Theme()

    private lazy var transitionToPassphraseDisplay = BottomSheetTransition(presentingViewController: self)
    private lazy var transitionToTransactionOptions = BottomSheetTransition(presentingViewController: self)
    private lazy var transitionToOptions = BottomSheetTransition(presentingViewController: self)
    private lazy var transitionToManagementOptions = BottomSheetTransition(presentingViewController: self)
    private lazy var transitionToRenameAccount = BottomSheetTransition(presentingViewController: self)
    private lazy var transitionToBuySellOptions = BottomSheetTransition(presentingViewController: self)

    private lazy var assetListScreen = createAssetListScreen()
    private lazy var collectibleListScreen = createCollectibleListScreen()
    private lazy var transactionListScreen = createTransactionListScreen()

    private lazy var backupAccountFlowCoordinator = BackUpAccountFlowCoordinator(
        presentingScreen: self,
        api: api!
    )
    private lazy var removeAccountFlowCoordinator = RemoveAccountFlowCoordinator(
        presentingScreen: self,
        sharedDataController: sharedDataController,
        bannerController: bannerController!
    )
    private lazy var meldFlowCoordinator = MeldFlowCoordinator(
        analytics: analytics,
        presentingScreen: self
    )
    private lazy var bidaliFlowCoordinator = BidaliFlowCoordinator(presentingScreen: self, api: api!)

    private lazy var swapAssetFlowCoordinator = SwapAssetFlowCoordinator(
        draft: SwapAssetFlowDraft(account: accountHandle.value),
        dataStore: swapDataStore,
        analytics: analytics,
        api: api!,
        sharedDataController: sharedDataController,
        loadingController: loadingController!,
        bannerController: bannerController!,
        hdWalletStorage: hdWalletStorage,
        presentingScreen: self
    )
    private lazy var sendTransactionFlowCoordinator = SendTransactionFlowCoordinator(
        presentingScreen: self,
        sharedDataController: sharedDataController,
        account: accountHandle.value
    )
    private lazy var receiveTransactionFlowCoordinator = ReceiveTransactionFlowCoordinator(
        presentingScreen: self
    )
    private lazy var undoRekeyFlowCoordinator = UndoRekeyFlowCoordinator(
        presentingScreen: self,
        sharedDataController: sharedDataController
    )
    private lazy var rekeyToStandardAccountFlowCoordinator = RekeyToStandardAccountFlowCoordinator(
        presentingScreen: self,
        sharedDataController: sharedDataController
    )
    private lazy var rekeyToLedgerAccountFlowCoordinator = RekeyToLedgerAccountFlowCoordinator(
        presentingScreen: self,
        sharedDataController: sharedDataController
    )
    private lazy var accountInformationFlowCoordinator = AccountInformationFlowCoordinator(
        presentingScreen: self,
        sharedDataController: sharedDataController
    )

    private lazy var localAuthenticator = LocalAuthenticator(session: session!)
    
    private lazy var rekeyingValidator = RekeyingValidator(
        session: session!,
        sharedDataController: sharedDataController
    )

    private lazy var navigationTitleView = AccountNameTitleView()

    private var accountHandle: AccountHandle {
        didSet { updateNavigationItemsIfNeededWhenAccountDidUpdate(old: oldValue)  }
    }

    private let dataController: AccountDetailDataController
    private lazy var rescanRekeyedAccountsCoordinator = RescanRekeyedAccountsCoordinator(presenter: self)

    /// <todo>
    /// Normally, we shouldn't retain data store or create flow coordinator here but our currenct
    /// routing approach hasn't been refactored yet.
    private let swapDataStore: SwapDataStore
    private let copyToClipboardController: CopyToClipboardController
    private let incomingASAsRequestsCount: Int

    init(
        accountHandle: AccountHandle,
        dataController: AccountDetailDataController,
        swapDataStore: SwapDataStore,
        copyToClipboardController: CopyToClipboardController,
        configuration: ViewControllerConfiguration,
        incomingASAsRequestsCount: Int
    ) {
        self.accountHandle = accountHandle
        self.dataController = dataController
        self.swapDataStore = swapDataStore
        self.copyToClipboardController = copyToClipboardController
        self.incomingASAsRequestsCount = incomingASAsRequestsCount
        super.init(configuration: configuration)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setPageBarItems()
    }

    override func viewWillAppear(
        _ animated: Bool
    ) {
        super.viewWillAppear(animated)
        switchToHighlightedNavigationBarAppearance()
    }

    override func viewWillDisappear(
        _ animated: Bool
    ) {
        super.viewWillDisappear(animated)

        if presentedViewController == nil {
            switchToDefaultNavigationBarAppearance()
        }
    }

    override func configureNavigationBarAppearance() {
        addNavigationTitle()
        addNavigationActions()
    }
    
    override func customizeTabBarAppearence() {
        tabBarHidden = false
    }

    override func customizePageBarAppearance() {
        super.customizePageBarAppearance()

        pageBar.customizeAppearance([
            .backgroundColor(Colors.Defaults.background)
        ])
    }

    override func configureAppearance() {
        super.configureAppearance()
        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
    }

    override func linkInteractors() {
        super.linkInteractors()
        linkInteractors(assetListScreen)
    }

    override func itemDidSelect(
        _ index: Int
    ) {
        endEditing()
    }
}

extension AccountDetailViewController {
    private func linkInteractors(
        _ screen: AccountAssetListViewController
    ) {
        screen.eventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .didUpdate(let accountHandle):
                self.accountHandle = accountHandle
            case .backUpAccount:
                openBackUpAccount()
            case .manageAssets(let isWatchAccount):
                self.assetListScreen.endEditing()

                self.openAssetManagementOptions(isWatchAccount: isWatchAccount)
            case .copyAddress:
                self.copyAddress()
            case .showAddress:
                self.openShowAddress()
            case .addAsset:
                self.assetListScreen.endEditing()
                self.analytics.track(.recordAccountDetailScreen(type: .addAssets))

                self.openAddAssetScreenIfPossible()
            case .requests:
                self.assetListScreen.endEditing()
                self.analytics.track(.recordAccountDetailScreen(type: .tapAssetInbox))
                
                self.openIncomingASAAccountInbox()
            case .swap:
                self.assetListScreen.endEditing()

                self.openSwapAssetIfPossible()
            case .buy:
                self.assetListScreen.endEditing()
                self.analytics.track(.recordAccountDetailScreen(type: .tapBuyAlgo))
                
                self.openBuySellOptionsIfPossible()
            case .send:
                self.assetListScreen.endEditing()
                self.analytics.track(.recordAccountDetailScreen(type: .tapSend))

                self.openSendTransactionIfPossible()
            case .more:
                self.assetListScreen.endEditing()
                self.analytics.track(.recordAccountDetailScreen(type: .tapMore))

                self.presentOptionsScreen()
            case .transactionOption:
                self.openAccountActionsMenu()
            }
        }
    }
}

extension AccountDetailViewController: TransactionOptionsScreenDelegate {
    func transactionOptionsScreenDidTapCopyAddress(_ transactionOptionsScreen: TransactionOptionsScreen) {
        transactionOptionsScreen.dismiss(animated: true) {
            [unowned self] in
            self.copyAddress()
        }
    }

    func transactionOptionsScreenDidTapShowAddress(_ transactionOptionsScreen: TransactionOptionsScreen) {
        transactionOptionsScreen.dismiss(animated: true) {
            [unowned self] in
            self.openShowAddress()
        }
    }

    func transactionOptionsScreenDidTapAddAsset(_ transactionOptionsScreen: TransactionOptionsScreen) {
        transactionOptionsScreen.dismiss(animated: true) {
            [unowned self] in
            self.openAddAssetScreenIfPossible()
        }
    }

    func transactionOptionsScreenDidTapBuySell(_ transactionOptionsScreen: TransactionOptionsScreen) {
        transactionOptionsScreen.dismiss(animated: true) {
            [unowned self] in
            self.openBuySellOptionsIfPossible()
        }
    }

    func transactionOptionsScreenDidTapSwap(_ transactionOptionsScreen: TransactionOptionsScreen) {
        transactionOptionsScreen.dismiss(animated: true) {
            [unowned self] in
            self.openSwapAssetIfPossible()
        }
    }

    func transactionOptionsScreenDidTapSend(_ transactionOptionsScreen: TransactionOptionsScreen) {
        transactionOptionsScreen.dismiss(animated: true) {
            [unowned self] in
            self.openSendTransactionIfPossible()
        }
    }

    func transactionOptionsScreenDidTapReceive(_ transactionOptionsScreen: TransactionOptionsScreen) {
        transactionOptionsScreen.dismiss(animated: true) {
            [unowned self] in
            self.receiveTransactionFlowCoordinator.launch(accountHandle.value)
        }
    }

    func transactionOptionsScreenDidTapMore(_ transactionOptionsScreen: TransactionOptionsScreen) {
        transactionOptionsScreen.dismiss(animated: true) {
            [unowned self] in
            self.presentOptionsScreen()
        }
    }
}

extension AccountDetailViewController {
    private func openBackUpAccount() {
        backupAccountFlowCoordinator.eventHandler = {
            [weak self] event in
            guard let self else { return }
            
            switch event {
            case .didBackUpAccount(let account):
                self.accountHandle = account
          
                self.assetListScreen.reloadData()

                self.eventHandler?(.didBackUp)
            }
        }

        backupAccountFlowCoordinator.launch(accountHandle)
    }
}

extension AccountDetailViewController {
    private func openAssetManagementOptions(isWatchAccount: Bool) {
        analytics.track(.recordAccountDetailScreen(type: .manageAssets))

        transitionToManagementOptions.perform(
            .managementOptions(
                managementType: isWatchAccount ? .watchAccountAssets : .assets,
                delegate: self
            ),
            by: .present
        )
    }
}

extension AccountDetailViewController {
    private func openIncomingASAAccountInbox()  {
        let screen = open(
            .incomingASA(
                address: accountHandle.value.address,
                requestsCount: incomingASAsRequestsCount
            ),
            by: .push
        ) as? IncomingASAAccountInboxViewController
        
        screen?.eventHandler = {
            [weak self, weak screen] event in
            guard let screen else {
                return
            }
            
            switch event {
            case .didCompleteTransaction:
                screen.closeScreen(by: .pop, animated: false)
                self?.popScreen()
            }
        }
    }
    
    private func openBuySellOptionsIfPossible() {
        let aRawAccount = accountHandle.value
        if aRawAccount.authorization.isNoAuth {
            presentActionsNotAvailableForAccountBanner()
            return
        }

        let eventHandler: BuySellOptionsScreen.EventHandler = {
            [unowned self] event in
            switch event {
            case .performBuyWithMeld:
                self.dismiss(animated: true) {
                    [weak self] in
                    guard let self else { return }
                    self.openBuyWithMeld()
                }
            case .performBuyGiftCardsWithBidali:
                self.dismiss(animated: true) {
                    [weak self] in
                    guard let self else { return }
                    self.openBuyGiftCardsWithBidali()
                }
            }
        }

        transitionToBuySellOptions.perform(
            .buySellOptions(eventHandler: eventHandler),
            by: .presentWithoutNavigationController
        )
    }

    private func openBuyWithMeld() {
        analytics.track(.recordAccountDetailScreen(type: .tapBuyAlgo))

        meldFlowCoordinator.launch(accountHandle.value)
    }

    private func openBuyGiftCardsWithBidali() {
        bidaliFlowCoordinator.launch(accountHandle)
    }
}

extension AccountDetailViewController {
    private func openSwapAssetIfPossible() {
        let aRawAccount = accountHandle.value
        if aRawAccount.authorization.isNoAuth {
            presentActionsNotAvailableForAccountBanner()
            return
        }

        analytics.track(.recordAccountDetailScreen(type: .tapSwap))
        swapAssetFlowCoordinator.launch()
    }
}

extension AccountDetailViewController {
    private func openSendTransactionIfPossible() {
        let aRawAccount = accountHandle.value
        if aRawAccount.authorization.isNoAuth {
            presentActionsNotAvailableForAccountBanner()
            return
        }

        sendTransactionFlowCoordinator.launch()
    }
}

extension AccountDetailViewController {
    private func presentActionsNotAvailableForAccountBanner() {
        bannerController?.presentErrorBanner(
            title: String(localized: "action-not-available-for-account-type"),
            message: ""
        )
    }
}

extension AccountDetailViewController {
    private func addNavigationActions() {
        let account = accountHandle.value
        let optionsBarButtonItem = ALGBarButtonItem(kind: .account(account)) {
            [unowned self] in
            self.endEditing()
            self.openAccountInformationScreen()
        }

        rightBarButtonItems = [ optionsBarButtonItem ]
    }

    private func openAccountInformationScreen() {
        let sourceAccount = accountHandle.value
        accountInformationFlowCoordinator.launch(sourceAccount)
    }

    private func updateNavigationItemsIfNeededWhenAccountDidUpdate(old: AccountHandle) {
        if old.value.authorization == accountHandle.value.authorization {
            return
        }

        addNavigationActions()
        bindNavigationTitle()
        setNeedsRightBarButtonItemsUpdate()
    }

    private func presentOptionsScreen() {
        transitionToOptions.perform(
            .options(
                account: accountHandle.value,
                delegate: self
            ),
            by: .presentWithoutNavigationController
        )
    }

    private func openAddAssetScreenIfPossible() {
        let aRawAccount = accountHandle.value
        if aRawAccount.authorization.isNoAuth {
            presentActionsNotAvailableForAccountBanner()
            return
        }

        let controller = open(
            .addAsset(
                account: accountHandle.value
            ),
            by: .present
        ) as? AssetAdditionViewController
        controller?.navigationController?.presentationController?.delegate = assetListScreen
    }

    private func setPageBarItems() {
        items = [
            AssetListPageBarItem(screen: assetListScreen),
            CollectibleListPageBarItem(screen: collectibleListScreen),
            TransactionListPageBarItem(screen: transactionListScreen)
        ]
    }

    private func addNavigationTitle() {
        navigationTitleView.customize(theme.navigationTitle)

        navigationItem.titleView = navigationTitleView

        let recognizer = UILongPressGestureRecognizer(
            target: self,
            action: #selector(copyAccountAddress(_:))
        )
        navigationTitleView.addGestureRecognizer(recognizer)

        bindNavigationTitle()
    }

    private func bindNavigationTitle() {
        let account = accountHandle.value
        let viewModel = AccountNameTitleViewModel(account)
        navigationTitleView.bindData(viewModel)
    }
}

extension AccountDetailViewController {
    @objc
    private func copyAccountAddress(_ recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began {
            copyAddress()
        }
    }

    private func copyAddress() {
        let account = accountHandle.value
        copyToClipboardController.copyAddress(account)
    }
}

extension AccountDetailViewController {
    @objc
    private func openAccountActionsMenu() {
        view.endEditing(true)

        transitionToTransactionOptions.perform(
           .transactionOptions(
                account: accountHandle.value,
                delegate: self
            ),
            by: .presentWithoutNavigationController
        )
    }
}

extension AccountDetailViewController: OptionsViewControllerDelegate {
    
    func optionsViewControllerDidCopyAddress(_ optionsViewController: OptionsViewController) {
        let account = accountHandle.value
        analytics.track(.showQRCopy(account: account))

        copyAddress()
    }

    func optionsViewControllerDidUndoRekey(_ optionsViewController: OptionsViewController) {
        let sourceAccount = accountHandle.value
        undoRekeyFlowCoordinator.launch(sourceAccount)
    }
    
    func optionsViewControllerDidOpenRekeyingToLedger(_ optionsViewController: OptionsViewController) {
        let sourceAccount = accountHandle.value
        rekeyToLedgerAccountFlowCoordinator.launch(sourceAccount)
    }

    func optionsViewControllerDidOpenRekeyingToStandardAccount(_ optionsViewController: OptionsViewController) {
        let sourceAccount = accountHandle.value
        rekeyToStandardAccountFlowCoordinator.launch(sourceAccount)
    }
    
    func optionsViewControllerDidViewRekeyInformation(_ optionsViewController: OptionsViewController) {
        guard let authAddress = accountHandle.value.authAddress else {
            return
        }

        let draft = QRCreationDraft(address: authAddress, mode: .address, title: accountHandle.value.name)
        open(.qrGenerator(title: String(localized: "options-auth-account"), draft: draft, isTrackable: true), by: .present)
    }

    func optionsViewControllerDidShowQR(_ optionsViewController: OptionsViewController) {
        openShowAddress()
    }

    private func openShowAddress() {
        let account = accountHandle.value
        let accountName = account.primaryDisplayName
        let draft = QRCreationDraft(
            address: account.address,
            mode: .address,
            title: accountName
        )
        let qrGeneratorScreen: Screen = .qrGenerator(
            title: accountName,
            draft: draft,
            isTrackable: true
        )

        open(qrGeneratorScreen, by: .present)
    }

    func optionsViewControllerDidViewPassphrase(_ optionsViewController: OptionsViewController) {
        guard let session = session else {
            return
        }

        if !session.hasPassword() {
            presentPassphraseView()
            return
        }

        if localAuthenticator.hasAuthentication() {
            do {
                try localAuthenticator.authenticate()
                presentPassphraseView()
            } catch {
                presentPasswordConfirmScreen()
            }
        } else {
            presentPasswordConfirmScreen()
        }
    }

    private func presentPassphraseView() {
        let eventHandler: PassphraseWarningScreen.EventHandler = {
            [weak self] event in
            guard let self else { return }
            switch event {
            case .close:
                dismiss(animated: true)
            case .reveal:
                dismiss(animated: true) {
                    [weak self] in
                    guard let self else { return }
                    transitionToPassphraseDisplay.perform(
                        .passphraseDisplay(address: accountHandle.value),
                        by: .present
                    )
                }
            }
        }
        
        transitionToPassphraseDisplay.perform(
            .passphraseWarning(eventHandler: eventHandler),
            by: .presentWithoutNavigationController
        )
    }

    private func presentPasswordConfirmScreen() {
        let controller = open(
            .choosePassword(mode: .confirm(flow: .viewPassphrase), flow: nil),
            by: .present
        ) as? ChoosePasswordViewController
        controller?.delegate = self
    }

    func optionsViewControllerDidRenameAccount(_ optionsViewController: OptionsViewController) {
        let screen: Screen = .renameAccount(
            account: accountHandle.value,
            delegate: self
        )

        transitionToRenameAccount.perform(
            screen,
            by: .present
        )
    }

    func optionsViewControllerDidRemoveAccount(_ optionsViewController: OptionsViewController) {
        removeAccountFlowCoordinator.eventHandler = {
            [weak self] event in
            guard let self else { return }
            switch event {
            case .didRemoveAccount:
                self.eventHandler?(.didRemove)
            }
        }

        let account = accountHandle.value
        removeAccountFlowCoordinator.launch(account)
    }
    
    func optionsViewControllerDidRescanRekeyedAccounts(_ optionsViewController: OptionsViewController) {
        rescanRekeyedAccountsCoordinator.rescan(accounts: [accountHandle.value], nextStep: .dismiss)
    }
    
}

extension AccountDetailViewController: ChoosePasswordViewControllerDelegate {
    func choosePasswordViewController(
        _ choosePasswordViewController: ChoosePasswordViewController,
        didConfirmPassword isConfirmed: Bool
    ) {
        choosePasswordViewController.dismissScreen {
            [weak self] in
            guard let self else { return }
            
            if isConfirmed {
                self.presentPassphraseView()
            }
        }
    }
}

extension AccountDetailViewController: RenameAccountScreenDelegate {
    func renameAccountScreenDidTapDoneButton(_ screen: RenameAccountScreen) {
        screen.closeScreen(by: .dismiss) {
            [weak self] in
            guard let self = self else {
                return
            }

            self.bindNavigationTitle()
            self.eventHandler?(.didEdit)
        }
    }
}

extension AccountDetailViewController: ManagementOptionsViewControllerDelegate {
    func managementOptionsViewControllerDidTapSort(
        _ managementOptionsViewController: ManagementOptionsViewController
    ) {
        let eventHandler: SortAccountAssetListViewController.EventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .didComplete:
                let order = self.sharedDataController.selectedAccountAssetSortingAlgorithm
                self.assetListScreen.reloadData(order)
            }

            self.dismiss(animated: true)
        }

        open(
            .sortAccountAsset(
                dataController: SortAccountAssetListLocalDataController(
                    session: session!,
                    sharedDataController: sharedDataController
                ),
                eventHandler: eventHandler
            ),
            by: .present
        )
    }
    
    func managementOptionsViewControllerDidTapFilterAssets(
        _ managementOptionsViewController: ManagementOptionsViewController
    ) {
        var uiInteractions = AssetsFilterSelectionViewController.UIInteractions()
        uiInteractions.didComplete = {
            [unowned self] in

            let filters = AssetFilterOptions()
            self.assetListScreen.reloadData(filters)

            self.dismiss(animated: true)
        }
        uiInteractions.didCancel =  {
            [unowned self] in
            self.dismiss(animated: true)
        }
        
        open(
            .assetsFilterSelection(uiInteractions: uiInteractions),
            by: .present
        )
    }

    func managementOptionsViewControllerDidTapRemove(
        _ managementOptionsViewController: ManagementOptionsViewController
    ) {
        let aRawAccount = accountHandle.value
        if aRawAccount.authorization.isNoAuth {
            presentActionsNotAvailableForAccountBanner()
            return
        }

        let dataController = ManageAssetListLocalDataController(
            account: accountHandle.value,
            sharedDataController: sharedDataController
        )

        let controller = open(
            .removeAsset(dataController: dataController),
            by: .present
        ) as? ManageAssetListViewController
        controller?.navigationController?.presentationController?.delegate = assetListScreen
    }
    
    func managementOptionsViewControllerDidTapFilterCollectibles(
        _ managementOptionsViewController: ManagementOptionsViewController
    ) {}
}

extension AccountDetailViewController {
    private func createAssetListScreen() -> AccountAssetListViewController {
        let query = AccountAssetListQuery(
            filteringBy: .init(),
            sortingBy: sharedDataController.selectedAccountAssetSortingAlgorithm
        )
        let vc = AccountAssetListViewController(
            query: query,
            dataController: dataController.assetListDataController,
            copyToClipboardController: copyToClipboardController,
            configuration: configuration,
            incomingASAsRequestsCount: incomingASAsRequestsCount
        )
        vc.tabBarHidden = false
        return vc
    }

    private func createCollectibleListScreen() -> AccountCollectibleListViewController {
        let query = CollectibleListQuery(
            filteringBy: .init(),
            sortingBy: sharedDataController.selectedCollectibleSortingAlgorithm
        )
        let vc = AccountCollectibleListViewController(
            account: accountHandle,
            query: query,
            dataController: dataController.collectibleListDataController,
            copyToClipboardController: copyToClipboardController,
            configuration: configuration
        )
        vc.tabBarHidden = false
        return vc
    }
    
    private func createTransactionListScreen() -> AccountTransactionListViewController {
        let vc = AccountTransactionListViewController(
           draft: AccountTransactionListing(accountHandle: accountHandle),
           copyToClipboardController: copyToClipboardController,
           configuration: configuration
       )
        vc.tabBarHidden = false
        return vc
    }
}

extension AccountDetailViewController {
    struct AssetListPageBarItem: PageBarItem {
        let id: String
        let barButtonItem: PageBarButtonItem
        let screen: UIViewController

        init(screen: UIViewController) {
            self.id = AccountDetailPageBarItemID.assets.rawValue
            self.barButtonItem = PrimaryPageBarButtonItem(title: String(localized: "accounts-title-overview"))
            self.screen = screen
        }
    }

    struct CollectibleListPageBarItem: PageBarItem {
        let id: String
        let barButtonItem: PageBarButtonItem
        let screen: UIViewController

        init(screen: UIViewController) {
            self.id = AccountDetailPageBarItemID.collectibles.rawValue
            self.barButtonItem = PrimaryPageBarButtonItem(title: String(localized: "title-collectibles"))
            self.screen = screen
        }
    }

    struct TransactionListPageBarItem: PageBarItem {
        let id: String
        let barButtonItem: PageBarButtonItem
        let screen: UIViewController

        init(screen: UIViewController) {
            self.id = AccountDetailPageBarItemID.transactions.rawValue
            self.barButtonItem = PrimaryPageBarButtonItem(title: String(localized: "accounts-title-history"))
            self.screen = screen
        }
    }

    enum AccountDetailPageBarItemID: String {
        case assets
        case collectibles
        case transactions
    }
}

extension AccountDetailViewController {
    enum Event {
        case didEdit
        case didRemove
        case didBackUp
    }
}
