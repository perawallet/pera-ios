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
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
            .withTextColor(SharedColors.primaryText)
            .withLine(.single)
            .withAlignment(.right)
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = SharedColors.primaryBackground
        return view
    }()
    
    override func configureAppearance() {
        backgroundColor = SharedColors.secondaryBackground
    }
    
    override func prepareLayout() {
        setupAssetNameViewLayout()
        setupAmountLabelLayout()
        setupSeparatorViewLayout()
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
    
    private func setupAmountLabelLayout() {
        addSubview(amountLabel)
        
        amountLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        amountLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        amountLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.leading.greaterThanOrEqualTo(assetNameView.snp.trailing).offset(layout.current.assetNameOffet)
        }
    }
    
    private func setupSeparatorViewLayout() {
        addSubview(separatorView)
        
        separatorView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.separatorInset)
            make.height.equalTo(layout.current.separatorHeight)
            make.bottom.equalToSuperview()
        }
    }
}

extension AssetView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0
        let assetNameOffet: CGFloat = 10.0
        let separatorHeight: CGFloat = 1.0
        let separatorInset: CGFloat = 10.0
    }
}
