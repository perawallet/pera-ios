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
    
    private lazy var algoIconImageView = UIImageView(image: img("icon-algo-small-purple"))
    
    private lazy var algosLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(.overpass, withWeight: .bold(size: 13.0)))
            .withTextColor(SharedColors.purple)
            .withLine(.single)
            .withAlignment(.left)
            .withText("asset-algos-title".localized)
    }()
    
    private(set) lazy var amountLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(.overpass, withWeight: .bold(size: 14.0)))
            .withTextColor(SharedColors.purple)
            .withLine(.single)
            .withAlignment(.right)
    }()
    
    private lazy var arrowImageView = UIImageView(image: img("icon-arrow-purple"))
    
    override func configureAppearance() {
        backgroundColor = .white
    }
    
    override func prepareLayout() {
        setupAlgoIconImageViewLayout()
        setupAlgosLabelLayout()
        setupArrowImageViewLayout()
        setupAmountLabelLayout()
    }
}

extension AlgoAssetView {
    private func setupAlgoIconImageViewLayout() {
        addSubview(algoIconImageView)
        
        algoIconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
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
            make.leading.greaterThanOrEqualTo(algosLabel.snp.trailing).offset(layout.current.imageInset)
        }
    }
}

extension AlgoAssetView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 15.0
        let imageInset: CGFloat = 10.0
        let nameInset: CGFloat = 7.0
        let arrowImageSize = CGSize(width: 20.0, height: 20.0)
    }
}
