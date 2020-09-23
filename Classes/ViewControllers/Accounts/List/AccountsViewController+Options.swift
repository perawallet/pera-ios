//
//  AccountsViewController+Options.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 12.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

extension AccountsViewController: OptionsViewControllerDelegate {
    func optionsViewControllerDidOpenRekeying(_ optionsViewController: OptionsViewController) {
        guard let account = selectedAccount else {
            return
        }
        
        open(
            .rekeyInstruction(account: account),
            by: .customPresent(
                presentationStyle: .fullScreen,
                transitionStyle: nil,
                transitioningDelegate: nil
            )
        )
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
            let controller = open(.choosePassword(mode: .confirm(""), flow: nil, route: nil), by: .present) as? ChoosePasswordViewController
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
        
        open(
            .passphraseDisplay(address: account.address),
            by: .customPresent(
                presentationStyle: .custom,
                transitionStyle: nil,
                transitioningDelegate: passphraseModalPresenter
            )
        )
    }
    
    func optionsViewControllerDidViewRekeyInformation(_ optionsViewController: OptionsViewController) {
        guard let authAddress = selectedAccount?.authAddress else {
            return
        }
        
        let draft = QRCreationDraft(address: authAddress, mode: .address)
        open(.qrGenerator(title: "options-auth-account".localized, draft: draft), by: .present)
    }
    
    func optionsViewControllerDidRemoveAccount(_ optionsViewController: OptionsViewController) {
        displayRemoveAccountAlert()
    }
    
    private func displayRemoveAccountAlert() {
        let configurator = BottomInformationBundle(
            title: "options-remove-account".localized,
            image: img("img-remove-account"),
            explanation: "options-remove-alert-explanation".localized,
            actionTitle: "options-remove-account".localized,
            actionImage: img("bg-button-red"),
            closeTitle: "title-keep".localized) {
                guard let user = self.session?.authenticatedUser,
                    let account = self.selectedAccount,
                    let accountInformation = self.session?.accountInformation(from: account.address) else {
                        return
                }
                
                self.session?.removeAccount(account)
                user.removeAccount(accountInformation)
                
                guard !user.accounts.isEmpty else {
                    self.session?.reset(isContactIncluded: false)
                    self.tabBarContainer?.open(.introduction(flow: .initializeAccount(mode: nil)), by: .launch, animated: false)
                    return
                }

                self.session?.authenticatedUser = user
        }
        
        open(
            .bottomInformation(mode: .action, configurator: configurator),
            by: .customPresent(
                presentationStyle: .custom,
                transitionStyle: nil,
                transitioningDelegate: removeAccountModalPresenter
            )
        )
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
