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
//  Screen.swift

import UIKit

indirect enum Screen {
    case asaDetail(
        account: Account,
        asset: Asset,
        configuration: ASADetailScreenConfiguration? = nil
    )
    case asaDiscovery(
        account: Account?,
        quickAction: AssetQuickAction?,
        asset: AssetDecoration,
        eventHandler: ASADiscoveryScreen.EventHandler? = nil
    )
    case welcome(flow: AccountSetupFlow)
    case addAccount(flow: AccountSetupFlow)
    case mnemonicTypeSelection(eventHandler: MnemonicTypeSelectionScreen.EventHandler)
    case recoverAccount(flow: AccountSetupFlow)
    case recoverAccountsLoadingScreen
    case choosePassword(mode: ChoosePasswordViewController.Mode, flow: AccountSetupFlow?)
    case passphraseView(flow: AccountSetupFlow, address: String, walletFlowType: WalletFlowType)
    case passphraseVerify(flow: AccountSetupFlow, address: String, walletFlowType: WalletFlowType)
    case accountNameSetup(flow: AccountSetupFlow,  mode: AccountSetupMode, nameServiceName: String? = nil, accountAddress: PublicKey)
    case accountRecover(flow: AccountSetupFlow, walletFlowType: WalletFlowType = .algo25, initialMnemonic: String? = nil)
    case addressNameSetup(flow: AccountSetupFlow, mode: AccountSetupMode, nameServiceName: String? = nil, account: AccountInformation)
    case hdWalletSetup(flow: AccountSetupFlow, mode: AccountSetupMode)
    case selectAddress(recoveredAddresses: [RecoveredAddress], hdWalletId: String)
    case rescanRekeyedAccountsSelectList(inputData: [RecoveredAccountsListModel.InputData], nextStep: RecoveredAccountsListView.NextStep)
    case qrScanner(canReadWCSession: Bool)
    case qrGenerator(title: String?, draft: QRCreationDraft, isTrackable: Bool = false)
    case accountDetail(accountHandle: AccountHandle, eventHandler: AccountDetailViewController.EventHandler, incomingASAsRequestsCount: Int)
    case options(account: Account, delegate: OptionsViewControllerDelegate)
    case accountList(mode: AccountListViewController.Mode, delegate: AccountListViewControllerDelegate)
    case renameAccount(account: Account, delegate: RenameAccountScreenDelegate)
    case contacts
    case notifications
    case addContact(address: String? = nil, name: String? = nil)
    case editContact(contact: Contact)
    case contactDetail(contact: Contact)
    case nodeSettings
    case settings
    case transactionDetail(
        account: Account,
        transaction: Transaction,
        assetDetail: Asset?
    )
    case appCallTransactionDetail(
        account: Account,
        transaction: Transaction,
        transactionTypeFilter: TransactionTypeFilter,
        assets: [Asset]?
    )
    case appCallAssetList(
        dataController: AppCallAssetListDataController
    )
    case keyRegTransactionDetail(
        account: Account,
        transaction: Transaction
    )
    case addAsset(account: Account)
    case removeAsset(dataController: ManageAssetListDataController)
    case managementOptions(
        managementType: ManagementOptionsViewController.ManagementType,
        delegate: ManagementOptionsViewControllerDelegate
    )
    case assetActionConfirmation(
        assetAlertDraft: AssetAlertDraft,
        delegate: AssetActionConfirmationViewControllerDelegate?,
        theme: AssetActionConfirmationViewControllerTheme = .init()
    )
    case rewardDetail(account: Account)
    case ledgerTutorial(flow: AccountSetupFlow)
    case ledgerDeviceList(flow: AccountSetupFlow)
    case passphraseDisplay(address: Account)
    case assetDetailNotification(address: String, assetId: Int64?)
    case assetActionConfirmationNotification(address: String, assetId: Int64?)
    case transactionFilter(filterOption: TransactionFilterViewController.FilterOption = .allTime, delegate: TransactionFilterViewControllerDelegate)
    case transactionFilterCustomRange(fromDate: Date?, toDate: Date?)
    case pinLimit
    case rekeyToStandardAccountInstructions(sourceAccount: Account)
    case rekeyToLedgerAccountInstructions(sourceAccount: Account)
    case rekeyConfirmation(sourceAccount: Account, authAccount: Account? = nil, newAuthAccount: Account)
    case rekeySuccess(sourceAccount: Account, eventHandler: RekeySuccessScreen.EventHandler)
    case undoRekey(sourceAccount: Account, authAccount: Account)
    case undoRekeySuccess(sourceAccount: Account, eventHandler: UndoRekeySuccessScreen.EventHandler)
    case rekeyAccountSelection(
        eventHandler: AccountSelectionListScreen<RekeyAccountSelectionListLocalDataController>.EventHandler,
        account: Account
    )
    case ledgerAccountSelection(flow: AccountSetupFlow, accounts: [Account])
    case walletRating
    case securitySettings
    case developerSettings
    case currencySelection
    case appearanceSelection
    case watchAccountAddition(
        flow: AccountSetupFlow,
        address: String? = nil
    )
    case ledgerAccountDetail(account: Account, authAccount: Account, ledgerIndex: Int?, rekeyedAccounts: [Account]?)
    case notificationFilter
    case bottomWarning(configurator: BottomWarningViewConfigurator)
    case tutorial(flow: AccountSetupFlow, tutorial: Tutorial, walletFlowType: WalletFlowType? = nil)
    case tutorialSteps(step: Troubleshoot.Step)
    case transactionTutorial(isInitialDisplay: Bool)
    case recoverOptions(delegate: AccountRecoverOptionsViewControllerDelegate)
    case ledgerAccountVerification(flow: AccountSetupFlow, selectedAccounts: [Account])
    case wcConnection(draft: WCSessionConnectionDraft, isAccountMultiselectionEnabled: Bool)
    case walletConnectSessionList
    case walletConnectSessionShortList
    case wcTransactionFullDappDetail(configurator: WCTransactionFullDappDetailConfigurator)
    case wcAlgosTransaction(
        transaction: WCTransaction,
        transactionRequest: WalletConnectRequestDraft,
        wcSession: WCSessionDraft
    )
    case wcAssetTransaction(
        transaction: WCTransaction,
        transactionRequest: WalletConnectRequestDraft,
        wcSession: WCSessionDraft
    )
    case wcAssetAdditionTransaction(
        transaction: WCTransaction,
        transactionRequest: WalletConnectRequestDraft,
        wcSession: WCSessionDraft
    )
    case wcGroupTransaction(
        transactions: [WCTransaction],
        transactionRequest: WalletConnectRequestDraft,
        wcSession: WCSessionDraft
    )
    case wcAppCall(
        transaction: WCTransaction,
        transactionRequest: WalletConnectRequestDraft,
        wcSession: WCSessionDraft
    )
    case wcAssetCreationTransaction(
        transaction: WCTransaction,
        transactionRequest: WalletConnectRequestDraft,
        wcSession: WCSessionDraft
    )
    case wcAssetReconfigurationTransaction(
        transaction: WCTransaction,
        transactionRequest: WalletConnectRequestDraft,
        wcSession: WCSessionDraft
    )
    case wcAssetDeletionTransaction(
        transaction: WCTransaction,
        transactionRequest: WalletConnectRequestDraft,
        wcSession: WCSessionDraft
    )
    case wcKeyRegTransaction(
        transaction: WCTransaction,
        transactionRequest: WalletConnectRequestDraft,
        wcSession: WCSessionDraft
    )
    case jsonDisplay(jsonData: Data, title: String)
    
    case incomingASAAccounts(
        result: IncomingASAsRequestList?
    )
    case incomingASA(
        address: String,
        requestsCount: Int
    )
    case incomingASAsDetail(draft: IncomingASAListItem)
    case successResultScreen(
        viewModel: SuccessResultScreenViewModel,
        theme: SuccessResultScreenViewTheme = SuccessResultScreenTheme()
    )
    case ledgerPairWarning(delegate: LedgerPairWarningViewControllerDelegate)
    case sortAccountList(
        dataController: SortAccountListDataController,
        eventHandler: SortAccountListViewController.EventHandler
    )
    case accountSelection(
        draft: SelectAccountDraft,
        delegate: SelectAccountViewControllerDelegate?,
        shouldFilterAccount: ((Account) -> Bool)? = nil
    )
    case assetSelection(
        account: Account,
        receiver: String? = nil
    )
    case sendTransaction(draft: SendTransactionDraft)
    case editNote(note: String?, isLocked: Bool, delegate: EditNoteScreenDelegate?)
    case portfolioCalculationInfo(result: PortfolioValue?, eventHandler: PortfolioCalculationInfoViewController.EventHandler)
    case invalidAccount(
        account: AccountHandle,
        uiInteractionsHandler: InvalidAccountOptionsViewController.InvalidAccountOptionsUIInteractions
    )
    case transactionResult
    case sendAssetAndOptInTransactionInfo
    case sendTransactionPreview(draft: TransactionSendDraft)
    case wcMainTransactionScreen(
        draft: WalletConnectTransactionSignRequestDraft,
        delegate: WCMainTransactionScreenDelegate
    )
    case wcMainArbitraryDataScreen(
        draft: WalletConnectArbitraryDataSignRequestDraft,
        delegate: WCMainArbitraryDataScreenDelegate
    )
    case wcArbitraryDataScreen(data: WCArbitraryData, wcSession: WCSessionDraft)
    case asaVerificationInfo(EventHandler<AsaVerificationInfoEvent>)
    case sortCollectibleList(
        dataController: SortCollectibleListDataController,
        eventHandler: SortCollectibleListViewController.EventHandler
    )
    case accountCollectibleListFilterSelection(uiInteractions: AccountCollectibleListFilterSelectionViewController.UIInteractions)
    case collectiblesFilterSelection(uiInteractions: CollectiblesFilterSelectionViewController.UIInteractions)
    case receiveCollectibleAccountList(
        dataController: ReceiveCollectibleAccountListDataController
    )
    case receiveCollectibleAssetList(account: AccountHandle)
    case collectibleList
    case collectibleDetail(
        asset: CollectibleAsset,
        account: Account,
        thumbnailImage: UIImage? = nil,
        quickAction: AssetQuickAction? = nil,
        eventHandler: CollectibleDetailViewController.EventHandler? = nil
    )
    case sendCollectible(draft: SendCollectibleDraft)
    case sendCollectibleReceiverAccountSelectionList(
        addressInputViewText: String?
    )
    case sendAssetReceiverAccountSelectionList(
        asset: Asset?,
        addressInputViewText: String?
    )
    case approveCollectibleTransaction(draft: SendCollectibleDraft)
    case shareActivity(items: [Any], excludedActivityTypes: [UIActivity.ActivityType]?)
    case image3DCard(
        image: UIImage,
        rendersContinuously: Bool
    )
    case video3DCard(
        image: UIImage?,
        url: URL
    )
    case collectibleFullScreenImage(draft: CollectibleFullScreenImageDraft)
    case collectibleFullScreenVideo(draft: CollectibleFullScreenVideoDraft)
    case transactionOptions(account: Account, delegate: TransactionOptionsScreenDelegate?)
    case qrScanOptions(
        address: PublicKey,
        eventHandler: QRScanOptionsViewController.EventHandler
    )
    case assetsFilterSelection(uiInteractions: AssetsFilterSelectionViewController.UIInteractions)
    case sortAccountAsset(
        dataController: SortAccountAssetListDataController,
        eventHandler: SortAccountAssetListViewController.EventHandler
    )
    case innerTransactionList(
        dataController: InnerTransactionListDataController,
        eventHandler: InnerTransactionListViewController.EventHandler
    )
    case swapAsset(
        dataStore: SwapAmountPercentageStore & SwapMutableAmountPercentageStore,
        swapController: SwapController,
        coordinator: SwapAssetFlowCoordinator
    )
    case swapAccountSelection(
        swapAssetFlowCoordinator: SwapAssetFlowCoordinator,
        eventHandler: AccountSelectionListScreen<SwapAccountSelectionListLocalDataController>.EventHandler
    )
    case ledgerConnection(eventHandler: LedgerConnectionScreen.EventHandler)
    case signWithLedgerProcess(
        draft: SignWithLedgerProcessDraft,
        eventHandler: SignWithLedgerProcessScreen.EventHandler
    )
    case loading(
        viewModel: LoadingScreenViewModel,
        theme: LoadingScreenTheme = .init()
    )
    case error(
        viewModel: ErrorScreenViewModel,
        theme: ErrorScreenTheme = .init()
    )
    case swapSuccess(
        swapController: SwapController,
        theme: SwapAssetSuccessScreenTheme = .init()
    )
    case swapSummary(
        swapController: SwapController,
        theme: SwapSummaryScreenTheme = .init()
    )
    case alert(alert: Alert)
    case swapIntroduction(
        draft: SwapIntroductionDraft,
        eventHandler: EventHandler<SwapIntroductionEvent>
    )
    case optInAsset(
        draft: OptInAssetDraft,
        eventHandler: OptInAssetScreen.EventHandler
    )
    case optOutAsset(
        draft: OptOutAssetDraft,
        theme: OptOutAssetScreenTheme = .init(),
        eventHandler: OptOutAssetScreen.EventHandler
    )
    case transferAssetBalance(
        draft: TransferAssetBalanceDraft,
        theme: TransferAssetBalanceScreenTheme = .init(),
        eventHandler: TransferAssetBalanceScreen.EventHandler
    )
    case sheetAction(
        sheet: UISheet,
        theme: UISheetActionScreenTheme = UISheetActionScreenCommonTheme()
    )
    case insufficientAlgoBalance(
        draft: InsufficientAlgoBalanceDraft,
        eventHandler: InsufficientAlgoBalanceScreen.EventHandler
    )
    case selectAsset(
        dataController: SelectAssetDataController,
        coordinator: SwapAssetFlowCoordinator?,
        title: String,
        theme: SelectAssetScreenTheme = .init()
    )
    case confirmSwap(
        dataStore: SwapSlippageTolerancePercentageStore,
        dataController: ConfirmSwapDataController,
        eventHandler: EventHandler<ConfirmSwapScreen.Event>,
        theme: ConfirmSwapScreenTheme = .init()
    )
    /// <todo>
    /// We should find a way to define the EventHandler decoupled to the actual screen when we
    /// refactor the routing mechanism.
    case editSwapAmount(
        dataStore: SwapAmountPercentageStore & SwapMutableAmountPercentageStore,
        eventHandler: EditSwapAmountScreen.EventHandler
    )
    case editSwapSlippage(
        dataStore: SwapSlippageTolerancePercentageStore & SwapMutableSlippageTolerancePercentageStore,
        eventHandler: EditSwapSlippageScreen.EventHandler
    )
    case discoverSearch(DiscoverSearchScreen.EventHandler)
    case discoverAssetDetail(DiscoverAssetParameters)
    case discoverDappDetail(
        DiscoverDappParamaters,
        eventHandler: DiscoverExternalInAppBrowserScreen.EventHandler?
    )
    case discoverGeneric(DiscoverGenericParameters)
    case importAccountIntroduction(WebImportInstructionScreen.EventHandler)
    case importAccountQRScanner(ImportQRScannerScreen.EventHandler)
    case importAccount(ImportAccountScreen.ImportAccountRequest, ImportAccountScreen.EventHandler)
    case importAccountError(ImportAccountScreenError, WebImportErrorScreen.EventHandler)
    case importAccountSuccess(result: ImportAccountScreen.Result, eventHandler: WebImportSuccessScreen.EventHandler)
    case algorandSecureBackupInstructions(eventHandler: AlgorandSecureBackupInstructionsScreen.EventHandler)
    case algorandSecureBackupMnemonic(accounts: [Account], eventHandler: AlgorandSecureBackupMnemonicsScreen.EventHandler)
    case algorandSecureBackupSuccess(backup: AlgorandSecureBackup, eventHandler: AlgorandSecureBackupSuccessScreen.EventHandler)
    case algorandSecureBackupError(eventHandler: AlgorandSecureBackupErrorScreen.EventHandler)
    case algorandSecureBackupImportBackup(eventHandler: AlgorandSecureBackupImportBackupScreen.EventHandler)
    case algorandSecureBackupImportSuccess(
        accountImportParameters: [AccountImportParameters],
        selectedAccounts: [Account],
        eventHandler: WebImportSuccessScreen.EventHandler
    )
    case algorandSecureBackupRecoverMnemonic(backup: SecureBackup, eventHandler: AlgorandSecureBackupRecoverMnemonicScreen.EventHandler)
    case importTextDocumentPicker(delegate: UIDocumentPickerDelegate)
    case buySellOptions(eventHandler: BuySellOptionsScreen.EventHandler)
    case bidaliIntroduction
    case bidaliDappDetail(account: AccountHandle)
    case bidaliAccountSelection(
        eventHandler: AccountSelectionListScreen<BidaliAccountSelectionListLocalDataController>.EventHandler
    )
    case moonPayIntroduction(
        draft: MoonPayDraft,
        delegate: MoonPayIntroductionScreenDelegate?
    )
    case moonPayAccountSelection(
        eventHandler: AccountSelectionListScreen<MoonPayAccountSelectionListLocalDataController>.EventHandler
    )
    case moonPayTransaction(moonPayParams: MoonPayParams)
    case meldAccountSelection(
        eventHandler: AccountSelectionListScreen<MeldAccountSelectionListLocalDataController>.EventHandler
    )
    case meldDappDetail(address: PublicKey)
    case standardAccountInformation(account: Account)
    case watchAccountInformation(account: Account)
    case ledgerAccountInformation(account: Account)
    case noAuthAccountInformation(account: Account)
    case rekeyedAccountInformation(sourceAccount: Account, authAccount: Account)
    case anyToNoAuthRekeyedAccountInformation(account: Account)
    case rekeyedAccountSelectionList(
        authAccount: Account,
        rekeyedAccounts: [Account],
        eventHandler: RekeyedAccountSelectionListScreen.EventHandler
    )
    case undoRekeyConfirmation(
        sourceAccount: Account,
        authAccount: Account,
        eventHandler: UndoRekeyConfirmationSheet.EventHandler
    )
    case overwriteRekeyConfirmation(
        sourceAccount: Account,
        authAccount: Account,
        eventHandler: OverwriteRekeyConfirmationSheet.EventHandler
    )
    case backUpBeforeRemovingAccountWarning(eventHandler: BackUpBeforeRemovingAccountWarningSheet.EventHandler)
    case removeAccount(
        account: Account,
        eventHandler: RemoveAccountSheet.EventHandler
    )
    case externalInAppBrowser(destination: DiscoverExternalDestination)
    case extendWCSessionValidity(
        wcV2Session: WalletConnectV2Session,
        eventHandler: ExtendWCSessionValiditySheet.EventHandler
    )
    case wcAdvancedPermissionsInfo(eventHandler: WCAdvancedPermissionsInfoSheet.EventHandler)
    case wcSessionDetail(draft: WCSessionDraft)
    case wcSessionConnectionSuccessful(
        draft: WCSessionDraft,
        eventHandler: WCSessionConnectionSuccessfulSheet.EventHandler
    )
    case wcTransactionSignSuccessful(
        draft: WCSessionDraft,
        eventHandler: WCTransactionSignSuccessfulSheet.EventHandler
    )
    case backUpAccountSelection(
        eventHandler: AccountSelectionListScreen<BackUpAccountSelectionListLocalDataController>.EventHandler
    )
    case staking
    case cards(path: String?)
    case sendAssetInbox(draft: SendAssetInboxDraft)
    case sendKeyRegTransaction(
        account: Account,
        transactionDraft: KeyRegTransactionSendDraft
    )
    case inviteFriends(eventHandler: InviteFriendsScreen.EventHandler)
    case passphraseWarning(eventHandler: PassphraseWarningScreen.EventHandler)
    case rekeyTransactionOverlay(variant: RekeySupportOverlayView.Variant, onPrimaryAction: (() -> Void)?)
}

extension Screen {
    enum Transition { }
}

extension Screen.Transition {
    enum Open: Equatable {
        case root
        case push
        case present
        case presentWithoutNavigationController
        case launch
        case set
        case customPresent(
            presentationStyle: UIModalPresentationStyle?,
            transitionStyle: UIModalTransitionStyle?,
            transitioningDelegate: UIViewControllerTransitioningDelegate?)
        case customPresentWithoutNavigationController(
            presentationStyle: UIModalPresentationStyle?,
            transitionStyle: UIModalTransitionStyle?,
            transitioningDelegate: UIViewControllerTransitioningDelegate?)
        
        static func == (lhs: Open, rhs: Open) -> Bool {
            switch (lhs, rhs) {
            case (.push, .push):
                return true
            case (.present, .present):
                return true
            case (.presentWithoutNavigationController, .presentWithoutNavigationController):
                return true
            case (.launch, .launch):
                return true
            case (.set, .set):
                return true
            case (.customPresent, .customPresent):
                return false
            case (.customPresentWithoutNavigationController, .customPresentWithoutNavigationController):
                return false
            default:
                return false
            }
        }
    }
    
    enum Close {
        case pop
        case dismiss
    }
}

extension Screen {
    typealias EventHandler<Event> = (Event) -> Void
}
