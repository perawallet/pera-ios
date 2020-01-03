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
    
    private(set) lazy var assetNameView = AssetNameView()
    
    private(set) lazy var detailLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(.avenir, withWeight: .demiBold(size: 14.0)))
            .withTextColor(SharedColors.darkGray)
            .withLine(.single)
            .withAlignment(.right)
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.separatorColor
        return view
    }()
    
    override func configureAppearance() {
        backgroundColor = .white
    }
    
    override func prepareLayout() {
        setupAssetNameViewLayout()
        setupDetailLabelLayout()
        setupSeparatorViewLayout()
    }
}

extension AssetSelectionView {
    private func setupAssetNameViewLayout() {
        addSubview(assetNameView)
        
        assetNameView.setContentCompressionResistancePriority(.required, for: .horizontal)
        assetNameView.setContentHuggingPriority(.required, for: .horizontal)
        
        assetNameView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.centerY.equalToSuperview()
        }
    }
    
    private func setupDetailLabelLayout() {
        addSubview(detailLabel)
        
        detailLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        detailLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        detailLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
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
        let horizontalInset: CGFloat = 25.0
    }
}

extension AssetSelectionView {
    private enum Colors {
        static let separatorColor = rgb(0.91, 0.91, 0.92)
    }
}
