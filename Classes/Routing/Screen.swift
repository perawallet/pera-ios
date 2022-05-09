// Copyright 2022 Pera Wallet, LDA

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
    case welcome(flow: AccountSetupFlow)
    case addAccount(flow: AccountSetupFlow)
    case recoverAccount(flow: AccountSetupFlow)
    case choosePassword(mode: ChoosePasswordViewController.Mode, flow: AccountSetupFlow?)
    case passphraseView(flow: AccountSetupFlow, address: String)
    case passphraseVerify(flow: AccountSetupFlow)
    case accountNameSetup(flow: AccountSetupFlow,  mode: AccountSetupMode, accountAddress: PublicKey)
    case accountRecover(flow: AccountSetupFlow)
    case qrScanner(canReadWCSession: Bool)
    case qrGenerator(title: String?, draft: QRCreationDraft, isTrackable: Bool = false)
    case accountDetail(accountHandle: AccountHandle, eventHandler: AccountDetailViewController.EventHandler)
    case assetSearch(accountHandle: AccountHandle, dataController: AssetSearchDataController)
    case assetDetail(draft: TransactionListing)
    case algosDetail(draft: TransactionListing)
    case options(account: Account, delegate: OptionsViewControllerDelegate)
    case accountList(mode: AccountListViewController.Mode, delegate: AccountListViewControllerDelegate)
    case editAccount(account: Account, delegate: EditAccountViewControllerDelegate)
    case contacts
    case notifications
    case addContact(address: String? = nil, name: String? = nil)
    case editContact(contact: Contact)
    case contactDetail(contact: Contact)
    case nodeSettings
    case transactionDetail(account: Account, transaction: Transaction, transactionType: TransactionType, assetDetail: StandardAsset?)
    case addAsset(account: Account)
    case removeAsset(account: Account)
    case assetActionConfirmation(assetAlertDraft: AssetAlertDraft, delegate: AssetActionConfirmationViewControllerDelegate?)
    case rewardDetail(account: Account, calculatedRewards: Decimal)
    case verifiedAssetInformation
    case ledgerTutorial(flow: AccountSetupFlow)
    case ledgerDeviceList(flow: AccountSetupFlow)
    case ledgerApproval(mode: LedgerApprovalViewController.Mode, deviceName: String)
    case passphraseDisplay(address: String)
    case assetDetailNotification(address: String, assetId: Int64?)
    case assetActionConfirmationNotification(address: String, assetId: Int64?)
    case transactionFilter(filterOption: TransactionFilterViewController.FilterOption = .allTime, delegate: TransactionFilterViewControllerDelegate)
    case transactionFilterCustomRange(fromDate: Date?, toDate: Date?)
    case pinLimit
    case rekeyInstruction(account: Account)
    case rekeyConfirmation(account: Account, ledgerDetail: LedgerDetail?, ledgerAddress: String)
    case ledgerAccountSelection(flow: AccountSetupFlow, accounts: [Account])
    case walletRating
    case securitySettings
    case developerSettings
    case currencySelection
    case appearanceSelection
    case watchAccountAddition(flow: AccountSetupFlow)
    case ledgerAccountDetail(account: Account, ledgerIndex: Int?, rekeyedAccounts: [Account]?)
    case notificationFilter(flow: NotificationFilterViewController.Flow)
    case bottomWarning(configurator: BottomWarningViewConfigurator)
    case tutorial(flow: AccountSetupFlow, tutorial: Tutorial)
    case tutorialSteps(step: Troubleshoot.Step)
    case transactionTutorial(isInitialDisplay: Bool)
    case recoverOptions(delegate: AccountRecoverOptionsViewControllerDelegate)
    case ledgerAccountVerification(flow: AccountSetupFlow, selectedAccounts: [Account])
    case wcConnectionApproval(walletConnectSession: WalletConnectSession, delegate: WCConnectionApprovalViewControllerDelegate, completion: WalletConnectSessionConnectionCompletionHandler)
    case walletConnectSessionList
    case walletConnectSessionShortList
    case wcTransactionFullDappDetail(configurator: WCTransactionFullDappDetailConfigurator)
    case wcAlgosTransaction(transaction: WCTransaction, transactionRequest: WalletConnectRequest)
    case wcAssetTransaction(transaction: WCTransaction, transactionRequest: WalletConnectRequest)
    case wcAssetAdditionTransaction(transaction: WCTransaction, transactionRequest: WalletConnectRequest)
    case wcGroupTransaction(transactions: [WCTransaction], transactionRequest: WalletConnectRequest)
    case wcAppCall(transaction: WCTransaction, transactionRequest: WalletConnectRequest)
    case wcAssetCreationTransaction(transaction: WCTransaction, transactionRequest: WalletConnectRequest)
    case wcAssetReconfigurationTransaction(transaction: WCTransaction, transactionRequest: WalletConnectRequest)
    case wcAssetDeletionTransaction(transaction: WCTransaction, transactionRequest: WalletConnectRequest)
    case jsonDisplay(jsonData: Data, title: String)
    case ledgerPairWarning(delegate: LedgerPairWarningViewControllerDelegate)
    case accountListOptions(accountType: AccountType, eventHandler: AccountListOptionsViewController.EventHandler)
    case orderAccountList(accountType: AccountType, eventHandler: OrderAccountListViewController.EventHandler)
    case accountSelection(
        transactionAction: TransactionAction,
        delegate: SelectAccountViewControllerDelegate?
    )
    case assetSelection(filter: AssetType?, account: Account)
    case sendTransaction(draft: SendTransactionDraft)
    case editNote(note: String?, isLocked: Bool, delegate: EditNoteScreenDelegate?)
    case portfolioCalculationInfo(result: PortfolioCalculator.Result, eventHandler: PortfolioCalculationInfoViewController.EventHandler)
    case invalidAccount(
        account: AccountHandle,
        uiInteractionsHandler: InvalidAccountOptionsViewController.InvalidAccountOptionsUIInteractions
    )
    case transactionResult
    case transactionAccountSelect(draft: SendTransactionDraft)
    case sendTransactionPreview(draft: TransactionSendDraft, transactionController: TransactionController)
    case wcMainTransactionScreen(draft: WalletConnectRequestDraft, delegate: WCMainTransactionScreenDelegate)
    case transactionFloatingActionButton
    case wcSingleTransactionScreen(
        transactions: [WCTransaction],
        transactionRequest: WalletConnectRequest,
        transactionOption: WCTransactionOption?
    )
    case peraIntroduction
    case collectiblesFilterSelection(filter: CollectiblesFilterSelectionViewController.Filter)
    case receiveCollectibleAccountList(
        dataController: ReceiveCollectibleAccountListDataController
    )
    case receiveCollectibleAssetList(
        account: AccountHandle,
        dataController: ReceiveCollectibleAssetListDataController
    )
    case collectibleDetail(
        asset: CollectibleAsset,
        account: Account,
        thumbnailImage: UIImage?
    )
    case sendCollectible(draft: SendCollectibleDraft)
    case sendCollectibleAccountList(
        dataController: SendCollectibleAccountListDataController
    )
    case approveCollectibleTransaction(draft: SendCollectibleDraft)
    case shareActivity(items: [Any])
    case image3DCard(image: UIImage)
    case video3DCard(
        image: UIImage?,
        url: URL
    )
    case buyAlgoHome(
        transactionDraft: BuyAlgoDraft,
        delegate: BuyAlgoHomeScreenDelegate?
    )
    case buyAlgoTransaction(buyAlgoParams: BuyAlgoParams)
}

extension Screen {
    enum Transition {
    }
}

extension Screen.Transition {
    enum Open: Equatable {
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
