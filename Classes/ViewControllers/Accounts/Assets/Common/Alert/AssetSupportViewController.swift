//
//  AssetSupportViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 24.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit
import SVProgressHUD

class AssetSupportViewController: BaseViewController {
    
    private lazy var assetSupportView = AssetSupportView()
    
    private let viewModel = AssetSupportViewModel()
    
    private var assetAlertDraft: AssetAlertDraft
    
    init(assetAlertDraft: AssetAlertDraft, configuration: ViewControllerConfiguration) {
        self.assetAlertDraft = assetAlertDraft
        super.init(configuration: configuration)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchAssetDetailIfNeeded()
    }
    
    override func configureAppearance() {
        view.backgroundColor = SharedColors.secondaryBackground
        viewModel.configure(assetSupportView, with: assetAlertDraft)
    }
    
    override func setListeners() {
        assetSupportView.delegate = self
    }
    
    override func prepareLayout() {
        setupAssetSupportViewLayout()
    }
}

extension AssetSupportViewController {
    private func setupAssetSupportViewLayout() {
        view.addSubview(assetSupportView)
        
        assetSupportView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension AssetSupportViewController {
    private func fetchAssetDetailIfNeeded() {
        if assetAlertDraft.assetDetail == nil {
            SVProgressHUD.show(withStatus: "title-loading".localized)
            api?.getAssetDetails(with: AssetFetchDraft(assetId: "\(assetAlertDraft.assetIndex)")) { response in
                switch response {
                case let .success(asset):
                    self.handleAssetDetailSetup(with: asset)
                case .failure:
                    SVProgressHUD.showError(withStatus: nil)
                    SVProgressHUD.dismiss()
                }
            }
        }
    }
    
    private func handleAssetDetailSetup(with asset: AssetDetail) {
        SVProgressHUD.showSuccess(withStatus: "title-done".localized)
        SVProgressHUD.dismiss()
        var assetDetail = asset
        setVerifiedIfNeeded(&assetDetail)
        assetAlertDraft.assetDetail = assetDetail
        viewModel.configure(self.assetSupportView.assetDisplayView, with: assetAlertDraft)
    }
    
    private func setVerifiedIfNeeded(_ assetDetail: inout AssetDetail) {
        if let verifiedAssets = self.session?.verifiedAssets,
            verifiedAssets.contains(where: { verifiedAsset -> Bool in
                verifiedAsset.id == self.assetAlertDraft.assetIndex
            }) {
            assetDetail.isVerified = true
        }
    }
}

extension AssetSupportViewController: AssetSupportViewDelegate {
    func assetSupportViewDidTapOKButton(_ assetSupportView: AssetSupportView) {
        dismissScreen()
    }
}
