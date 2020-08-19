//
//  RekeyConfirmationViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 3.08.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit
import Magpie
import CoreBluetooth

class RekeyConfirmationViewController: BaseScrollViewController {
    
    private lazy var rekeyConfirmationView = RekeyConfirmationView()
    
    private let account: Account
    private let ledger: LedgerDetail
    private var rekeyConfirmationDataSource: RekeyConfirmationDataSource
    private var rekeyConfirmationListLayout: RekeyConfirmationListLayout
    private let viewModel: RekeyConfirmationViewModel
    
    private var ledgerApprovalViewController: LedgerApprovalViewController?
    
    private lazy var cardModalPresenter = CardModalPresenter(
        config: ModalConfiguration(
            animationMode: .normal(duration: 0.25),
            dismissMode: .none
        ),
        initialModalSize: .custom(CGSize(width: view.frame.width, height: 354.0))
    )
    
    private lazy var transactionController: TransactionController = {
        guard let api = api else {
            fatalError("API should be set.")
        }
        return TransactionController(api: api)
    }()
    
    init(account: Account, ledger: LedgerDetail, configuration: ViewControllerConfiguration) {
        self.account = account
        self.ledger = ledger
        self.viewModel = RekeyConfirmationViewModel(account: account, ledgerName: ledger.name)
        rekeyConfirmationDataSource = RekeyConfirmationDataSource(account: account, rekeyConfirmationViewModel: viewModel)
        rekeyConfirmationListLayout = RekeyConfirmationListLayout(account: account)
        super.init(configuration: configuration)
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        title = "ledger-rekey-confirm-title".localized
        viewModel.configure(rekeyConfirmationView)
    }
    
    override func linkInteractors() {
        rekeyConfirmationView.delegate = self
        rekeyConfirmationDataSource.delegate = self
        transactionController.delegate = self
        rekeyConfirmationView.setDataSource(rekeyConfirmationDataSource)
        rekeyConfirmationView.setListDelegate(rekeyConfirmationListLayout)
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        setupRekeyConfirmationViewLayout()
    }
}

extension RekeyConfirmationViewController {
    private func setupRekeyConfirmationViewLayout() {
        contentView.addSubview(rekeyConfirmationView)
        
        rekeyConfirmationView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension RekeyConfirmationViewController: RekeyConfirmationDataSourceDelegate {
    func rekeyConfirmationDataSourceDidShowMoreAssets(_ rekeyConfirmationDataSource: RekeyConfirmationDataSource) {
        rekeyConfirmationListLayout.setFooterHidden(true)
        rekeyConfirmationView.reloadData()
    }
}

extension RekeyConfirmationViewController: RekeyConfirmationViewDelegate {
    func rekeyConfirmationViewDidFinalizeConfirmation(_ rekeyConfirmationView: RekeyConfirmationView) {
        guard let ledgerAddress = ledger.address else {
            return
        }
        let rekeyTransactionDraft = RekeyTransactionSendDraft(account: account, rekeyedTo: ledgerAddress)
        transactionController.setTransactionDraft(rekeyTransactionDraft)
        transactionController.getTransactionParamsAndComposeTransactionData(for: .rekey)
    }
}

extension RekeyConfirmationViewController {
    private func openLedgerApprovalScreen() {
        ledgerApprovalViewController = open(
            .ledgerApproval(mode: .connection),
            by: .customPresent(presentationStyle: .custom, transitionStyle: nil, transitioningDelegate: cardModalPresenter)
        ) as? LedgerApprovalViewController
    }
    
    private func openRekeyConfirmationAlert() {
        let accountName = account.name ?? ""
        let configurator = BottomInformationBundle(
            title: "ledger-rekey-success-title".localized,
            image: img("img-green-checkmark"),
            explanation: "ledger-rekey-success-message".localized(params: accountName),
            actionTitle: "title-go-home".localized,
            actionImage: img("bg-main-button")) {
                self.handleRekeyUpdates()
        }
        
        open(
            .bottomInformation(mode: .confirmation, configurator: configurator),
            by: .customPresentWithoutNavigationController(
                presentationStyle: .custom,
                transitionStyle: nil,
                transitioningDelegate: cardModalPresenter
            )
        )
    }
    
    private func handleRekeyUpdates() {
        guard let accountInformation = api?.session.accountInformation(from: account.address) else {
            return
        }
        
        accountInformation.type = .rekeyed
        accountInformation.ledgerDetail = LedgerDetail(id: ledger.id, name: ledger.name)
        session?.authenticatedUser?.updateAccount(accountInformation)
        dismissScreen()
    }
}

extension RekeyConfirmationViewController: TransactionControllerDelegate {
    func transactionController(_ transactionController: TransactionController, didComposedTransactionDataFor draft: TransactionSendDraft?) {
        ledgerApprovalViewController?.dismissScreen()
        openRekeyConfirmationAlert()
    }
    
    func transactionController(_ transactionController: TransactionController, didFailedComposing error: Error) {
        ledgerApprovalViewController?.dismissScreen()
    }
    
    func transactionControllerDidStartBLEConnection(_ transactionController: TransactionController) {
        openLedgerApprovalScreen()
    }
    
    func transactionController(_ transactionController: TransactionController, didFailBLEConnectionWith state: CBManagerState) {
        ledgerApprovalViewController?.dismissScreen()
        
        guard let errorTitle = state.errorDescription.title,
            let errorSubtitle = state.errorDescription.subtitle else {
                return
        }
        
        NotificationBanner.showError(errorTitle, message: errorSubtitle)
    }
    
    func transactionController(_ transactionController: TransactionController, didFailToConnect peripheral: CBPeripheral) {
        ledgerApprovalViewController?.dismissScreen()
        NotificationBanner.showError("ble-error-connection-title".localized, message: "ble-error-fail-connect-peripheral".localized)
    }
    
    func transactionController(_ transactionController: TransactionController, didDisconnectFrom peripheral: CBPeripheral) {
        ledgerApprovalViewController?.dismissScreen()
    }
    
    func transactionControllerDidFailToSignWithLedger(_ transactionController: TransactionController) {
        ledgerApprovalViewController?.dismissScreen()
        NotificationBanner.showError(
            "ble-error-transaction-cancelled-title".localized,
            message: "ble-error-fail-sign-transaction".localized
        )
    }
}
