//
//  AssetSelectionView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 18.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AssetSelectionView: BaseView {

    private let layout = Layout<LayoutConstants>()
    
    private(set) lazy var assetNameView: AssetNameView = {
        let view = AssetNameView()
        view.removeId()
        return view
    }()
    
    private(set) lazy var detailLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
            .withTextColor(SharedColors.gray700)
            .withLine(.single)
            .withAlignment(.right)
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = SharedColors.gray100
        return view
    }()
    
    override func configureAppearance() {
        backgroundColor = SharedColors.secondaryBackground
    }
    
    override func prepareLayout() {
        setupDetailLabelLayout()
        setupAssetNameViewLayout()
        setupSeparatorViewLayout()
    }
}

extension AssetSelectionView {
    private func setupDetailLabelLayout() {
        addSubview(detailLabel)
        
        detailLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        detailLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        detailLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.centerY.equalToSuperview()
        }
    }
    
    private func setupAssetNameViewLayout() {
        addSubview(assetNameView)
        
        assetNameView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.trailing.lessThanOrEqualTo(detailLabel.snp.leading).offset(-4.0)
            make.centerY.equalToSuperview()
        }
    }
    
    private func setupSeparatorViewLayout() {
        addSubview(separatorView)
        
        separatorView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.height.equalTo(layout.current.separatorHeight)
            make.bottom.equalToSuperview()
        }
    }
}

extension AssetSelectionView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let separatorHeight: CGFloat = 1.0
        let codeLabelInset: CGFloat = 3.0
        let horizontalInset: CGFloat = 20.0
    }
}
