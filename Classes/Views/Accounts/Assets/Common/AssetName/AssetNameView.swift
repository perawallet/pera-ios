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
            .withFont(UIFont.font(.overpass, withWeight: .bold(size: 13.0)))
            .withTextColor(SharedColors.black)
            .withLine(.single)
            .withAlignment(.left)
    }()
    
    private(set) lazy var codeLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(.overpass, withWeight: .bold(size: 13.0)))
            .withTextColor(SharedColors.purple)
            .withLine(.single)
            .withAlignment(.left)
    }()
    
    override func configureAppearance() {
        backgroundColor = .clear
    }
    
    override func prepareLayout() {
        setupNameLabelLayout()
        setupCodeLabelLayout()
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
            make.trailing.top.bottom.equalToSuperview()
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
            nameLabel.textColor = SharedColors.purple
        }
        
        nameLabel.text = firstDisplayName
        codeLabel.text = secondDisplayName
    }
}

extension AssetNameView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let codeLabelOffset: CGFloat = 2.0
    }
}
