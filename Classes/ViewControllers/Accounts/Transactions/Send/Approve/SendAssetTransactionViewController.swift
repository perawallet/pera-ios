//
//  SendAssetTransactionViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 27.01.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class SendAssetTransactionViewController: SendTransactionViewController {
    
    private var assetTransaction: AssetTransactionDraft
    private let viewModel = SendAssetTransactionViewModel()
    
    init(assetTransaction: AssetTransactionDraft, assetReceiverState: AssetReceiverState, configuration: ViewControllerConfiguration) {
        self.assetTransaction = assetTransaction
        super.init(assetReceiverState: assetReceiverState, configuration: configuration)
        
        fee = assetTransaction.fee
        transactionController?.setAssetTransactionDraft(assetTransaction)
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        setTitle()
        viewModel.configure(sendTransactionView, with: assetTransaction)
    }
    
    override func completeTransaction(with id: TransactionID) {
        assetTransaction.identifier = id.identifier
        delegate?.sendTransactionViewController(self, didCompleteTransactionFor: assetTransaction.assetIndex)
    }
}

extension SendAssetTransactionViewController {
    private func setTitle() {
        guard let assetIndex = assetTransaction.assetIndex,
            let assetDetail = assetTransaction.fromAccount.assetDetails.first(where: { $0.id == assetIndex }) else {
            return
        }
        title = "title-send-lowercased".localized + " \(assetDetail.getDisplayNames().0)"
    }
}
