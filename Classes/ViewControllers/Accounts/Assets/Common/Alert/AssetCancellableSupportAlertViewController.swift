//
//  AssetCancellableSupportAlertViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 26.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit
import SVProgressHUD

protocol AssetCancellableSupportAlertViewControllerDelegate: class {
    func assetCancellableSupportAlertViewControllerDidTapOKButton(
        _ assetCancellableSupportAlertViewController: AssetCancellableSupportAlertViewController
    )
}

class AssetCancellableSupportAlertViewController: BaseViewController {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: AssetCancellableSupportAlertViewControllerDelegate?
    
    private lazy var assetCancellableSupportAlertView = AssetCancellableSupportAlertView()
    
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
            api?.getAssetDetails(with: AssetFetchDraft(assetId: "\(assetAlertDraft.assetIndex)")) { response in
                switch response {
                case let .success(assetDetail):
                    SVProgressHUD.showSuccess(withStatus: "title-done-lowercased".localized)
                    SVProgressHUD.dismiss()
                    
                    if let verifiedAssets = self.session?.verifiedAssets,
                        verifiedAssets.contains(where: { verifiedAsset -> Bool in
                            verifiedAsset.id == self.assetAlertDraft.assetIndex
                        }) {
                        assetDetail.isVerified = true
                    }
                    
                    self.assetAlertDraft.assetDetail = assetDetail
                    self.viewModel.configure(self.assetCancellableSupportAlertView.assetDisplayView, with: self.assetAlertDraft)
                case .failure:
                    SVProgressHUD.showError(withStatus: nil)
                    SVProgressHUD.dismiss()
                }
            }
        }
    }
    
    override func configureAppearance() {
        view.backgroundColor = Colors.backgroundColor
        viewModel.configure(assetCancellableSupportAlertView, with: assetAlertDraft)
    }
    
    override func setListeners() {
        assetCancellableSupportAlertView.delegate = self
    }
    
    override func prepareLayout() {
        setupCancellableAssetSupportAlertViewLayout()
    }
}

extension AssetCancellableSupportAlertViewController {
    private func setupCancellableAssetSupportAlertViewLayout() {
        view.addSubview(assetCancellableSupportAlertView)
        
        assetCancellableSupportAlertView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
}

extension AssetCancellableSupportAlertViewController: AssetCancellableSupportAlertViewDelegate {
    func assetCancellableSupportAlertViewDidTapOKButton(_ assetCancellableSupportAlertView: AssetCancellableSupportAlertView) {
        delegate?.assetCancellableSupportAlertViewControllerDidTapOKButton(self)
        dismissScreen()
    }
    
    func assetCancellableSupportAlertViewDidTapCancelButton(_ assetCancellableSupportAlertView: AssetCancellableSupportAlertView) {
        dismissScreen()
    }
}

extension AssetCancellableSupportAlertViewController {
    struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0
    }
}

extension AssetCancellableSupportAlertViewController {
    private enum Colors {
        static let backgroundColor = rgba(0.29, 0.29, 0.31, 0.6)
    }
}
