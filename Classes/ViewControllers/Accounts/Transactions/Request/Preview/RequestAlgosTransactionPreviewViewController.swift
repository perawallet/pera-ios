//
//  RequestAlgosTransactionPreviewViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 27.01.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class RequestAlgosTransactionPreviewViewController: RequestTransactionPreviewViewController, TestNetTitleDisplayable {
    
    private lazy var requestTransactionPreviewView = RequestTransactionPreviewView(inputFieldFraction: algosFraction)
    
    private let viewModel: RequestAlgosTransactionPreviewViewModel
    
    override var filterOption: SelectAssetViewController.FilterOption {
        return .algos
    }
    
    override init(account: Account, isReceiverEditable: Bool, configuration: ViewControllerConfiguration) {
        self.viewModel = RequestAlgosTransactionPreviewViewModel(account: account, isAccountSelectionEnabled: isReceiverEditable)
        super.init(account: account, isReceiverEditable: isReceiverEditable, configuration: configuration)
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        viewModel.configure(requestTransactionPreviewView)
        displayTestNetTitleView(with: "request-algos-title".localized)
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
        let draft = AlgosTransactionRequestDraft(account: account, amount: amount)
        open(.requestAlgosTransaction(algosTransactionRequestDraft: draft), by: .push)
    }
    
    override func configure(forSelected account: Account, with assetDetail: AssetDetail?) {
        self.account = account
        viewModel.updateAccount(account)
        viewModel.configure(requestTransactionPreviewView)
        requestTransactionPreviewView.setAssetSelectionHidden(true)
    }
}
