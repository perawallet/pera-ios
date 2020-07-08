//
//  SendAlgosTransactionViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 27.01.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class SendAlgosTransactionViewController: SendTransactionViewController, TestNetTitleDisplayable {
    
    private var algosTransactionSendDraft: AlgosTransactionSendDraft
    private let viewModel = SendAlgosTransactionViewModel()
    
    init(
        algosTransactionSendDraft: AlgosTransactionSendDraft,
        assetReceiverState: AssetReceiverState,
        transactionController: TransactionController,
        isSenderEditable: Bool,
        configuration: ViewControllerConfiguration
    ) {
        self.algosTransactionSendDraft = algosTransactionSendDraft
        super.init(
            assetReceiverState: assetReceiverState,
            transactionController: transactionController,
            isSenderEditable: isSenderEditable,
            configuration: configuration
        )
        
        fee = algosTransactionSendDraft.fee
        transactionController.setTransactionDraft(algosTransactionSendDraft)
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        viewModel.configure(sendTransactionView, with: algosTransactionSendDraft)
        displayTestNetTitleView(with: "send-algos-title".localized)
    }
    
    override func completeTransaction(with id: TransactionID) {
        algosTransactionSendDraft.identifier = id.identifier
        TransactionEvent(
            accountType: algosTransactionSendDraft.from.type,
            assetId: nil,
            isMaxTransaction: algosTransactionSendDraft.isMaxTransaction
        ).logEvent()
    }
}
