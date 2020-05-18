//
//  SendAssetTransactionViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 27.01.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class SendAssetTransactionViewController: SendTransactionViewController {
    
    private var assetTransactionSendDraft: AssetTransactionSendDraft
    private let viewModel = SendAssetTransactionViewModel()
    
    init(
        assetTransactionSendDraft: AssetTransactionSendDraft,
        assetReceiverState: AssetReceiverState,
        transactionController: TransactionController,
        configuration: ViewControllerConfiguration
    ) {
        self.assetTransactionSendDraft = assetTransactionSendDraft
        super.init(assetReceiverState: assetReceiverState, transactionController: transactionController, configuration: configuration)
        
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
        
        guard let isTestNet = api?.isTestNet else {
            title = assetTitle
            return
        }
        
        if isTestNet {
            navigationItem.titleView = TestNetTitleView(title: assetTitle)
        } else {
            title = assetTitle
        }
        
        sendTransactionView.setButtonTitle(assetTitle)
    }
}
