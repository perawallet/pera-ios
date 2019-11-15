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
    
    private lazy var algoIconImageView = UIImageView(image: img("icon-logo-small"))
    
    private lazy var assetNameLabel: UILabel = {
        UILabel()
    }()
    
    private lazy var amountLabel: UILabel = {
        UILabel()
    }()
    
    private lazy var arrowImageView = UIImageView(image: img("icon-logo-small"))
    
    override func configureAppearance() {
        backgroundColor = .white
    }
    
    override func prepareLayout() {
        setupAlgoIconImageViewLayout()
        setupAssetNameLabelLayout()
        setupArrowImageViewLayout()
        setupAmountLabelLayout()
    }
}

extension AlgoAssetView {
    private func setupAlgoIconImageViewLayout() {
        addSubview(algoIconImageView)
        
        algoIconImageView.snp.makeConstraints { _ in
            
        }
    }
    
    private func setupAssetNameLabelLayout() {
        addSubview(assetNameLabel)
        
        assetNameLabel.snp.makeConstraints { _ in
            
        }
    }
    
    private func setupArrowImageViewLayout() {
        addSubview(arrowImageView)
        
        arrowImageView.snp.makeConstraints { _ in
            
        }
    }
    
    private func setupAmountLabelLayout() {
        addSubview(amountLabel)
        
        amountLabel.snp.makeConstraints { _ in
            
        }
    }
}

extension AlgoAssetView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        
    }
}
