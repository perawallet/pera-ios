//
//  AssetView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 11.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AssetView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private(set) lazy var assetNameView: AssetNameView = {
        let view = AssetNameView()
        view.idLabel.removeFromSuperview()
        return view
    }()
    
    private(set) lazy var amountLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(.overpass, withWeight: .bold(size: 14.0)))
            .withTextColor(SharedColors.darkGray)
            .withLine(.single)
            .withAlignment(.right)
    }()
    
    private lazy var arrowImageView = UIImageView(image: img("icon-arrow-gray"))
    
    override func configureAppearance() {
        backgroundColor = .white
    }
    
    override func prepareLayout() {
        setupAssetNameViewLayout()
        setupArrowImageViewLayout()
        setupAmountLabelLayout()
    }
}

extension AssetView {
    private func setupAssetNameViewLayout() {
        addSubview(assetNameView)
        
        assetNameView.setContentCompressionResistancePriority(.required, for: .horizontal)
        assetNameView.setContentHuggingPriority(.required, for: .horizontal)
        
        assetNameView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.centerY.equalToSuperview()
        }
    }
    
    private func setupArrowImageViewLayout() {
        addSubview(arrowImageView)
        
        arrowImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(layout.current.imageInset)
            make.size.equalTo(layout.current.arrowImageSize)
            make.centerY.equalToSuperview()
        }
    }
    
    private func setupAmountLabelLayout() {
        addSubview(amountLabel)
        
        amountLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        amountLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        amountLabel.snp.makeConstraints { make in
            make.centerY.equalTo(arrowImageView)
            make.trailing.equalTo(arrowImageView.snp.leading).offset(-layout.current.imageInset)
            make.leading.greaterThanOrEqualTo(assetNameView.snp.trailing).offset(layout.current.imageInset)
        }
    }
}

extension AssetView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 15.0
        let imageInset: CGFloat = 10.0
        let arrowImageSize = CGSize(width: 20.0, height: 20.0)
    }
}
