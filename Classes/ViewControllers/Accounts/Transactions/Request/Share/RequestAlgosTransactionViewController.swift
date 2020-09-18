//
//  RequestAlgosTransactionViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 27.01.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class RequestAlgosTransactionViewController: RequestTransactionViewController, TestNetTitleDisplayable {
    
    private lazy var requestTransactionView = RequestTransactionView(
        inputFieldFraction: algosFraction,
        address: algosTransactionRequestDraft.account.address
    )
    
    private let viewModel: RequestAlgosTransactionViewModel
    private let algosTransactionRequestDraft: AlgosTransactionRequestDraft
    
    init(isPresented: Bool, algosTransactionRequestDraft: AlgosTransactionRequestDraft, configuration: ViewControllerConfiguration) {
        self.algosTransactionRequestDraft = algosTransactionRequestDraft
        viewModel = RequestAlgosTransactionViewModel(algosTransactionRequestDraft: algosTransactionRequestDraft)
        super.init(isPresented: isPresented, configuration: configuration)
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        viewModel.configure(requestTransactionView)
        displayTestNetTitleView(with: "request-algos-title".localized)
    }
    
    override func linkInteractors() {
        requestTransactionView.transactionDelegate = self
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        prepareLayout(of: requestTransactionView)
    }
    
    override func copyAccountAddress() {
        UIPasteboard.general.string = algosTransactionRequestDraft.account.address
        NotificationBanner.showInformation("qr-creation-copied".localized)
    }
}
