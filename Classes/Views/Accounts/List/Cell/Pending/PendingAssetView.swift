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
    
    private lazy var pendingImageView = UIImageView(image: img("icon-pending"))
    
    private(set) lazy var assetNameView: AssetNameView = {
        let view = AssetNameView()
        view.removeId()
        view.nameLabel.textColor = SharedColors.gray600
        view.codeLabel.textColor = SharedColors.gray400
        return view
    }()
    
    private(set) lazy var detailLabel: UILabel = {
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
        setupPendingImageViewLayout()
        setupAssetNameViewLayout()
        setupDetailLabelLayout()
        setupSeparatorViewLayout()
    }
}

extension PendingAssetView {
    private func setupPendingImageViewLayout() {
        addSubview(pendingImageView)
        
        pendingImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.size.equalTo(layout.current.imageViewSize)
        }
    }
    
    private func setupAssetNameViewLayout() {
        addSubview(assetNameView)
        
        assetNameView.setContentCompressionResistancePriority(.required, for: .horizontal)
        assetNameView.setContentHuggingPriority(.required, for: .horizontal)
        
        assetNameView.snp.makeConstraints { make in
            make.leading.equalTo(pendingImageView.snp.trailing).offset( layout.current.imageViewOffset)
            make.centerY.equalToSuperview()
        }
    }
    
    private func setupDetailLabelLayout() {
        addSubview(detailLabel)
        
        detailLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        detailLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        detailLabel.snp.makeConstraints { make in
            make.centerY.equalTo(assetNameView)
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.leading.greaterThanOrEqualTo(assetNameView.snp.trailing).offset(layout.current.labelInset)
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

extension PendingAssetView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0
        let labelInset: CGFloat = 10.0
        let imageViewOffset: CGFloat = 8.0
        let imageViewSize = CGSize(width: 24.0, height: 24.0)
        let separatorHeight: CGFloat = 1.0
        let separatorInset: CGFloat = 14.0
    }
}
