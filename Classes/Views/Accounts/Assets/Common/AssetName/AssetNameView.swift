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
    
    private lazy var verifiedImageView: UIImageView = {
        let imageView = UIImageView(image: img("icon-verified"))
        imageView.isHidden = true
        return imageView
    }()
    
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
            .withTextColor(SharedColors.detailText)
            .withLine(.single)
            .withAlignment(.left)
    }()
    
    private(set) lazy var idLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
            .withTextColor(SharedColors.detailText)
            .withLine(.single)
            .withAlignment(.left)
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
        
        nameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
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
            nameLabel.textColor = SharedColors.secondary
            nameLabel.font = UIFont.font(withWeight: .boldItalic(size: 14.0))
        } else if secondDisplayName.isNilOrEmpty && assetDetail.assetName.isNilOrEmpty {
            nameLabel.textColor = SharedColors.subtitleText
        }
        
        nameLabel.text = firstDisplayName
        codeLabel.text = secondDisplayName
        idLabel.text = "\(assetDetail.id)"
        
        verifiedImageView.isHidden = !assetDetail.isVerified
    }
    
    func setVerified(_ hidden: Bool) {
        verifiedImageView.isHidden = !hidden
    }
    
    func setName(_ name: String) {
        nameLabel.text = name
    }
    
    func setCode(_ code: String) {
        codeLabel.text = code
    }
    
    func setId(_ id: String) {
        idLabel.text = id
    }
    
    func removeId() {
        idLabel.removeFromSuperview()
    }
}

extension AssetNameView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let codeLabelOffset: CGFloat = 4.0
        let imageSize = CGSize(width: 20.0, height: 20.0)
        let imageViewOffset: CGFloat = 4.0
    }
}
