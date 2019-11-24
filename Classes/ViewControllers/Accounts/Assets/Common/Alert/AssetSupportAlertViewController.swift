//
//  AssetSupportAlertViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 24.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AssetSupportAlertViewController: BaseViewController {
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var assetSupportAlertView = AssetSupportAlertView()
    
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
            make.edges.equalToSuperview()
        }
    }
}

extension AssetSupportAlertViewController: AssetSupportAlertViewDelegate {
    func assetSupportAlertViewDidTapOKButton(_ assetSupportAlertView: AssetSupportAlertView) {
        
    }
    
    func assetSupportAlertViewDidTapCancelButton(_ assetSupportAlertView: AssetSupportAlertView) {
        dismissScreen()
    }
}

extension AssetSupportAlertViewController {
    struct LayoutConstants: AdaptiveLayoutConstants {
    }
}
