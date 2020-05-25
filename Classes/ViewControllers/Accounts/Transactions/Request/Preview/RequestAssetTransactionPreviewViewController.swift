//
//  RequestAssetTransactionPreviewViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 27.01.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class RequestAssetTransactionPreviewViewController: RequestTransactionPreviewViewController, TestNetTitleDisplayable {
    
    private lazy var requestTransactionPreviewView = RequestTransactionPreviewView(inputFieldFraction: assetDetail.fractionDecimals)
    
    private let assetDetail: AssetDetail
    private let viewModel: RequestAssetTransactionPreviewViewModel
    
    init(account: Account, assetDetail: AssetDetail, isReceiverEditable: Bool, configuration: ViewControllerConfiguration) {
        self.assetDetail = assetDetail
        self.viewModel = RequestAssetTransactionPreviewViewModel(account: account, assetDetail: assetDetail)
        super.init(account: account, isReceiverEditable: isReceiverEditable, configuration: configuration)
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        viewModel.configure(requestTransactionPreviewView)
        displayTestNetTitleView(with: "request-title".localized + " \(assetDetail.getDisplayNames().0)")
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        prepareLayout(of: requestTransactionPreviewView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        requestTransactionPreviewView.amountInputView.beginEditing()
    }
    
    override func linkInteractors() {
        requestTransactionPreviewView.delegate = self
    }
    
    override func openRequestScreen() {
        let draft = AssetTransactionRequestDraft(account: account, amount: amount, assetDetail: assetDetail)
        open(.requestAssetTransaction(assetTransactionRequestDraft: draft), by: .push)
    }
}
