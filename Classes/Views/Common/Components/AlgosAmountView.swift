//
//  AlgosAmountView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 29.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AlgosAmountView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let labelInset: CGFloat = 3.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    var mode: Mode = .normal(amount: 0.00) {
        didSet {
            updateAmountView()
        }
    }
    
    // MARK: Components
    
    private(set) lazy var signLabel: UILabel = {
        UILabel()
            .withAlignment(.left)
            .withLine(.single)
            .withTextColor(SharedColors.black)
            .withFont(UIFont.font(.overpass, withWeight: .bold(size: 15.0)))
    }()
    
    private(set) lazy var algoIconImageView = UIImageView(image: img("icon-algo-black", isTemplate: true))
    
    private(set) lazy var amountLabel: UILabel = {
        UILabel()
            .withAlignment(.right)
            .withLine(.single)
            .withTextColor(SharedColors.black)
            .withFont(UIFont.font(.overpass, withWeight: .bold(size: 15.0)))
    }()

    // MARK: Setup
    
    override func configureAppearance() {
        backgroundColor = .clear
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupAmountLabelLayout()
        setupAlgoIconImageViewLayout()
        setupSignLabelLayout()
    }
    
    private func setupAmountLabelLayout() {
        addSubview(amountLabel)
        
        amountLabel.setContentHuggingPriority(.required, for: .horizontal)
        amountLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        amountLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview()
        }
    }
    
    private func setupAlgoIconImageViewLayout() {
        addSubview(algoIconImageView)
        
        algoIconImageView.setContentHuggingPriority(.required, for: .horizontal)
        algoIconImageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        algoIconImageView.snp.makeConstraints { make in
            make.trailing.equalTo(amountLabel.snp.leading).offset(-layout.current.labelInset)
            make.centerY.equalToSuperview()
        }
    }
    
    private func setupSignLabelLayout() {
        addSubview(signLabel)
        
        signLabel.setContentHuggingPriority(.required, for: .horizontal)
        signLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        signLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.trailing.equalTo(algoIconImageView.snp.leading)
            make.trailing.equalTo(amountLabel.snp.leading).offset(-layout.current.labelInset).priority(.low)
        }
    }
    
    // MARK: Update
    
    private func updateAmountView() {
        switch mode {
        case let .normal(amount, assetFraction):
            signLabel.isHidden = true
            
            if let fraction = assetFraction {
                amountLabel.text = amount.toFractionStringForLabel(fraction: fraction)
            } else {
                amountLabel.text = amount.toDecimalStringForLabel
            }
            
            amountLabel.textColor = SharedColors.black
            
            algoIconImageView.tintColor = SharedColors.black
        case let .positive(amount, assetFraction):
            signLabel.isHidden = false
            signLabel.text = "+"
            signLabel.textColor = SharedColors.turquois
            
            if let fraction = assetFraction {
                amountLabel.text = amount.toFractionStringForLabel(fraction: fraction)
            } else {
                amountLabel.text = amount.toDecimalStringForLabel
            }
            
            amountLabel.textColor = SharedColors.turquois
            
            algoIconImageView.tintColor = SharedColors.turquois
        case let .negative(amount, assetFraction):
            signLabel.isHidden = false
            signLabel.text = "-"
            signLabel.textColor = SharedColors.orange
            
            if let fraction = assetFraction {
                amountLabel.text = amount.toFractionStringForLabel(fraction: fraction)
            } else {
                amountLabel.text = amount.toDecimalStringForLabel
            }
            
            amountLabel.textColor = SharedColors.orange
            
            algoIconImageView.tintColor = SharedColors.orange
        }
    }
}

// MARK: Mode

extension AlgosAmountView {
    
    enum Mode {
        case normal(amount: Double, assetFraction: Int? = nil)
        case positive(amount: Double, assetFraction: Int? = nil)
        case negative(amount: Double, assetFraction: Int? = nil)
    }
}
