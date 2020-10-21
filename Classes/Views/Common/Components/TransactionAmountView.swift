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
    
    private lazy var amountStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.axis = .horizontal
        stackView.spacing = 0.0
        return stackView
    }()
    
    private(set) lazy var signLabel: UILabel = {
        UILabel()
            .withAlignment(.left)
            .withLine(.single)
            .withTextColor(SharedColors.primaryText)
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
    }()
    
    private(set) lazy var algoIconImageView = UIImageView(image: img("icon-algo-gray", isTemplate: true))
    
    private(set) lazy var amountLabel: UILabel = {
        UILabel()
            .withAlignment(.right)
            .withLine(.single)
            .withTextColor(SharedColors.primaryText)
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
    }()
    
    override func configureAppearance() {
        backgroundColor = .clear
    }
    
    override func prepareLayout() {
        setupAmountStackViewLayout()
    }
}

extension TransactionAmountView {
    private func setupAmountStackViewLayout() {
        addSubview(amountStackView)
        
        amountLabel.setContentHuggingPriority(.required, for: .horizontal)
        amountLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        amountStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        amountStackView.addArrangedSubview(signLabel)
        amountStackView.addArrangedSubview(algoIconImageView)
        amountStackView.addArrangedSubview(amountLabel)
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
            setAlgoIconHidden(!isAlgos)
        case let .positive(amount, isAlgos, assetFraction):
            signLabel.isHidden = false
            signLabel.text = "+"
            signLabel.textColor = SharedColors.tertiaryText
            
            setAmount(amount, with: assetFraction)
            amountLabel.textColor = SharedColors.tertiaryText
            algoIconImageView.tintColor = SharedColors.tertiaryText
            setAlgoIconHidden(!isAlgos)
        case let .negative(amount, isAlgos, assetFraction):
            signLabel.isHidden = false
            signLabel.text = "-"
            signLabel.textColor = SharedColors.red
            
            setAmount(amount, with: assetFraction)
            amountLabel.textColor = SharedColors.red
            algoIconImageView.tintColor = SharedColors.red
            setAlgoIconHidden(!isAlgos)
        }
    }
    
    private func setAmount(_ amount: Double, with assetFraction: Int?) {
        if let fraction = assetFraction {
            amountLabel.text = amount.toFractionStringForLabel(fraction: fraction)
        } else {
            amountLabel.text = amount.toAlgosStringForLabel
        }
    }
    
    private func setAlgoIconHidden(_ isHidden: Bool) {
        algoIconImageView.isHidden = isHidden
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
