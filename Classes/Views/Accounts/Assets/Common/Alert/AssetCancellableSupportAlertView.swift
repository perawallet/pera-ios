//
//  AssetCancellableSupportAlertView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 25.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol AssetCancellableSupportAlertViewDelegate: class {
    func assetCancellableSupportAlertViewDidTapOKButton(_ assetCancellableSupportAlertView: AssetCancellableSupportAlertView)
    func assetCancellableSupportAlertViewDidTapCancelButton(_ assetCancellableSupportAlertView: AssetCancellableSupportAlertView)
}

class AssetCancellableSupportAlertView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: AssetCancellableSupportAlertViewDelegate?
    
    private(set) lazy var titleLabel: UILabel = {
        UILabel()
            .withLine(.single)
            .withAlignment(.center)
            .withFont(UIFont.font(.overpass, withWeight: .bold(size: 16.0)))
            .withText("asset-support-qr-title".localized)
    }()
    
    private(set) lazy var assetDisplayView = AssetDisplayView()
    
    private(set) lazy var detailLabel: UILabel = {
        UILabel()
            .withLine(.contained)
            .withAlignment(.center)
            .withFont(UIFont.font(.avenir, withWeight: .medium(size: 14.0)))
            .withText("asset-support-qr-error".localized)
    }()
    
    private lazy var okButton: UIButton = {
        UIButton(type: .custom)
            .withBackgroundImage(img("bg-black-button"))
            .withTitle("title-ok".localized)
            .withAlignment(.center)
            .withFont(UIFont.font(.avenir, withWeight: .demiBold(size: 12.0)))
            .withTitleColor(UIColor.white)
    }()
    
    private lazy var cancelButton: UIButton = {
        UIButton(type: .custom)
            .withTitle("title-cancel".localized)
            .withAlignment(.center)
            .withFont(UIFont.font(.avenir, withWeight: .demiBold(size: 12.0)))
            .withTitleColor(SharedColors.darkGray)
    }()
    
    override func configureAppearance() {
        backgroundColor = .white
        layer.cornerRadius = 10.0
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

extension AssetCancellableSupportAlertView {
    @objc
    private func notifyDelegateToOKButtonTapped() {
        delegate?.assetCancellableSupportAlertViewDidTapOKButton(self)
    }
    
    @objc
    private func notifyDelegateToCancelButtonTapped() {
        delegate?.assetCancellableSupportAlertViewDidTapCancelButton(self)
    }
}

extension AssetCancellableSupportAlertView {
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(layout.current.titleLabelTopInset)
        }
    }

    private func setupAssetDisplayViewLayout() {
        addSubview(assetDisplayView)
        
        assetDisplayView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.displayViewTopInset)
        }
    }
    
    private func setupDetailLabelLayout() {
        addSubview(detailLabel)
        
        detailLabel.snp.makeConstraints { make in
            make.top.equalTo(assetDisplayView.snp.bottom).offset(layout.current.verticalInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupOKButtonLayout() {
        addSubview(okButton)
        
        okButton.snp.makeConstraints { make in
            make.top.equalTo(detailLabel.snp.bottom).offset(layout.current.verticalInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }

    private func setupCancelButtonLayout() {
        addSubview(cancelButton)
        
        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(okButton.snp.bottom).offset(layout.current.buttonOffset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.bottom.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
}

extension AssetCancellableSupportAlertView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let verticalInset: CGFloat = 35.0
        let titleLabelTopInset: CGFloat = 30.0
        let displayViewTopInset: CGFloat = 24.0
        let horizontalInset: CGFloat = 25.0
        let buttonOffset: CGFloat = 10.0
    }
}
