//
//  RequestTransactionViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 11.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class RequestTransactionViewController: BaseScrollViewController {
    
    private lazy var requestTransactionView: RequestTransactionView = {
        if !transaction.isAlgoTransaction,
            let assetIndex = transaction.assetDetail?.index {
            return RequestTransactionView(
                inputFieldFraction: transaction.assetDetail?.fractionDecimals ?? algosFraction,
                address: transaction.fromAccount.address,
                amount: transaction.amount.toFraction(of: transaction.assetDetail?.fractionDecimals ?? algosFraction),
                assetIndex: Int(assetIndex)
            )
        } else {
            return RequestTransactionView(
                inputFieldFraction: algosFraction,
                address: transaction.fromAccount.address,
                amount: transaction.amount.toMicroAlgos
            )
        }
    }()
    
    private let transaction: TransactionPreviewDraft
    
    init(transaction: TransactionPreviewDraft, configuration: ViewControllerConfiguration) {
        self.transaction = transaction
        super.init(configuration: configuration)
        
        hidesBottomBarWhenPushed = true
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        
        requestTransactionView.transactionParticipantView.accountSelectionView.set(enabled: false)
        
        if transaction.isAlgoTransaction {
            configureViewForAlgos()
        } else {
            configureViewForAssets()
        }
    }
    
    override func linkInteractors() {
        requestTransactionView.transactionDelegate = self
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        setupRequestTransactionViewLayout()
    }
}

extension RequestTransactionViewController {
    private func setupRequestTransactionViewLayout() {
        contentView.addSubview(requestTransactionView)
        
        requestTransactionView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.bottom.equalToSuperview().inset(view.safeAreaBottom)
        }
    }
}

extension RequestTransactionViewController {
    private func configureViewForAlgos() {
        title = "request-algos-title".localized
        requestTransactionView.transactionParticipantView.accountSelectionView.detailLabel.text = transaction.fromAccount.name
        requestTransactionView.transactionParticipantView.accountSelectionView.amountView.amountLabel.textColor = SharedColors.turquois
        requestTransactionView.transactionParticipantView.accountSelectionView.amountView.algoIconImageView.tintColor =
            SharedColors.turquois
        requestTransactionView.amountInputView.inputTextField.text = transaction.amount.toDecimalStringForLabel
        requestTransactionView.transactionParticipantView.assetSelectionView.detailLabel.text = "asset-algos-title".localized
        requestTransactionView.transactionParticipantView.assetSelectionView.verifiedImageView.isHidden = false
    }
    
    private func configureViewForAssets() {
        requestTransactionView.transactionParticipantView.accountSelectionView.amountView.amountLabel.textColor = SharedColors.black
        requestTransactionView.transactionParticipantView.accountSelectionView.amountView.algoIconImageView.removeFromSuperview()
        requestTransactionView.transactionParticipantView.accountSelectionView.detailLabel.text = transaction.fromAccount.name
        requestTransactionView.amountInputView.algosImageView.removeFromSuperview()
        
        guard let assetDetail = transaction.assetDetail else {
            return
        }
        
        requestTransactionView.transactionParticipantView.assetSelectionView.verifiedImageView.isHidden = !assetDetail.isVerified
        requestTransactionView.amountInputView.inputTextField.text =
            transaction.amount.toFractionStringForLabel(fraction: assetDetail.fractionDecimals)
        
        title = "\(assetDetail.getDisplayNames().0) " + "request-title".localized
        requestTransactionView.transactionParticipantView.assetSelectionView.detailLabel.attributedText = assetDetail.assetDisplayName()
    }
}

extension RequestTransactionViewController: RequestTransactionViewDelegate {
    func requestTransactionViewDidTapShareButton(_ requestTransactionView: RequestTransactionView) {
        guard let shareUrl = URL(string: requestTransactionView.qrView.qrText.qrText()) else {
            return
        }
        
        let sharedItem = [shareUrl]
        let activityViewController = UIActivityViewController(activityItems: sharedItem, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [UIActivity.ActivityType.addToReadingList]
        navigationController?.present(activityViewController, animated: true, completion: nil)
    }
}
