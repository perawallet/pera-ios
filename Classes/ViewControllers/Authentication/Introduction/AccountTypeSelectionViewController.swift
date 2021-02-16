// Copyright 2019 Algorand, Inc.

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
//  AccountTypeSelectionViewController.swift

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
