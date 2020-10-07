//
//  Screen.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 14.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

indirect enum Screen {
    case introduction(flow: AccountSetupFlow)
    case choosePassword(mode: ChoosePasswordViewController.Mode, flow: AccountSetupFlow?, route: Screen?)
    case localAuthenticationPreference(flow: AccountSetupFlow)
    case passphraseView(address: String)
    case passphraseVerify
    case accountNameSetup
    case accountRecover(flow: AccountSetupFlow)
    case qrScanner
    case qrGenerator(title: String?, draft: QRCreationDraft)
    case home(route: Screen?)
    case assetDetail(account: Account, assetDetail: AssetDetail?)
    case options(account: Account)
    case accountList(mode: AccountListViewController.Mode)
    case editAccount(account: Account)
    case contactSelection
    case addContact(mode: AddContactViewController.Mode)
    case contactDetail(contact: Contact)
    case sendAlgosTransactionPreview(account: Account?, receiver: AssetReceiverState, isSenderEditable: Bool)
    case sendAssetTransactionPreview(
        account: Account?,
        receiver: AssetReceiverState,
        assetDetail: AssetDetail,
        isSenderEditable: Bool,
        isMaxTransaction: Bool
    )
    case sendAlgosTransaction(
        algosTransactionSendDraft: AlgosTransactionSendDraft,
        transactionController: TransactionController,
        receiver: AssetReceiverState,
        isSenderEditable: Bool
    )
    case sendAssetTransaction(
        assetTransactionSendDraft: AssetTransactionSendDraft,
        transactionController: TransactionController,
        receiver: AssetReceiverState,
        isSenderEditable: Bool
    )
    case requestAlgosTransaction(isPresented: Bool, algosTransactionRequestDraft: AlgosTransactionRequestDraft)
    case requestAssetTransaction(isPresented: Bool, assetTransactionRequestDraft: AssetTransactionRequestDraft)
    case nodeSettings
    case addNode
    case editNode(node: Node)
    case transactionDetail(account: Account, transaction: Transaction, transactionType: TransactionType, assetDetail: AssetDetail?)
    case feedback
    case addAsset(account: Account)
    case removeAsset(account: Account)
    case assetActionConfirmation(assetAlertDraft: AssetAlertDraft)
    case assetSupport(assetAlertDraft: AssetAlertDraft)
    case bottomInformation(mode: BottomInformationViewController.Mode, configurator: BottomInformationBundle)
    case rewardDetail(account: Account)
    case verifiedAssetInformation
    case ledgerTutorial(flow: AccountSetupFlow)
    case ledgerDeviceList(flow: AccountSetupFlow)
    case ledgerTroubleshoot
    case ledgerApproval(mode: LedgerApprovalViewController.Mode)
    case ledgerTroubleshootBluetooth
    case ledgerTroubleshootLedgerConnection
    case ledgerTroubleshootInstallApp
    case ledgerTroubleshootOpenApp
    case termsAndServices
    case selectAsset(transactionAction: TransactionAction, filterOption: SelectAssetViewController.FilterOption = .none)
    case passphraseDisplay(address: String)
    case tooltip(title: String)
    case assetDetailNotification(address: String, assetId: Int64?)
    case assetActionConfirmationNotification(address: String, assetId: Int64?)
    case transactionFilter(filterOption: TransactionFilterViewController.FilterOption = .allTime)
    case transactionFilterCustomRange(fromDate: Date?, toDate: Date?)
    case pinLimit
    case rekeyInstruction(account: Account)
    case rekeyConfirmation(account: Account, ledger: LedgerDetail, ledgerAddress: String)
    case ledgerAccountSelection(flow: AccountSetupFlow, ledger: LedgerDetail, ledgerAddress: String)
    case developerSettings
    case currencySelection
    case watchAccountAddition(flow: AccountSetupFlow)
    case accountTypeSelection(flow: AccountSetupFlow)
    case languageSelection
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
