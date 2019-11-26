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
    
    private let viewModel = AssetDisplayViewModel()
    
    private var assetAlertDraft: AssetAlertDraft
    
    init(assetAlertDraft: AssetAlertDraft, configuration: ViewControllerConfiguration) {
        self.assetAlertDraft = assetAlertDraft
        super.init(configuration: configuration)
    }
    
    override func configureAppearance() {
        view.backgroundColor = Colors.backgroundColor
        viewModel.configure(assetSupportAlertView.assetDisplayView, with: assetAlertDraft)
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
            make.centerX.equalToSuperview()
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
