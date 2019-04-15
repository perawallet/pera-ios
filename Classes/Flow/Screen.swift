//
//  Screen.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 14.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

enum Screen {
    case introduction(mode: AccountSetupMode)
    case welcome
    case choosePassword(mode: ChoosePasswordViewController.Mode)
    case localAuthenticationPreference
    case passPhraseBackUp
    case passPhraseVerify
    case accountNameSetup
    case accountRecover(mode: AccountSetupMode)
    case qrScanner
    case qrGenerator(title: String?, text: String, mode: QRMode)
    case home
    case options
    case accountList(mode: AccountListMode)
    case editAccount(account: Account)
    case contacts
    case addContact(mode: AddContactViewController.Mode)
    case contactDetail(contact: Contact)
    case contactQRDisplay(contact: Contact)
    case sendAlgos(receiver: AlgosReceiverState)
    case sendAlgosPreview(transaction: Transaction, receiver: AlgosReceiverState)
    case sendAlgosSuccess(transaction: Transaction, receiver: AlgosReceiverState)
    case receiveAlgos
    case receiveAlgosPreview(transaction: Transaction)
    case nodeSettings
    case addNode
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
        case customPresent(
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
