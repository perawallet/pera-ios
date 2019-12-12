//
//  PendingAssetView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 10.12.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class PendingAssetView: BaseView {

    private let layout = Layout<LayoutConstants>()
    
    private(set) lazy var pendingSpinnerView = LoadingSpinnerView()
    
    private(set) lazy var assetNameView: AssetNameView = {
        let view = AssetNameView()
        view.nameLabel.alpha = 0.4
        view.codeLabel.alpha = 0.4
        return view
    }()
    
    private(set) lazy var detailLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(.overpass, withWeight: .bold(size: 13.0)))
            .withTextColor(SharedColors.darkGray)
            .withLine(.single)
            .withAlignment(.right)
    }()
    
    override func configureAppearance() {
        backgroundColor = .white
    }
    
    override func prepareLayout() {
        setupLoadingImageViewLayout()
        setupAssetNameViewLayout()
        setupDetailLabelLayout()
    }
}

extension PendingAssetView {
    private func setupLoadingImageViewLayout() {
        addSubview(pendingSpinnerView)
        
        pendingSpinnerView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.size.equalTo(layout.current.spinnerSize)
        }
    }
    
    private func setupAssetNameViewLayout() {
        addSubview(assetNameView)
        
        assetNameView.setContentCompressionResistancePriority(.required, for: .horizontal)
        assetNameView.setContentHuggingPriority(.required, for: .horizontal)
        
        assetNameView.snp.makeConstraints { make in
            make.leading.equalTo(pendingSpinnerView.snp.trailing).offset( layout.current.spinnerOffset)
            make.centerY.equalToSuperview()
        }
    }
    
    private func setupDetailLabelLayout() {
        addSubview(detailLabel)
        
        detailLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        detailLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        detailLabel.snp.makeConstraints { make in
            make.centerY.equalTo(assetNameView)
            make.trailing.equalToSuperview().inset(layout.current.labelInset)
            make.leading.greaterThanOrEqualTo(assetNameView.snp.trailing).offset(layout.current.labelInset)
        }
    }
}

extension PendingAssetView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 15.0
        let labelInset: CGFloat = 10.0
        let spinnerOffset: CGFloat = 8.0
        let spinnerSize = CGSize(width: 22.0, height: 22.0)
    }
}
