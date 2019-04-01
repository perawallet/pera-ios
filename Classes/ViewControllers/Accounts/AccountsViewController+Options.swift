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
        
        open(.qrGenerator(text: text, mode: .mnemonic), by: .present)
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
            actionTitle: "title-remove".localized
        )
        
        // TODO: Handle remove account action
        
        let viewController = AlertViewController(mode: .destructive, alertConfigurator: configurator, configuration: configuration)
        viewController.modalPresentationStyle = .overCurrentContext
        viewController.modalTransitionStyle = .crossDissolve
        
        tabBarController?.present(viewController, animated: true, completion: nil)
    }
}
