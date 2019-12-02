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
        let view = RequestTransactionView(address: transaction.fromAccount.address, amount: transaction.amount.toMicroAlgos)
        return view
    }()
    
    private let transaction: TransactionPreviewDraft
    
    init(transaction: TransactionPreviewDraft, configuration: ViewControllerConfiguration) {
        self.transaction = transaction
        super.init(configuration: configuration)
        
        hidesBottomBarWhenPushed = true
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        
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
    }
    
    private func configureViewForAssets() {
        requestTransactionView.transactionParticipantView.accountSelectionView.amountView.amountLabel.textColor = SharedColors.black
        requestTransactionView.transactionParticipantView.accountSelectionView.amountView.algoIconImageView.isHidden = true
        requestTransactionView.transactionParticipantView.accountSelectionView.detailLabel.text = transaction.fromAccount.name
        requestTransactionView.amountInputView.inputTextField.text = transaction.amount.toDecimalStringForLabel
        requestTransactionView.amountInputView.algosImageView.isHidden = true
        
        guard let assetDetail = transaction.assetDetail,
            let assetName = assetDetail.assetName,
            let assetCode = assetDetail.unitName else {
            return
        }
        
        title = "\(assetName) " + "request-title".localized
        let nameText = assetName.attributed()
        let codeText = "(\(assetCode))".attributed([.textColor(SharedColors.purple)])
        requestTransactionView.transactionParticipantView.assetSelectionView.detailLabel.attributedText = nameText + codeText
    }
}

extension RequestTransactionViewController: RequestTransactionViewDelegate {
    func requestTransactionViewDidTapShareButton(_ requestTransactionView: RequestTransactionView) {
        guard let qrImage = requestTransactionView.qrView.imageView.image,
            let shareUrl = URL(string: "algorand://send-algos/\(transaction.fromAccount.address)/\(transaction.amount.toMicroAlgos)") else {
                return
        }
        
        let sharedItem: [Any] = [shareUrl, qrImage]
        let activityViewController = UIActivityViewController(activityItems: sharedItem, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [UIActivity.ActivityType.addToReadingList]
        navigationController?.present(activityViewController, animated: true, completion: nil)
    }
}
