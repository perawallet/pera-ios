//
//  AssetSupportAlertView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 24.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol AssetSupportAlertViewDelegate: class {
    func assetSupportAlertViewDidTapOKButton(_ assetSupportAlertView: AssetSupportAlertView)
    func assetSupportAlertViewDidTapCancelButton(_ assetSupportAlertView: AssetSupportAlertView)
}

class AssetSupportAlertView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: AssetSupportAlertViewDelegate?
    
    private lazy var titleLabel: UILabel = {
        UILabel()
    }()
    
    private lazy var assetDisplayView = AssetDisplayView()
    
    private lazy var detailLabel: UILabel = {
        UILabel()
    }()
    
    private lazy var okButton: UIButton = {
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
        setupOKButtonLayout()
        setupCancelButtonLayout()
    }
    
    override func setListeners() {
        okButton.addTarget(self, action: #selector(notifyDelegateToOKButtonTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(notifyDelegateToCancelButtonTapped), for: .touchUpInside)
    }
}

extension AssetSupportAlertView {
    @objc
    private func notifyDelegateToOKButtonTapped() {
        delegate?.assetSupportAlertViewDidTapOKButton(self)
    }
    
    @objc
    private func notifyDelegateToCancelButtonTapped() {
        delegate?.assetSupportAlertViewDidTapCancelButton(self)
    }
}

extension AssetSupportAlertView {
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
    
    private func setupOKButtonLayout() {
        addSubview(okButton)
        
        okButton.snp.makeConstraints { _ in
            
        }
    }

    private func setupCancelButtonLayout() {
        addSubview(cancelButton)
        
        cancelButton.snp.makeConstraints { _ in
            
        }
    }
}

extension AssetSupportAlertView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        
    }
}
