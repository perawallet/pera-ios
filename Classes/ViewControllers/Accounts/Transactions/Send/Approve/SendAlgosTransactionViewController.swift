//
//  SendAlgosTransactionViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 27.01.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class SendAlgosTransactionViewController: SendTransactionViewController {
    
    private var algosTransaction: TransactionPreviewDraft
    private let viewModel = SendAlgosTransactionViewModel()
    
    init(algosTransaction: TransactionPreviewDraft, assetReceiverState: AssetReceiverState, configuration: ViewControllerConfiguration) {
        self.algosTransaction = algosTransaction
        super.init(assetReceiverState: assetReceiverState, configuration: configuration)
        
        fee = algosTransaction.fee
        transactionController?.setTransactionDraft(algosTransaction)
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        title = "send-algos-title".localized
        viewModel.configure(sendTransactionView, with: algosTransaction)
    }
    
    override func completeTransaction(with id: TransactionID) {
        algosTransaction.identifier = id.identifier
    }
}
