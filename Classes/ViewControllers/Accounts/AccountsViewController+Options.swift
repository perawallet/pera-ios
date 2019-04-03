//
//  AccountsViewController+Options.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 28.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

extension AccountsViewController: OptionsViewControllerDelegate {
    
    func optionsViewControllerDidShowQR(_ optionsViewController: OptionsViewController) {
        guard let account = selectedAccount else {
            return
        }
        
        let text = account.address
        
        open(.qrGenerator(text: text, mode: .address), by: .present)
    }
    
    func optionsViewControllerDidSetDefaultAccount(_ optionsViewController: OptionsViewController) {
        guard let user = session?.authenticatedUser,
            let account = selectedAccount else {
            return
        }
        
        user.setDefaultAccount(account)
        
        displaySimpleAlertWith(title: "options-default-account-title".localized, message: "options-default-account-message".localized)
    }
    
    func optionsViewControllerDidViewPassphrase(_ optionsViewController: OptionsViewController) {
        if localAuthenticator.localAuthenticationStatus != .allowed {
            presentPassphraseView()
            return
        }
        
        displaySimpleAlertWith(
            title: "options-view-passphrase-alert-title".localized,
            message: "options-view-passphrase-alert-message".localized
        ) { _ in
            
            self.localAuthenticator.authenticate { error in
                guard error == nil else {
                    return
                }
                
                self.presentPassphraseView()
            }
        }
    }
    
    private func presentPassphraseView() {
        guard let account = self.selectedAccount else {
            return
        }
        
        let viewController = PassphraseDisplayViewController(account: account, configuration: configuration)
        viewController.modalPresentationStyle = .overCurrentContext
        viewController.modalTransitionStyle = .crossDissolve
        
        tabBarController?.present(viewController, animated: true, completion: nil)
    }
    
    func optionsViewControllerDidEditAccountName(_ optionsViewController: OptionsViewController) {
        openEditAccountModalView()
    }
    
    private func openEditAccountModalView() {
        guard let selectedAccount = self.selectedAccount else {
            return
        }
        
        open(
            .editAccount(account: selectedAccount),
            by: .customPresent(
                presentationStyle: .custom,
                transitionStyle: nil,
                transitioningDelegate: editAccountModalPresenter
            )
        )
    }
    
    func optionsViewControllerDidRemoveAccount(_ optionsViewController: OptionsViewController) {
        displayRemoveAccountAlert()
    }
    
    private func displayRemoveAccountAlert() {
        let configurator = AlertViewConfigurator(
            title: "options-remove-account".localized,
            image: img("remove-account-alert-icon"),
            explanation: "options-remove-alert-explanation".localized,
            actionTitle: "title-remove".localized) {
                
                guard let user = self.session?.authenticatedUser,
                    let account = self.selectedAccount,
                    let index = user.index(of: account) else {
                        return
                }
                
                user.removeAccount(account)
                
                guard !user.accounts.isEmpty else {
                    self.session?.reset()
                    
                    self.tabBarController?.open(.introduction(mode: .initialize), by: .launch, animated: false)
                    
                    return
                }
                
                defer {
                    self.session?.authenticatedUser = user
                }
                
                let newSelectedAccount: Account?
                if user.accounts.count == 1 {
                    newSelectedAccount = user.account(at: 0)
                } else {
                    if index == user.accounts.count {
                        newSelectedAccount = user.account(at: index.advanced(by: -1))
                    } else {
                        newSelectedAccount = user.account(at: index)
                    }
                }
                
                guard let newDefaultAccount = newSelectedAccount else {
                    return
                }
                
                self.selectedAccount = newDefaultAccount
                
                if user.isDefaultAccount(newDefaultAccount) {
                    user.setDefaultAccount(newDefaultAccount)
                }
        }
        
        let viewController = AlertViewController(mode: .destructive, alertConfigurator: configurator, configuration: configuration)
        viewController.modalPresentationStyle = .overCurrentContext
        viewController.modalTransitionStyle = .crossDissolve
        
        tabBarController?.present(viewController, animated: true, completion: nil)
    }
}
