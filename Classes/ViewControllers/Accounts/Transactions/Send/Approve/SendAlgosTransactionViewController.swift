//
//  SendAlgosTransactionViewController.swift

import UIKit

class SendAlgosTransactionViewController: SendTransactionViewController, TestNetTitleDisplayable {
    
    private var algosTransactionSendDraft: AlgosTransactionSendDraft
    
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
        sendTransactionView.bind(SendTransactionViewModel(transactionDraft: algosTransactionSendDraft))
        displayTestNetTitleView(with: "send-algos-title".localized)
    }
    
    override func completeTransaction(with id: TransactionID) {
        algosTransactionSendDraft.identifier = id.identifier
        
        log(
            TransactionEvent(
                accountType: algosTransactionSendDraft.from.type,
                assetId: nil,
                isMaxTransaction: algosTransactionSendDraft.isMaxTransaction,
                amount: algosTransactionSendDraft.amount?.toMicroAlgos
            )
        )
    }
}
