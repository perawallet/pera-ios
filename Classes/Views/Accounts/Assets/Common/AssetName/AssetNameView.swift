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
    
    private lazy var nameLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(.overpass, withWeight: .bold(size: 13.0)))
            .withTextColor(SharedColors.black)
            .withLine(.single)
            .withAlignment(.left)
    }()
    
    private lazy var codeLabel: UILabel = {
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
    func setName(_ name: String) {
        nameLabel.text = name
    }
    
    func setCode(_ code: String) {
        codeLabel.text = "(\(code))"
    }
}

extension AssetNameView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let codeLabelOffset: CGFloat = 2.0
    }
}
