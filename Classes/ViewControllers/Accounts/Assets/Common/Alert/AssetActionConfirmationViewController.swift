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
    
    private let viewModel = AssetActionConfirmationViewModel()
    
    private var assetAlertDraft: AssetAlertDraft
    
    init(assetAlertDraft: AssetAlertDraft, configuration: ViewControllerConfiguration) {
        self.assetAlertDraft = assetAlertDraft
        super.init(configuration: configuration)
    }
    
    override func configureAppearance() {
        view.backgroundColor = Colors.backgroundColor
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
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
}

extension AssetActionConfirmationViewController: AssetActionConfirmationViewDelegate {
    func assetActionConfirmationViewDidTapActionButton(_ assetActionConfirmationView: AssetActionConfirmationView) {
        delegate?.assetActionConfirmationViewController(self, didConfirmedActionFor: assetAlertDraft.assetDetail)
        dismissScreen()
    }
    
    func assetActionConfirmationViewDidTapCancelButton(_ assetActionConfirmationView: AssetActionConfirmationView) {
        dismissScreen()
    }
}

extension AssetActionConfirmationViewController {
    struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0
    }
}

extension AssetActionConfirmationViewController {
    private enum Colors {
        static let backgroundColor = rgba(0.29, 0.29, 0.31, 0.6)
    }
}
