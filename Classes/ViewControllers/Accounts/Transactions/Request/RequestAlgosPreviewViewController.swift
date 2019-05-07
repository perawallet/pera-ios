//
//  ReceiveAlgosPreviewViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 11.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class RequestAlgosPreviewViewController: BaseScrollViewController {

    // MARK: Components
    
    private lazy var requestAlgosPreviewView: RequestAlgosPreviewView = {
        let view = RequestAlgosPreviewView(address: transaction.fromAccount.address, amount: transaction.amount.toMicroAlgos)
        return view
    }()
    
    private let transaction: TransactionPreviewDraft
    
    // MARK: Initialization
    
    init(transaction: TransactionPreviewDraft, configuration: ViewControllerConfiguration) {
        self.transaction = transaction
        
        super.init(configuration: configuration)
        
        hidesBottomBarWhenPushed = true
    }
    
    // MARK: Setup
    
    override func configureAppearance() {
        super.configureAppearance()
        
        title = "request-algos-title".localized
        
        requestAlgosPreviewView.algosInputView.inputTextField.text = transaction.amount.toDecimalStringForLabel
        requestAlgosPreviewView.accountSelectionView.detailLabel.text = transaction.fromAccount.name
        requestAlgosPreviewView.accountSelectionView.set(amount: transaction.fromAccount.amount.toAlgos)
    }
    
    override func linkInteractors() {
        requestAlgosPreviewView.previewViewDelegate = self
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        
        setupRequestAlgosPreviewViewLayout()
    }
    
    private func setupRequestAlgosPreviewViewLayout() {
        contentView.addSubview(requestAlgosPreviewView)
        
        requestAlgosPreviewView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.bottom.equalToSuperview().inset(view.safeAreaBottom)
        }
    }
}

// MARK: RequestAlgosPreviewViewDelegate

extension RequestAlgosPreviewViewController: RequestAlgosPreviewViewDelegate {
    
    func requestAlgosPreviewViewDidTapShareButton(_ requestAlgosPreviewView: RequestAlgosPreviewView) {
        guard let qrImage = requestAlgosPreviewView.qrView.imageView.image,
            let shareUrl = URL(string: "algorand://send-algos/\(transaction.fromAccount.address)/\(transaction.amount.toMicroAlgos)") else {
                return
        }
        
        let sharedItem: [Any] = [shareUrl, qrImage]
        let activityViewController = UIActivityViewController(activityItems: sharedItem, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [UIActivity.ActivityType.addToReadingList]
        
        navigationController?.present(activityViewController, animated: true, completion: nil)
    }
}
