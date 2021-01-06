//
//  LedgerAccountSelectionViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 10.08.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

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
        ledgerAccountSelectionView.setAddButtonEnabled(!ledgerAccountSelectionView.selectedIndexes.isEmpty)
    }
    
    func ledgerAccountSelectionListLayout(
        _ ledgerAccountSelectionListLayout: LedgerAccountSelectionListLayout,
        didDeselectItemAt indexPath: IndexPath
    ) {
        ledgerAccountSelectionView.setAddButtonEnabled(!ledgerAccountSelectionView.selectedIndexes.isEmpty)
    }
}
