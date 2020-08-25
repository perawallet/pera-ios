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
    
    private lazy var ledgerAccountSelectionView = LedgerAccountSelectionView()
    
    private lazy var accountManager: AccountManager? = {
        guard let api = self.api else {
            return nil
        }
        let manager = AccountManager(api: api)
        return manager
    }()
    
    private let ledger: LedgerDetail
    private let mode: AccountSetupMode

    private lazy var dataSource: LedgerAccountSelectionDataSource = {
        guard let api = api else {
            fatalError("API should be set.")
        }
        return LedgerAccountSelectionDataSource(api: api, ledger: ledger)
    }()
    
    private lazy var listLayout = LedgerAccountSelectionListLayout(dataSource: dataSource)
    
    init(mode: AccountSetupMode, ledger: LedgerDetail, configuration: ViewControllerConfiguration) {
        self.mode = mode
        self.ledger = ledger
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
    
    func ledgerAccountSelectionDataSourceDidCopyAuthAddress(_ ledgerAccountSelectionDataSource: LedgerAccountSelectionDataSource) {
        displaySimpleAlertWith(title: "qr-creation-copied".localized, message: "")
        UIPasteboard.general.string = dataSource.account(at: 0)?.authAddress
    }
}

extension LedgerAccountSelectionViewController: LedgerAccountSelectionListLayoutDelegate {
    func ledgerAccountSelectionListLayout(_ listLayout: LedgerAccountSelectionListLayout, didSelectAccountAt indexPath: IndexPath) {
        setAddButtonEnabledIfNeeded()
    }
    
    func ledgerAccountSelectionListLayout(_ listLayout: LedgerAccountSelectionListLayout, didDeselectAccountAt indexPath: IndexPath) {
        setAddButtonEnabledIfNeeded()
    }
}

extension LedgerAccountSelectionViewController: LedgerAccountSelectionViewDelegate {
    func ledgerAccountSelectionViewDidAddAccount(_ ledgerAccountSelectionView: LedgerAccountSelectionView) {
        if ledgerAccountSelectionView.selectedIndexes.isEmpty {
            return
        }
        
        RegistrationEvent(type: .ledger).logEvent()
        dataSource.saveSelectedAccounts(ledgerAccountSelectionView.selectedIndexes)
        launchHome()
    }
    
    private func launchHome() {
        SVProgressHUD.show(withStatus: "title-loading".localized)
        accountManager?.fetchAllAccounts(isVerifiedAssetsIncluded: true) {
            SVProgressHUD.showSuccess(withStatus: "title-done".localized)
            SVProgressHUD.dismiss(withDelay: 1.0) {
                switch self.mode {
                case .initialize:
                    self.dismiss(animated: false) {
                        UIApplication.shared.rootViewController()?.setupTabBarController()
                    }
                case .new:
                    self.closeScreen(by: .dismiss, animated: false)
                case .rekey:
                    break
                }
            }
        }
    }
    
    private func setAddButtonEnabledIfNeeded() {
        ledgerAccountSelectionView.setEnabled(!ledgerAccountSelectionView.selectedIndexes.isEmpty)
    }
}
