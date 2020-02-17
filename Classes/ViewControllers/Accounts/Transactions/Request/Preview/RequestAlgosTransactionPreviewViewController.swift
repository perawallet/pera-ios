//
//  RequestAlgosTransactionPreviewViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 27.01.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class RequestAlgosTransactionPreviewViewController: RequestTransactionPreviewViewController {
    
    private lazy var requestTransactionPreviewView = RequestTransactionPreviewView(inputFieldFraction: algosFraction)
    
    private let viewModel: RequestAlgosTransactionPreviewViewModel
    
    override init(account: Account, configuration: ViewControllerConfiguration) {
        self.viewModel = RequestAlgosTransactionPreviewViewModel(account: account)
        super.init(account: account, configuration: configuration)
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        title = "request-algos-title".localized
        viewModel.configure(requestTransactionPreviewView)
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
}
