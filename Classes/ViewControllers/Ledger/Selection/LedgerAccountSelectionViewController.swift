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
//  LedgerAccountSelectionViewController.swift

import UIKit
import SVProgressHUD

class LedgerAccountSelectionViewController: BaseViewController {
    
    private lazy var ledgerAccountSelectionView = LedgerAccountSelectionView(isMultiSelect: isMultiSelect)
    
    private lazy var accountManager: AccountManager? = {
        guard let api = self.api else {
            return nil
        }
        let manager = AccountManager(api: api)
        return manager
    }()
    
    private let ledger: LedgerDetail
    private let ledgerAccounts: [Account]
    private let accountSetupFlow: AccountSetupFlow

    private var selectedAccountCount: Int {
        return ledgerAccountSelectionView.selectedIndexes.count
    }
    
    private var isMultiSelect: Bool {
        switch accountSetupFlow {
        case .initializeAccount:
            return true
        case let .addNewAccount(mode):
            switch mode {
            case .rekey:
                return false
            default:
                return true
            }
        }
    }

    private lazy var dataSource: LedgerAccountSelectionDataSource = {
        guard let api = api else {
            fatalError("API should be set.")
        }
        return LedgerAccountSelectionDataSource(api: api, ledger: ledger, accounts: ledgerAccounts, isMultiSelect: isMultiSelect)
    }()
    
    private lazy var listLayout = LedgerAccountSelectionListLayout(dataSource: dataSource, isMultiSelect: isMultiSelect)
    
    init(accountSetupFlow: AccountSetupFlow, ledger: LedgerDetail, accounts: [Account], configuration: ViewControllerConfiguration) {
        self.accountSetupFlow = accountSetupFlow
        self.ledger = ledger
        self.ledgerAccounts = accounts
        super.init(configuration: configuration)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ledgerAccountSelectionView.setLoadingState()
        
        SVProgressHUD.show(withStatus: "title-loading".localized)
        dataSource.loadData()
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        title = ledger.name
        ledgerAccountSelectionView.bind(LedgerAccountSelectionViewModel(isMultiSelect: isMultiSelect, selectedCount: selectedAccountCount))
    }
    
    override func linkInteractors() {
        ledgerAccountSelectionView.delegate = self
        ledgerAccountSelectionView.setDataSource(dataSource)
        ledgerAccountSelectionView.setListDelegate(listLayout)
        dataSource.delegate = self
        listLayout.delegate = self
    }
    
    override func prepareLayout() {
        setupLedgerAccountSelectionViewLayout()
    }
}

extension LedgerAccountSelectionViewController {
    private func setupLedgerAccountSelectionViewLayout() {
        view.addSubview(ledgerAccountSelectionView)
        
        ledgerAccountSelectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension LedgerAccountSelectionViewController: LedgerAccountSelectionDataSourceDelegate {
    func ledgerAccountSelectionDataSource(
        _ ledgerAccountSelectionDataSource: LedgerAccountSelectionDataSource,
        didFetch accounts: [Account]
    ) {
        SVProgressHUD.showSuccess(withStatus: "title-done".localized)
        SVProgressHUD.dismiss()
        
        ledgerAccountSelectionView.setNormalState()
        ledgerAccountSelectionView.reloadData()
    }
    
    func ledgerAccountSelectionDataSourceDidFailToFetch(_ ledgerAccountSelectionDataSource: LedgerAccountSelectionDataSource) {
        SVProgressHUD.showError(withStatus: nil)
        SVProgressHUD.dismiss()
        
        ledgerAccountSelectionView.setErrorState()
        ledgerAccountSelectionView.reloadData()
    }
    
    func ledgerAccountSelectionDataSource(
        _ ledgerAccountSelectionDataSource: LedgerAccountSelectionDataSource,
        didTapMoreInfoFor cell: LedgerAccountCell
    ) {
        guard let indexPath = ledgerAccountSelectionView.indexPath(for: cell),
              let account = dataSource.account(at: indexPath.item) else {
            return
        }
        
        open(
            .ledgerAccountDetail(
                account: account,
                ledgerIndex: dataSource.ledgerAccountIndex(for: account.address),
                rekeyedAccounts: dataSource.rekeyedAccounts(for: account.address)
            ),
            by: .present
        )
    }
}

extension LedgerAccountSelectionViewController: LedgerAccountSelectionViewDelegate {
    func ledgerAccountSelectionViewDidAddAccount(_ ledgerAccountSelectionView: LedgerAccountSelectionView) {
        switch accountSetupFlow {
        case let .addNewAccount(mode):
            switch mode {
            case let .rekey(rekeyedAccount):
                openRekeyConfirmation(for: rekeyedAccount)
            default:
                saveNewAccounts()
            }
        case .initializeAccount:
            saveNewAccounts()
        }
    }

    private func openRekeyConfirmation(for rekeyedAccount: Account) {
        guard let selectedIndex = ledgerAccountSelectionView.selectedIndexes.first,
              let account = dataSource.account(at: selectedIndex.item),
              !isMultiSelect else {
            return
        }

        self.open(.rekeyConfirmation(account: rekeyedAccount, ledger: ledger, ledgerAddress: account.address), by: .push)
    }

    private func saveNewAccounts() {
        dataSource.saveSelectedAccounts(ledgerAccountSelectionView.selectedIndexes)
        launchHome()
    }
    
    private func launchHome() {
        SVProgressHUD.show(withStatus: "title-loading".localized)
        accountManager?.fetchAllAccounts(isVerifiedAssetsIncluded: true) {
            SVProgressHUD.showSuccess(withStatus: "title-done".localized)
            SVProgressHUD.dismiss(withDelay: 1.0) {
                switch self.accountSetupFlow {
                case .initializeAccount:
                    self.dismiss(animated: false) {
                        UIApplication.shared.rootViewController()?.setupTabBarController()
                    }
                case .addNewAccount:
                    self.closeScreen(by: .dismiss, animated: false)
                }
            }
        }
    }
}

extension LedgerAccountSelectionViewController: LedgerAccountSelectionListLayoutDelegate {
    func ledgerAccountSelectionListLayout(
        _ ledgerAccountSelectionListLayout: LedgerAccountSelectionListLayout,
        didSelectItemAt indexPath: IndexPath
    ) {
        ledgerAccountSelectionView.bind(LedgerAccountSelectionViewModel(isMultiSelect: isMultiSelect, selectedCount: selectedAccountCount))
    }
    
    func ledgerAccountSelectionListLayout(
        _ ledgerAccountSelectionListLayout: LedgerAccountSelectionListLayout,
        didDeselectItemAt indexPath: IndexPath
    ) {
        ledgerAccountSelectionView.bind(LedgerAccountSelectionViewModel(isMultiSelect: isMultiSelect, selectedCount: selectedAccountCount))
    }
}
