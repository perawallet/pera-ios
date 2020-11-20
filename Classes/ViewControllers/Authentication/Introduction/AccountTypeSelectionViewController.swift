//
//  AccountTypeSelectionViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 21.09.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class AccountTypeSelectionViewController: BaseViewController {
    
    private lazy var accountTypeSelectionView = AccountTypeSelectionView()
    
    private let flow: AccountSetupFlow
    
    init(flow: AccountSetupFlow, configuration: ViewControllerConfiguration) {
        self.flow = flow
        super.init(configuration: configuration)
    }
    
    override func configureNavigationBarAppearance() {
        let closeBarButtonItem = ALGBarButtonItem(kind: .close) { [unowned self] in
            self.closeScreen(by: .dismiss, animated: true)
        }
        
        switch flow {
        case .addNewAccount:
            leftBarButtonItems = [closeBarButtonItem]
        default:
            break
        }
    }
    
    override func configureAppearance() {
        view.backgroundColor = Colors.Background.tertiary
        setTertiaryBackgroundColor()
        title = "account-type-choose-title".localized
        accountTypeSelectionView.configureCreateNewAccountView(with: AccountTypeViewModel(accountSetupMode: .create))
        accountTypeSelectionView.configureWatchAccountView(with: AccountTypeViewModel(accountSetupMode: .watch))
        accountTypeSelectionView.configureRecoverAccountView(with: AccountTypeViewModel(accountSetupMode: .recover))
        accountTypeSelectionView.configurePairAccountView(with: AccountTypeViewModel(accountSetupMode: .pair))
    }
    
    override func linkInteractors() {
        accountTypeSelectionView.delegate = self
    }
    
    override func prepareLayout() {
        setupAccountTypeSelectionViewLayout()
    }
}

extension AccountTypeSelectionViewController {
    private func setupAccountTypeSelectionViewLayout() {
        view.addSubview(accountTypeSelectionView)
        
        accountTypeSelectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension AccountTypeSelectionViewController: AccountTypeSelectionViewDelegate {
    func accountTypeSelectionView(_ accountTypeSelectionView: AccountTypeSelectionView, didSelect mode: AccountSetupMode) {
        switch flow {
        case .initializeAccount:
            open(.choosePassword(mode: .setup, flow: .initializeAccount(mode: mode), route: nil), by: .push)
        case .addNewAccount:
            switch mode {
            case .create:
                open(.passphraseView(address: "temp"), by: .push)
            case .watch:
                open(.watchAccountAddition(flow: flow), by: .push)
            case .recover:
                open(.accountRecover(flow: .addNewAccount(mode: .recover)), by: .push)
            case .pair:
                open(.ledgerTutorial(flow: .addNewAccount(mode: .pair)), by: .push)
            case .rekey:
                break
            }
        }
    }
    
    func accountTypeSelectionView(_ accountTypeSelectionView: AccountTypeSelectionView, didOpen url: URL) {
        open(url)
    }
}
