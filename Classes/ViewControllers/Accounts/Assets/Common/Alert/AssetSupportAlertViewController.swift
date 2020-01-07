//
//  AssetSupportAlertViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 24.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit
import SVProgressHUD

class AssetSupportAlertViewController: BaseViewController {
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var assetSupportAlertView = AssetSupportAlertView()
    
    private let viewModel = AssetSupportAlertViewModel()
    
    private var assetAlertDraft: AssetAlertDraft
    
    init(assetAlertDraft: AssetAlertDraft, configuration: ViewControllerConfiguration) {
        self.assetAlertDraft = assetAlertDraft
        super.init(configuration: configuration)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if assetAlertDraft.assetDetail == nil {
            SVProgressHUD.show(withStatus: "title-loading".localized)
            api?.getAssetDetails(with: AssetFetchDraft(assetId: assetAlertDraft.assetIndex)) { response in
                switch response {
                case let .success(assetDetail):
                    SVProgressHUD.showSuccess(withStatus: "title-done-lowercased".localized)
                    SVProgressHUD.dismiss()
                    
                    if let verifiedAssets = self.session?.verifiedAssets,
                        verifiedAssets.contains(where: { verifiedAsset -> Bool in
                            "\(verifiedAsset.id)" == self.assetAlertDraft.assetIndex
                        }) {
                        assetDetail.isVerified = true
                    }
                    
                    self.assetAlertDraft.assetDetail = assetDetail
                    self.viewModel.configure(self.assetSupportAlertView.assetDisplayView, with: self.assetAlertDraft)
                case .failure:
                    SVProgressHUD.showError(withStatus: nil)
                    SVProgressHUD.dismiss()
                }
            }
        }
    }
    
    override func configureAppearance() {
        view.backgroundColor = Colors.backgroundColor
        viewModel.configure(assetSupportAlertView, with: assetAlertDraft)
    }
    
    override func setListeners() {
        assetSupportAlertView.delegate = self
    }
    
    override func prepareLayout() {
        setupAssetSupportAlertViewLayout()
    }
}

extension AssetSupportAlertViewController {
    private func setupAssetSupportAlertViewLayout() {
        view.addSubview(assetSupportAlertView)
        
        assetSupportAlertView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
}

extension AssetSupportAlertViewController: AssetSupportAlertViewDelegate {
    func assetSupportAlertViewDidTapOKButton(_ assetSupportAlertView: AssetSupportAlertView) {
        dismissScreen()
    }
}

extension AssetSupportAlertViewController {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0
    }
}

extension AssetSupportAlertViewController {
    private enum Colors {
        static let backgroundColor = rgba(0.29, 0.29, 0.31, 0.6)
    }
}
