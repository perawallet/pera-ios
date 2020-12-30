//
//  LedgerAccountDetailViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 15.12.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit
import SVProgressHUD

class LedgerAccountDetailViewController: BaseScrollViewController {
    
    private lazy var ledgerAccountDetailView = LedgerAccountDetailView()
    
    private let account: Account
    private let ledgerIndex: Int?
    private let rekeyedAccounts: [Account]?
    
    init(account: Account, ledgerIndex: Int?, rekeyedAccounts: [Account]?, configuration: ViewControllerConfiguration) {
        self.account = account
        self.ledgerIndex = ledgerIndex
        self.rekeyedAccounts = rekeyedAccounts
        super.init(configuration: configuration)
    }
    
    override func configureNavigationBarAppearance() {
        super.configureNavigationBarAppearance()
        
        let closeBarButtonItem = ALGBarButtonItem(kind: .close) { [unowned self] in
            self.closeScreen(by: .dismiss, animated: true)
        }
        
        leftBarButtonItems = [closeBarButtonItem]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchAssets(for: account)
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        
        if let index = ledgerIndex {
            title = "Ledger #\(index)"
        } else {
            title = account.address.shortAddressDisplay()
        }
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        setupLedgerAccountDetailViewLayout()
    }
}

extension LedgerAccountDetailViewController {
    private func setupLedgerAccountDetailViewLayout() {
        contentView.addSubview(ledgerAccountDetailView)
        
        ledgerAccountDetailView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension LedgerAccountDetailViewController {
    private func fetchAssets(for account: Account) {
        guard let assets = account.assets,
              !assets.isEmpty else {
            bindView(with: account)
            return
        }
        
        SVProgressHUD.show(withStatus: "title-loading".localized)
        
        for (index, asset) in assets.enumerated() {
            if let assetDetail = api?.session.assetDetails[asset.id] {
                account.assetDetails.append(assetDetail)
                
                if index == assets.count - 1 {
                    SVProgressHUD.showSuccess(withStatus: "title-done".localized)
                    SVProgressHUD.dismiss()
                    bindView(with: account)
                }
            } else {
                
                self.api?.getAssetDetails(with: AssetFetchDraft(assetId: "\(asset.id)")) { assetResponse in
                    switch assetResponse {
                    case .success(let assetDetailResponse):
                        self.composeAssetDetail(assetDetailResponse.assetDetail, of: account, with: asset.id)
                    case .failure:
                        account.removeAsset(asset.id)
                    }
                    
                    if index == assets.count - 1 {
                        SVProgressHUD.showSuccess(withStatus: "title-done".localized)
                        SVProgressHUD.dismiss()
                        self.bindView(with: account)
                    }
                }
            }
        }
    }
    
    private func bindView(with account: Account) {
        ledgerAccountDetailView.bind(LedgerAccountDetailViewModel(account: account, rekeyedAccounts: rekeyedAccounts))
    }
    
    private func composeAssetDetail(_ assetDetail: AssetDetail, of account: Account, with id: Int64) {
        var assetDetail = assetDetail
        setVerifiedIfNeeded(&assetDetail, with: id)
        account.assetDetails.append(assetDetail)
        api?.session.assetDetails[id] = assetDetail
    }
    
    private func setVerifiedIfNeeded(_ assetDetail: inout AssetDetail, with id: Int64) {
        if let verifiedAssets = api?.session.verifiedAssets,
            verifiedAssets.contains(where: { verifiedAsset -> Bool in
                verifiedAsset.id == id
            }) {
            assetDetail.isVerified = true
        }
    }
}
