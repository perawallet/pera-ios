//
//  AssetDisplayView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 24.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AssetDisplayView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var topContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = SharedColors.secondaryBackground
        view.layer.cornerRadius = 8.0
        return view
    }()
    
    private(set) lazy var assetIndexLabel: UILabel = {
        UILabel()
            .withLine(.single)
            .withAlignment(.center)
            .withFont(UIFont.font(.avenir, withWeight: .regular(size: 14.0)))
            .withTextColor(SharedColors.primaryText)
    }()
    
    private(set) lazy var verifiedImageView: UIImageView = {
        let imageView = UIImageView(image: img("icon-verified"))
        imageView.isHidden = true
        return imageView
    }()
    
    private lazy var copyButton: UIButton = {
        UIButton(type: .custom).withImage(img("icon-copy", isTemplate: true)).withTintColor(SharedColors.gray400)
    }()
    
    private(set) lazy var assetCodeLabel: UILabel = {
        UILabel()
            .withLine(.single)
            .withAlignment(.center)
            .withFont(UIFont.font(withWeight: .bold(size: 28.0)))
            .withTextColor(SharedColors.primary)
    }()
    
    private(set) lazy var assetNameLabel: UILabel = {
        UILabel()
            .withLine(.single)
            .withAlignment(.center)
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
            .withTextColor(SharedColors.primaryText)
    }()
    
    override func configureAppearance() {
        super.configureAppearance()
        layer.cornerRadius = 12.0
        topContainerView.applySmallShadow()
    }
    
    override func setListeners() {
        copyButton.addTarget(self, action: #selector(didTapCopyButton), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        setupTopContainerViewLayout()
        setupVerifiedImageViewLayout()
        setupCopyButtonLayout()
        setupAssetIndexLabelLayout()
        setupAssetCodeLabelLayout()
        setupAssetNameLabelLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        topContainerView.setShadowFrames()
    }
}

extension AssetDisplayView {
    @objc
    private func didTapCopyButton() {
        UIPasteboard.general.string = assetIndexLabel.text
    }
}

extension AssetDisplayView {
    private func setupTopContainerViewLayout() {
        addSubview(topContainerView)
        
        topContainerView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(layout.current.containerInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.containerInset)
            make.height.equalTo(44.0)
        }
    }
    
    private func setupVerifiedImageViewLayout() {
        topContainerView.addSubview(verifiedImageView)
        
        verifiedImageView.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().inset(layout.current.verifiedImageLeadingInset)
            make.size.equalTo(layout.current.imageSize)
        }
    }
    
    private func setupCopyButtonLayout() {
        topContainerView.addSubview(copyButton)
        
        copyButton.snp.makeConstraints { make in
            make.trailing.top.equalToSuperview().inset(layout.current.copyButtonTrailingInset)
            make.size.equalTo(layout.current.copyButtonSize)
        }
    }
    
    private func setupAssetIndexLabelLayout() {
        topContainerView.addSubview(assetIndexLabel)
        
        assetIndexLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.equalTo(verifiedImageView.snp.trailing).offset(layout.current.indexLabelInset)
            make.trailing.equalTo(copyButton.snp.leading).offset(-layout.current.indexLabelInset)
        }
    }
    
    private func setupAssetCodeLabelLayout() {
        addSubview(assetCodeLabel)
        
        assetCodeLabel.snp.makeConstraints { make in
            make.top.equalTo(topContainerView.snp.bottom).offset(layout.current.verticalInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.centerX.equalToSuperview()
        }
    }

    private func setupAssetNameLabelLayout() {
        addSubview(assetNameLabel)
        
        assetNameLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(assetCodeLabel.snp.bottom).offset(layout.current.nameTopInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.bottom.equalToSuperview().inset(layout.current.verticalInset)
        }
    }
}

extension AssetDisplayView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let containerInset: CGFloat = 8.0
        let verifiedImageLeadingInset: CGFloat = 12.0
        let indexLabelInset: CGFloat = 12.0
        let copyButtonTrailingInset: CGFloat = 10.0
        let horizontalInset: CGFloat = 20.0
        let copyButtonSize = CGSize(width: 30.0, height: 30.0)
        let nameTopInset: CGFloat = 4.0
        let verticalInset: CGFloat = 20.0
        let imageSize = CGSize(width: 20.0, height: 20.0)
    }
}

extension AssetDisplayView {
    private enum Colors {
        static let shadowColor = rgba(0.17, 0.17, 0.23, 0.04)
    }
}
