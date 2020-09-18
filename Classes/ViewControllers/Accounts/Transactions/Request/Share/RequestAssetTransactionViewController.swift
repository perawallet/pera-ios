//
//  RequestAssetTransactionViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 27.01.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class RequestAssetTransactionViewController: RequestTransactionViewController, TestNetTitleDisplayable {
    
    private lazy var requestTransactionView: RequestTransactionView = {
        let assetDetail = assetTransactionRequestDraft.assetDetail
        return RequestTransactionView(
            inputFieldFraction: assetDetail.fractionDecimals,
            address: assetTransactionRequestDraft.account.address,
            assetIndex: assetDetail.id
        )
    }()
    
    private let viewModel: RequestAssetTransactionViewModel
    private let assetTransactionRequestDraft: AssetTransactionRequestDraft
    
    init(isPresented: Bool, assetTransactionRequestDraft: AssetTransactionRequestDraft, configuration: ViewControllerConfiguration) {
        self.assetTransactionRequestDraft = assetTransactionRequestDraft
        viewModel = RequestAssetTransactionViewModel(assetTransactionRequestDraft: assetTransactionRequestDraft)
        super.init(isPresented: isPresented, configuration: configuration)
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        viewModel.configure(requestTransactionView)
        displayTestNetTitleView(with: "request-title".localized + " \(assetTransactionRequestDraft.assetDetail.getDisplayNames().0)")
    }
    
    override func linkInteractors() {
        requestTransactionView.transactionDelegate = self
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        prepareLayout(of: requestTransactionView)
    }
    
    override func copyAccountAddress() {
        UIPasteboard.general.string = assetTransactionRequestDraft.account.address
        NotificationBanner.showInformation("qr-creation-copied".localized)
    }
}
