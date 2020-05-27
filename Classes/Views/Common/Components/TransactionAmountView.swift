//
//  TransactionAmountView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 29.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class TransactionAmountView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    var mode: Mode = .normal(amount: 0.00) {
        didSet {
            updateAmountView()
        }
    }
    
    private(set) lazy var signLabel: UILabel = {
        UILabel()
            .withAlignment(.left)
            .withLine(.single)
            .withTextColor(SharedColors.primaryText)
            .withFont(UIFont.font(withWeight: .semiBold(size: 14.0)))
    }()
    
    private(set) lazy var algoIconImageView = UIImageView(image: img("icon-algo-gray", isTemplate: true))
    
    private(set) lazy var amountLabel: UILabel = {
        UILabel()
            .withAlignment(.right)
            .withLine(.single)
            .withTextColor(SharedColors.primaryText)
            .withFont(UIFont.font(withWeight: .semiBold(size: 14.0)))
    }()
    
    override func configureAppearance() {
        backgroundColor = .clear
    }
    
    override func prepareLayout() {
        setupAmountLabelLayout()
        setupAlgoIconImageViewLayout()
        setupSignLabelLayout()
    }
}

extension TransactionAmountView {
    private func setupAmountLabelLayout() {
        addSubview(amountLabel)
        
        amountLabel.setContentHuggingPriority(.required, for: .horizontal)
        amountLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        amountLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview()
        }
    }
    
    private func setupAlgoIconImageViewLayout() {
        addSubview(algoIconImageView)
        
        algoIconImageView.setContentHuggingPriority(.required, for: .horizontal)
        algoIconImageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        algoIconImageView.snp.makeConstraints { make in
            make.trailing.equalTo(amountLabel.snp.leading)
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
}

extension TransactionAmountView {
    private func updateAmountView() {
        switch mode {
        case let .normal(amount, isAlgos, assetFraction):
            signLabel.isHidden = true
            
            setAmount(amount, with: assetFraction)
            amountLabel.textColor = SharedColors.primaryText
            algoIconImageView.tintColor = SharedColors.primaryText
            removeAlgoIconForAssetIfNeeded(isAlgos)
        case let .positive(amount, isAlgos, assetFraction):
            signLabel.isHidden = false
            signLabel.text = "+"
            signLabel.textColor = SharedColors.tertiaryText
            
            setAmount(amount, with: assetFraction)
            amountLabel.textColor = SharedColors.tertiaryText
            algoIconImageView.tintColor = SharedColors.tertiaryText
            removeAlgoIconForAssetIfNeeded(isAlgos)
        case let .negative(amount, isAlgos, assetFraction):
            signLabel.isHidden = false
            signLabel.text = "-"
            signLabel.textColor = SharedColors.red
            
            setAmount(amount, with: assetFraction)
            amountLabel.textColor = SharedColors.red
            algoIconImageView.tintColor = SharedColors.red
            removeAlgoIconForAssetIfNeeded(isAlgos)
        }
    }
    
    private func setAmount(_ amount: Double, with assetFraction: Int?) {
        if let fraction = assetFraction {
            amountLabel.text = amount.toFractionStringForLabel(fraction: fraction)
        } else {
            amountLabel.text = amount.toDecimalStringForLabel
        }
    }
    
    private func removeAlgoIconForAssetIfNeeded(_ isAlgos: Bool) {
        if !isAlgos {
            algoIconImageView.removeFromSuperview()
        }
    }
}

extension TransactionAmountView {
    enum Mode {
        case normal(amount: Double, isAlgos: Bool = true, fraction: Int? = nil)
        case positive(amount: Double, isAlgos: Bool = true, fraction: Int? = nil)
        case negative(amount: Double, isAlgos: Bool = true, fraction: Int? = nil)
    }
}

extension TransactionAmountView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let labelInset: CGFloat = 4.0
    }
}
