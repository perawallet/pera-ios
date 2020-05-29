//
//  AssetActionConfirmationViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 11.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit
import SVProgressHUD

class AssetActionConfirmationViewController: BaseViewController {
    
    weak var delegate: AssetActionConfirmationViewControllerDelegate?
    
    private lazy var assetActionConfirmationView = AssetActionConfirmationView()
    
    private let viewModel = AssetActionConfirmationViewModel()
    
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
        viewModel.configure(assetActionConfirmationView, with: assetAlertDraft)
    }
    
    override func setListeners() {
        assetActionConfirmationView.delegate = self
    }
    
    override func prepareLayout() {
        setupAssetActionConfirmationViewLayout()
    }
}

extension AssetActionConfirmationViewController {
    private func setupAssetActionConfirmationViewLayout() {
        view.addSubview(assetActionConfirmationView)
        
        assetActionConfirmationView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension AssetActionConfirmationViewController {
    private func fetchAssetDetailIfNeeded() {
        if !assetAlertDraft.isValid() {
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
        viewModel.configure(self.assetActionConfirmationView.assetDisplayView, with: assetAlertDraft)
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

extension AssetActionConfirmationViewController: AssetActionConfirmationViewDelegate {
    func assetActionConfirmationViewDidTapActionButton(_ assetActionConfirmationView: AssetActionConfirmationView) {
        if let assetDetail = assetAlertDraft.assetDetail {
            delegate?.assetActionConfirmationViewController(self, didConfirmedActionFor: assetDetail)
        }
        dismissScreen()
    }
    
    func assetActionConfirmationViewDidTapCancelButton(_ assetActionConfirmationView: AssetActionConfirmationView) {
        dismissScreen()
    }
}

protocol AssetActionConfirmationViewControllerDelegate: class {
    func assetActionConfirmationViewController(
        _ assetActionConfirmationViewController: AssetActionConfirmationViewController,
        didConfirmedActionFor assetDetail: AssetDetail
    )
}
