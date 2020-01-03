//
//  Screen.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 14.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

indirect enum Screen {
    case introduction(mode: AccountSetupMode)
    case choosePassword(mode: ChoosePasswordViewController.Mode, route: Screen?)
    case localAuthenticationPreference
    case passphraseView(address: String)
    case passPhraseVerify
    case accountNameSetup
    case accountRecover(mode: AccountSetupMode)
    case qrScanner
    case qrGenerator(title: String?, address: String, mnemonic: String? = nil, mode: QRMode)
    case home(route: Screen?)
    case assetDetail(account: Account, assetDetail: AssetDetail?)
    case options(account: Account)
    case accountList(mode: AccountListViewController.Mode)
    case editAccount(account: Account)
    case contactSelection
    case addContact(mode: AddContactViewController.Mode)
    case contactDetail(contact: Contact)
    case contactQRDisplay(contact: Contact)
    case sendAlgosTransactionPreview(account: Account?, receiver: AlgosReceiverState)
    case sendAssetTransactionPreview(
        account: Account?,
        receiver: AlgosReceiverState,
        assetDetail: AssetDetail,
        isMaxTransaction: Bool = false
    )
    case sendTransaction(algosTransaction: TransactionPreviewDraft?, assetTransaction: AssetTransactionDraft?, receiver: AlgosReceiverState)
    case requestTransactionPreview(account: Account, assetDetail: AssetDetail?, isAlgoTransaction: Bool)
    case requestTransaction(transaction: TransactionPreviewDraft)
    case historyResults(draft: HistoryDraft)
    case nodeSettings(mode: NodeSettingsViewController.Mode)
    case addNode
    case editNode(node: Node)
    case splash
    case transactionDetail(account: Account, transaction: Transaction, transactionType: TransactionType, assetDetail: AssetDetail?)
    case auctionDetail(auction: Auction, user: AuctionUser, activeAuction: ActiveAuction)
    case pastAuctionDetail(auction: Auction, user: AuctionUser, activeAuction: ActiveAuction)
    case balance(user: AuctionUser)
    case deposit(user: AuctionUser)
    case feedback
    case addAsset(account: Account)
    case removeAsset(account: Account)
    case assetActionConfirmation(assetAlertDraft: AssetAlertDraft)
    case assetSupportAlert(assetAlertDraft: AssetAlertDraft)
    case assetCancellableSupportAlert(assetAlertDraft: AssetAlertDraft)
    case rewardDetail(account: Account)
    case assetList(account: Account)
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
            case (.launch, .launch):
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
