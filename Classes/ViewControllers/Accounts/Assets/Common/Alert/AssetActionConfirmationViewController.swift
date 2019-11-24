//
//  AssetActionConfirmationViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 11.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol AssetActionConfirmationViewControllerDelegate: class {
    func assetActionConfirmationViewController(
        _ assetActionConfirmationViewController: AssetActionConfirmationViewController,
        didConfirmedActionFor assetDetail: AssetDetail
    )
}

class AssetActionConfirmationViewController: BaseViewController {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: AssetActionConfirmationViewControllerDelegate?
    
    private lazy var assetActionConfirmationView = AssetActionConfirmationView()
    
    private var assetDetail: AssetDetail
    
    init(assetDetail: AssetDetail, configuration: ViewControllerConfiguration) {
        self.assetDetail = assetDetail
        super.init(configuration: configuration)
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

extension AssetActionConfirmationViewController: AssetActionConfirmationViewDelegate {
    func assetActionConfirmationViewDidTapActionButton(_ assetActionConfirmationView: AssetActionConfirmationView) {
        delegate?.assetActionConfirmationViewController(self, didConfirmedActionFor: assetDetail)
        dismissScreen()
    }
    
    func assetActionConfirmationViewDidTapCancelButton(_ assetActionConfirmationView: AssetActionConfirmationView) {
        dismissScreen()
    }
}

extension AssetActionConfirmationViewController {
    struct LayoutConstants: AdaptiveLayoutConstants {
    }
}
