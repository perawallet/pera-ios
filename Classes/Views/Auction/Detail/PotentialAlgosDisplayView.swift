//
//  PotentialAlgosDisplayView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 18.05.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class PotentialAlgosDisplayView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let minTitleTopInset: CGFloat = 23.0
        let minTitleLeadingInset: CGFloat = 15.0
        let minAmountTrailingInset: CGFloat = 12.0
        let minAmountTopInset: CGFloat = 20.0
        let iconTrailingInset: CGFloat = -2.0
        let iconMinimumInset: CGFloat = 3.0
        let totalTrailingInset: CGFloat = 9.0
        let totalTitleLeadingInset: CGFloat = 37.0
        let totalTopInset: CGFloat = 17.0
        let buttonInset: CGFloat = 12.0
        let buttonSize = CGSize(width: 15.0, height: 15.0)
    }
    
    private let layout = Layout<LayoutConstants>()
    
    // MARK: Components
    
    private lazy var infoImageView = UIImageView(image: img("button-info"))
    
    private lazy var potentialAlgosTitleLabel: UILabel = {
        UILabel()
            .withAlignment(.left)
            .withLine(.single)
            .withTextColor(.white)
            .withFont(UIFont.font(.montserrat, withWeight: .semiBold(size: 12.0)))
            .withText("auction-detail-potential-min".localized)
    }()
    
    private lazy var algoIconImageView = UIImageView(image: img("icon-algo-white"))
    
    private(set) lazy var amountLabel: UILabel = {
        UILabel()
            .withAlignment(.right)
            .withLine(.single)
            .withTextColor(.white)
            .withFont(UIFont.font(.montserrat, withWeight: .semiBold(size: 18.0)))
            .withText("0.00")
    }()
    
    private var mode: Mode
    
    // MARK: Initialization
    
    init(mode: Mode) {
        self.mode = mode
        
        super.init(frame: .zero)
    }
    
    // MARK: Setup
    
    override func configureAppearance() {
        backgroundColor = SharedColors.blue
        layer.cornerRadius = 5.0
        
        if mode == .minimum {
            potentialAlgosTitleLabel.text = "auction-detail-potential-min".localized
            amountLabel.font = UIFont.font(.montserrat, withWeight: .semiBold(size: 18.0))
            algoIconImageView.image = img("icon-algo-white")
        } else {
            potentialAlgosTitleLabel.text = "auction-detail-potential-total".localized
            amountLabel.font = UIFont.font(.montserrat, withWeight: .semiBold(size: 15.0))
            algoIconImageView.image = img("icon-algo-small-white")
        }
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        if mode == .total {
            setupInfoImageViewLayout()
        }
        
        setupPotentialAlgosTitleLabelLayout()
        setupAmountLabelLayout()
        setupAlgoIconImageViewLayout()
    }
    
    private func setupInfoImageViewLayout() {
        addSubview(infoImageView)
        
        infoImageView.snp.makeConstraints { make in
            make.size.equalTo(layout.current.buttonSize)
            make.leading.equalToSuperview().inset(layout.current.buttonInset)
            make.top.equalToSuperview().inset(layout.current.totalTopInset)
        }
    }
    
    private func setupPotentialAlgosTitleLabelLayout() {
        addSubview(potentialAlgosTitleLabel)
        
        potentialAlgosTitleLabel.snp.makeConstraints { make in
            if mode == .total {
                make.leading.equalToSuperview().inset(layout.current.totalTitleLeadingInset)
                make.top.equalToSuperview().inset(layout.current.totalTopInset)
            } else {
                make.leading.equalToSuperview().inset(layout.current.minTitleLeadingInset)
                make.top.equalToSuperview().inset(layout.current.minTitleTopInset)
            }
        }
    }
    
    private func setupAmountLabelLayout() {
        addSubview(amountLabel)
        
        amountLabel.snp.makeConstraints { make in
            if mode == .total {
                make.trailing.equalToSuperview().inset(layout.current.totalTrailingInset)
                make.top.equalToSuperview().inset(layout.current.totalTopInset)
            } else {
                make.trailing.equalToSuperview().inset(layout.current.minAmountTrailingInset)
                make.top.equalToSuperview().inset(layout.current.minAmountTopInset)
            }
        }
    }
    
    private func setupAlgoIconImageViewLayout() {
        addSubview(algoIconImageView)
        
        algoIconImageView.snp.makeConstraints { make in
            make.centerY.equalTo(amountLabel)
            make.trailing.equalTo(amountLabel.snp.leading).offset(layout.current.iconTrailingInset)
            make.leading.greaterThanOrEqualTo(potentialAlgosTitleLabel.snp.trailing).offset(layout.current.iconMinimumInset)
        }
    }
}

// MARK: Mode

extension PotentialAlgosDisplayView {
    
    enum Mode {
        case minimum
        case total
    }
}
