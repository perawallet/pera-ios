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
    
    override var intrinsicContentSize: CGSize {
        return layout.current.size
    }
    
    private(set) lazy var assetIndexLabel: UILabel = {
        UILabel()
            .withLine(.single)
            .withAlignment(.center)
            .withFont(UIFont.font(.avenir, withWeight: .demiBold(size: 14.0)))
            .withTextColor(SharedColors.darkGray)
    }()
    
    private(set) lazy var verifiedImageView: UIImageView = {
        let imageView = UIImageView(image: img("icon-verified"))
        imageView.isHidden = true
        return imageView
    }()
    
    private lazy var copyButton: UIButton = {
        UIButton(type: .custom).withImage(img("icon-copy"))
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.separatorColor
        return view
    }()
    
    private(set) lazy var assetCodeLabel: UILabel = {
        UILabel()
            .withLine(.single)
            .withAlignment(.center)
            .withFont(UIFont.font(.avenir, withWeight: .bold(size: 40.0)))
            .withTextColor(SharedColors.darkGray)
    }()
    
    private(set) lazy var assetNameLabel: UILabel = {
        UILabel()
            .withLine(.single)
            .withAlignment(.center)
            .withFont(UIFont.font(.avenir, withWeight: .demiBold(size: 14.0)))
            .withTextColor(SharedColors.black)
    }()
    
    override func configureAppearance() {
        backgroundColor = .white
        layer.cornerRadius = 6.0
        layer.borderWidth = 1.0
        layer.borderColor = Colors.separatorColor.cgColor
    }
    
    override func prepareLayout() {
        setupAssetIndexLabelLayout()
        setupCopyButtonLayout()
        setupVerifiedImageViewLayout()
        setupSeparatorViewLayout()
        setupAssetCodeLabelLayout()
        setupAssetNameLabelLayout()
    }
    
    override func setListeners() {
        copyButton.addTarget(self, action: #selector(didTapCopyButton), for: .touchUpInside)
    }
}

extension AssetDisplayView {
    @objc
    private func didTapCopyButton() {
        UIPasteboard.general.string = assetIndexLabel.text
    }
}

extension AssetDisplayView {
    private func setupAssetIndexLabelLayout() {
        addSubview(assetIndexLabel)
        
        assetIndexLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(layout.current.indexVerticalInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.indexHorizontalInset)
        }
    }
    
    private func setupCopyButtonLayout() {
        addSubview(copyButton)
        
        copyButton.snp.makeConstraints { make in
            make.trailing.top.equalToSuperview()
            make.size.equalTo(layout.current.copyButtonSize)
        }
    }
    
    private func setupVerifiedImageViewLayout() {
        addSubview(verifiedImageView)
        
        verifiedImageView.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().inset(layout.current.imageViewOffset)
            make.size.equalTo(layout.current.imageSize)
        }
    }
    
    private func setupSeparatorViewLayout() {
        addSubview(separatorView)
        
        separatorView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(layout.current.separatorHeight)
            make.top.equalTo(assetIndexLabel.snp.bottom).offset(layout.current.indexVerticalInset)
        }
    }
    
    private func setupAssetCodeLabelLayout() {
        addSubview(assetCodeLabel)
        
        assetCodeLabel.snp.makeConstraints { make in
            make.top.equalTo(separatorView.snp.bottom).offset(layout.current.codeVerticalInset)
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
        }
    }
}

extension AssetDisplayView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let size = CGSize(width: 225.0, height: 136.0)
        let separatorHeight: CGFloat = 1.0
        let indexHorizontalInset: CGFloat = 30.0
        let horizontalInset: CGFloat = 20.0
        let copyButtonSize = CGSize(width: 30.0, height: 30.0)
        let indexVerticalInset: CGFloat = 8.0
        let nameTopInset: CGFloat = 5.0
        let codeVerticalInset: CGFloat = 15.0
        let bottomInset: CGFloat = 13.0
        let imageSize = CGSize(width: 13.0, height: 13.0)
        let imageViewOffset: CGFloat = 10.0
    }
}

extension AssetDisplayView {
    private enum Colors {
        static let separatorColor = rgb(0.91, 0.91, 0.92)
    }
}
