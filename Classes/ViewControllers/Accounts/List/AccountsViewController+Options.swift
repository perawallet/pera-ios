//
//  AccountsViewController+Options.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 12.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

extension AccountsViewController: OptionsViewControllerDelegate {
    func optionsViewControllerDidShowQR(_ optionsViewController: OptionsViewController) {
        guard let account = selectedAccount else {
            return
        }
        
        open(.qrGenerator(title: account.name, text: account.address, mode: .address), by: .present)
    }
    
    func optionsViewControllerDidRemoveAsset(_ optionsViewController: OptionsViewController) {
        guard let account = selectedAccount else {
            return
        }
        
        let controller = open(
            .removeAsset(account: account),
            by: .customPresent(
                presentationStyle: .fullScreen,
                transitionStyle: nil,
                transitioningDelegate: nil
            )
        ) as? AssetRemovalViewController
        controller?.delegate = self
    }
    
    func optionsViewControllerDidViewPassphrase(_ optionsViewController: OptionsViewController) {
        if localAuthenticator.localAuthenticationStatus != .allowed {
            let controller = open(.choosePassword(mode: .confirm(""), route: nil), by: .present) as? ChoosePasswordViewController
            controller?.delegate = self
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

        let viewController = PassphraseDisplayViewController(address: account.address, configuration: configuration)
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
                    let account = self.selectedAccount else {
                        return
                }

                user.removeAccount(account)

                guard !user.accounts.isEmpty else {
                    self.session?.reset()

                    self.tabBarController?.open(.introduction(mode: .initialize), by: .launch, animated: false)

                    return
                }

                self.session?.authenticatedUser = user
        }

        let viewController = AlertViewController(mode: .destructive, alertConfigurator: configurator, configuration: configuration)
        viewController.modalPresentationStyle = .overCurrentContext
        viewController.modalTransitionStyle = .crossDissolve

        if let alertView = viewController.alertView as? DestructiveAlertView {
            alertView.cancelButton.setTitleColor(.white, for: .normal)
            alertView.cancelButton.setBackgroundImage(img("bg-black-cancel"), for: .normal)
            alertView.actionButton.setTitleColor(.white, for: .normal)
            alertView.actionButton.setBackgroundImage(img("bg-orange-action"), for: .normal)
        }

        tabBarController?.present(viewController, animated: true, completion: nil)
    }
}

extension AccountsViewController: ChoosePasswordViewControllerDelegate {
    func choosePasswordViewController(_ choosePasswordViewController: ChoosePasswordViewController, didConfirmPassword isConfirmed: Bool) {
        if isConfirmed {
            presentPassphraseView()
        } else {
            displaySimpleAlertWith(
                title: "password-verify-fail-title".localized,
                message: "options-view-passphrase-password-alert-message".localized
            )
        }
    }
}

extension AccountsViewController: AssetRemovalViewControllerDelegate {
    func assetRemovalViewController(
        _ assetRemovalViewController: AssetRemovalViewController,
        didRemove assetDetail: AssetDetail,
        from account: Account
    ) {
        guard let section = accountsDataSource.section(for: account),
            let index = accountsDataSource.item(for: assetDetail, in: account) else {
            return
        }
        
        accountsDataSource.remove(assetDetail: assetDetail, from: account)
        accountsView.accountsCollectionView.reloadItems(at: [IndexPath(item: index + 1, section: section)])
    }
}
