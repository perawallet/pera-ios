//
//  AssetActionConfirmationView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 11.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol AssetActionConfirmationViewDelegate: class {
    func assetActionConfirmationViewDidTapActionButton(_ assetActionConfirmationView: AssetActionConfirmationView)
    func assetActionConfirmationViewDidTapCancelButton(_ assetActionConfirmationView: AssetActionConfirmationView)
}

class AssetActionConfirmationView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: AssetActionConfirmationViewDelegate?
    
    private lazy var titleLabel: UILabel = {
        UILabel()
    }()
    
    private lazy var assetDisplayView = AssetDisplayView()
    
    private lazy var detailLabel: UILabel = {
        UILabel()
    }()
    
    private lazy var actionButton: UIButton = {
        UIButton(type: .custom)
    }()
    
    private lazy var cancelButton: UIButton = {
        UIButton(type: .custom)
    }()
    
    override func configureAppearance() {
        backgroundColor = .white
    }
    
    override func prepareLayout() {
        setupTitleLabelLayout()
        setupAssetDisplayViewLayout()
        setupDetailLabelLayout()
        setupActionButtonLayout()
        setupCancelButtonLayout()
    }
    
    override func setListeners() {
        actionButton.addTarget(self, action: #selector(notifyDelegateToActionButtonTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(notifyDelegateToCancelButtonTapped), for: .touchUpInside)
    }
}

extension AssetActionConfirmationView {
    @objc
    private func notifyDelegateToActionButtonTapped() {
        delegate?.assetActionConfirmationViewDidTapActionButton(self)
    }
    
    @objc
    private func notifyDelegateToCancelButtonTapped() {
        delegate?.assetActionConfirmationViewDidTapCancelButton(self)
    }
}

extension AssetActionConfirmationView {
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { _ in
            
        }
    }

    private func setupAssetDisplayViewLayout() {
        addSubview(assetDisplayView)
        
        assetDisplayView.snp.makeConstraints { _ in
            
        }
    }
    
    private func setupDetailLabelLayout() {
        addSubview(detailLabel)
        
        detailLabel.snp.makeConstraints { _ in
            
        }
    }
    
    private func setupActionButtonLayout() {
        addSubview(actionButton)
        
        actionButton.snp.makeConstraints { _ in
            
        }
    }

    private func setupCancelButtonLayout() {
        addSubview(cancelButton)
        
        cancelButton.snp.makeConstraints { _ in
            
        }
    }
}

extension AssetActionConfirmationView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        
    }
}
