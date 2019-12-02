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
        
        title = "request-algos-title".localized
        
        requestTransactionView.algosInputView.inputTextField.text = transaction.amount.toDecimalStringForLabel
        requestTransactionView.accountSelectionView.detailLabel.text = transaction.fromAccount.name
        requestTransactionView.accountSelectionView.set(amount: transaction.fromAccount.amount.toAlgos)
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
