//
//  SendAssetTransactionViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 27.01.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class SendAssetTransactionViewController: SendTransactionViewController, TestNetTitleDisplayable {
    
    private var assetTransactionSendDraft: AssetTransactionSendDraft
    private let viewModel = SendAssetTransactionViewModel()
    
    init(
        assetTransactionSendDraft: AssetTransactionSendDraft,
        assetReceiverState: AssetReceiverState,
        transactionController: TransactionController,
        isSenderEditable: Bool,
        configuration: ViewControllerConfiguration
    ) {
        self.assetTransactionSendDraft = assetTransactionSendDraft
        super.init(
            assetReceiverState: assetReceiverState,
            transactionController: transactionController,
            isSenderEditable: isSenderEditable,
            configuration: configuration
        )
        
        fee = assetTransactionSendDraft.fee
        transactionController.setTransactionDraft(assetTransactionSendDraft)
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        setTitle()
        viewModel.configure(sendTransactionView, with: assetTransactionSendDraft)
    }
    
    override func completeTransaction(with id: TransactionID) {
        assetTransactionSendDraft.identifier = id.identifier
        
        if let id = assetTransactionSendDraft.assetIndex {
            TransactionEvent(
                accountType: assetTransactionSendDraft.from.type,
                assetId: String(id),
                isMaxTransaction: assetTransactionSendDraft.isMaxTransaction
            ).logEvent()
        }
        
        delegate?.sendTransactionViewController(self, didCompleteTransactionFor: assetTransactionSendDraft.assetIndex)
    }
}

extension SendAssetTransactionViewController {
    private func setTitle() {
        guard let assetIndex = assetTransactionSendDraft.assetIndex,
            let assetDetail = assetTransactionSendDraft.from.assetDetails.first(where: { $0.id == assetIndex }) else {
            return
        }
        
        let assetTitle = "title-send".localized + " \(assetDetail.getDisplayNames().0)"
        displayTestNetTitleView(with: assetTitle)
        sendTransactionView.setButtonTitle(assetTitle)
    }
}
