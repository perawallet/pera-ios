//
//  RequestAlgosTransactionViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 27.01.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class RequestAlgosTransactionViewController: RequestTransactionViewController {
    
    private lazy var requestTransactionView: RequestTransactionView = {
        return RequestTransactionView(
            inputFieldFraction: algosFraction,
            address: algosTransactionRequestDraft.account.address,
            amount: algosTransactionRequestDraft.amount.toMicroAlgos
        )
    }()
    
    private let viewModel: RequestAlgosTransactionViewModel
    private let algosTransactionRequestDraft: AlgosTransactionRequestDraft
    
    init(algosTransactionRequestDraft: AlgosTransactionRequestDraft, configuration: ViewControllerConfiguration) {
        self.algosTransactionRequestDraft = algosTransactionRequestDraft
        viewModel = RequestAlgosTransactionViewModel(algosTransactionRequestDraft: algosTransactionRequestDraft)
        super.init(configuration: configuration)
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        title = "request-algos-title".localized
        viewModel.configure(requestTransactionView)
    }
    
    override func linkInteractors() {
        requestTransactionView.transactionDelegate = self
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        prepareLayout(of: requestTransactionView)
    }
}
