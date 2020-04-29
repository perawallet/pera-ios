//
//  AssetNameView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 23.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AssetNameView: BaseView {

    private let layout = Layout<LayoutConstants>()
    
    private(set) lazy var nameLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
            .withTextColor(SharedColors.primaryText)
            .withLine(.single)
            .withAlignment(.left)
    }()
    
    private(set) lazy var codeLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
            .withTextColor(SharedColors.subtitleText)
            .withLine(.single)
            .withAlignment(.left)
    }()
    
    private(set) lazy var idLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
            .withTextColor(SharedColors.subtitleText)
            .withLine(.single)
            .withAlignment(.left)
    }()
    
    private(set) lazy var verifiedImageView: UIImageView = {
        let imageView = UIImageView(image: img("icon-verified"))
        imageView.isHidden = true
        return imageView
    }()
    
    override func configureAppearance() {
        backgroundColor = .clear
    }
    
    override func prepareLayout() {
        setupNameLabelLayout()
        setupCodeLabelLayout()
        setupIdLabelLayout()
        setupVerifiedImageViewLayout()
    }
}

extension AssetNameView {
    private func setupNameLabelLayout() {
        addSubview(nameLabel)
        
        nameLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        nameLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        nameLabel.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
        }
    }

    private func setupCodeLabelLayout() {
        addSubview(codeLabel)
        
        codeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        codeLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        codeLabel.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel.snp.trailing).offset(layout.current.codeLabelOffset)
            make.top.bottom.equalToSuperview()
        }
    }
    
    private func setupIdLabelLayout() {
        addSubview(idLabel)
        
        idLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        idLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        idLabel.snp.makeConstraints { make in
            make.leading.equalTo(codeLabel.snp.trailing).offset(layout.current.codeLabelOffset)
            make.top.bottom.equalToSuperview()
        }
    }
    
    private func setupVerifiedImageViewLayout() {
        addSubview(verifiedImageView)
        
        verifiedImageView.snp.makeConstraints { make in
            make.leading.equalTo(idLabel.snp.trailing).offset(layout.current.imageViewOffset)
            make.leading.equalTo(codeLabel.snp.trailing).offset(layout.current.imageViewOffset).priority(.low)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview()
            make.size.equalTo(layout.current.imageSize)
        }
    }
}

extension AssetNameView {
    func setAssetName(for assetDetail: AssetDetail) {
        let (firstDisplayName, secondDisplayName) = assetDetail.getDisplayNames()
        
        if firstDisplayName.isUnknown() && !assetDetail.hasDisplayName() {
            nameLabel.textColor = SharedColors.orange
            nameLabel.font = UIFont.font(.overpass, withWeight: .boldItalic(size: 13.0))
        } else if secondDisplayName.isNilOrEmpty && assetDetail.assetName.isNilOrEmpty {
            nameLabel.textColor = SharedColors.subtitleText
        }
        
        nameLabel.text = firstDisplayName
        codeLabel.text = secondDisplayName
        
        if let assetId = assetDetail.id {
            idLabel.text = "\(assetId)"
        }
        
        verifiedImageView.isHidden = !assetDetail.isVerified
    }
}

extension AssetNameView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let codeLabelOffset: CGFloat = 2.0
        let imageSize = CGSize(width: 20.0, height: 20.0)
        let imageViewOffset: CGFloat = 4.0
    }
}
