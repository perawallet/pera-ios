//
//  SelectAssetHeaderView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 6.05.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class SelectAssetHeaderView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var imageView = UIImageView()
    
    private lazy var titleLabel: UILabel = {
        UILabel().withAlignment(.left).withFont(UIFont.font(withWeight: .medium(size: 14.0))).withTextColor(Colors.Text.primary)
    }()
    
    override func configureAppearance() {
        backgroundColor = Colors.Component.assetHeader
    }
    
    override func prepareLayout() {
        setupImageViewLayout()
        setupTitleLabelLayout()
    }
}

extension SelectAssetHeaderView {
    private func setupImageViewLayout() {
        imageView.contentMode = .scaleAspectFit
        
        addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.size.equalTo(layout.current.imageSize)
            make.top.bottom.equalToSuperview().inset(layout.current.verticalInset)
        }
    }
    
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(layout.current.labelInset)
            make.centerY.equalTo(imageView)
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
}

extension SelectAssetHeaderView {
    func bind(_ viewModel: SelectAssetViewModel) {
        titleLabel.text = viewModel.accountName
        imageView.image = viewModel.accountImage
    }
}

extension SelectAssetHeaderView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 16.0
        let containerInset: CGFloat = 4.0
        let labelInset: CGFloat = 12.0
        let buttonSize = CGSize(width: 40.0, height: 40.0)
        let imageSize = CGSize(width: 24.0, height: 24.0)
        let verticalInset: CGFloat = 12.0
        let buttonOffset: CGFloat = 2.0
        let trailingInset: CGFloat = 8.0
    }
}
