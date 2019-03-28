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
        
    }
    
    func optionsViewControllerDidSetDefaultAccount(_ optionsViewController: OptionsViewController) {
        
    }
    
    func optionsViewControllerDidViewPassphrase(_ optionsViewController: OptionsViewController) {
        
    }
    
    func optionsViewControllerDidEditAccountName(_ optionsViewController: OptionsViewController) {
        openEditAccountModalView()
    }
    
    private func openEditAccountModalView() {
        open(
            .editAccount,
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
