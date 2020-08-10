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
    private let connectedDeviceId: UUID
    private let connectedDeviceName: String?
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
    
    init(account: Account, connectedDeviceId: UUID, connectedDeviceName: String?, configuration: ViewControllerConfiguration) {
        self.account = account
        self.connectedDeviceId = connectedDeviceId
        self.connectedDeviceName = connectedDeviceName
        self.viewModel = RekeyConfirmationViewModel(account: account, ledgerName: connectedDeviceName)
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
        openLedgerApprovalScreen()
    }
    
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
}

extension RekeyConfirmationViewController: TransactionControllerDelegate {
    func transactionController(_ transactionController: TransactionController, didComposedTransactionDataFor draft: TransactionSendDraft?) {
        ledgerApprovalViewController?.dismissScreen()
    }
    
    func transactionController(_ transactionController: TransactionController, didFailedComposing error: Error) {
        ledgerApprovalViewController?.dismissScreen()
    }
    
    func transactionControllerDidStartBLEConnection(_ transactionController: TransactionController) {
        ledgerApprovalViewController?.dismissScreen()
    }
    
    func transactionController(_ transactionController: TransactionController, didFailBLEConnectionWith state: CBManagerState) {
        ledgerApprovalViewController?.dismissScreen()
    }
    
    func transactionController(_ transactionController: TransactionController, didFailToConnect peripheral: CBPeripheral) {
        ledgerApprovalViewController?.dismissScreen()
    }
    
    func transactionController(_ transactionController: TransactionController, didDisconnectFrom peripheral: CBPeripheral) {
        ledgerApprovalViewController?.dismissScreen()
    }
    
    func transactionControllerDidFailToSignWithLedger(_ transactionController: TransactionController) {
        ledgerApprovalViewController?.dismissScreen()
    }
}
