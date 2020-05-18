//
//  SendAlgosTransactionViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 27.01.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class SendAlgosTransactionViewController: SendTransactionViewController {
    
    private var algosTransactionSendDraft: AlgosTransactionSendDraft
    private let viewModel = SendAlgosTransactionViewModel()
    
    init(
        algosTransactionSendDraft: AlgosTransactionSendDraft,
        assetReceiverState: AssetReceiverState,
        transactionController: TransactionController,
        configuration: ViewControllerConfiguration
    ) {
        self.algosTransactionSendDraft = algosTransactionSendDraft
        super.init(assetReceiverState: assetReceiverState, transactionController: transactionController, configuration: configuration)
        
        fee = algosTransactionSendDraft.fee
        transactionController.setTransactionDraft(algosTransactionSendDraft)
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        viewModel.configure(sendTransactionView, with: algosTransactionSendDraft)
        
        guard let isTestNet = api?.isTestNet else {
            title = "send-algos-title".localized
            return
        }
        
        if isTestNet {
            navigationItem.titleView = TestNetTitleView(title: "send-algos-title".localized)
        } else {
            title = "send-algos-title".localized
        }
    }
    
    override func completeTransaction(with id: TransactionID) {
        algosTransactionSendDraft.identifier = id.identifier
    }
}
