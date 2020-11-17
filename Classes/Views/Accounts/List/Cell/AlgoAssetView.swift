//
//  AlgoAssetView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 12.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AlgoAssetView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private(set) lazy var verifiedImageView = UIImageView(image: img("icon-verified"))
    
    private lazy var algoIconImageView = UIImageView(image: img("icon-algo-gray"))
    
    private lazy var algosLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
            .withTextColor(Colors.Text.primary)
            .withLine(.single)
            .withAlignment(.left)
            .withText("asset-algos-title".localized)
    }()
    
    private(set) lazy var amountLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
            .withTextColor(Colors.Text.primary)
            .withLine(.single)
            .withAlignment(.right)
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.Component.separator
        return view
    }()
    
    override func configureAppearance() {
        backgroundColor = Colors.Background.secondary
    }
    
    override func prepareLayout() {
        setupVerifiedImageViewLayout()
        setupAlgoIconImageViewLayout()
        setupAlgosLabelLayout()
        setupAmountLabelLayout()
        setupSeparatorViewLayout()
    }
}

extension AlgoAssetView {
    private func setupVerifiedImageViewLayout() {
        addSubview(verifiedImageView)
        
        verifiedImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.centerY.equalToSuperview()
            make.size.equalTo(layout.current.imageSize)
        }
    }
    
    private func setupAlgoIconImageViewLayout() {
        addSubview(algoIconImageView)
        
        algoIconImageView.snp.makeConstraints { make in
            make.leading.equalTo(verifiedImageView.snp.trailing).offset(layout.current.nameInset)
            make.centerY.equalToSuperview()
        }
    }
    
    private func setupAlgosLabelLayout() {
        addSubview(algosLabel)
        
        algosLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        algosLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        algosLabel.snp.makeConstraints { make in
            make.leading.equalTo(algoIconImageView.snp.trailing).offset(layout.current.nameInset)
            make.centerY.equalToSuperview()
            make.top.bottom.equalToSuperview().inset(layout.current.verticalInset)
        }
    }
    
    private func setupAmountLabelLayout() {
        addSubview(amountLabel)
        
        amountLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        amountLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        amountLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.leading.greaterThanOrEqualTo(algosLabel.snp.trailing).offset(layout.current.imageInset)
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

extension AlgoAssetView {
    func setEnabled(_ isEnabled: Bool) {
        backgroundColor = isEnabled ? SharedColors.secondaryBackground : Colors.Background.disabled
        separatorView.backgroundColor = isEnabled ? SharedColors.primaryBackground : SharedColors.gray200
    }
}

extension AlgoAssetView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0
        let verticalInset: CGFloat = 16.0
        let imageInset: CGFloat = 10.0
        let nameInset: CGFloat = 4.0
        let imageSize = CGSize(width: 20.0, height: 20.0)
        let imageViewOffset: CGFloat = 6.0
        let separatorHeight: CGFloat = 1.0
        let separatorInset: CGFloat = 14.0
    }
}
