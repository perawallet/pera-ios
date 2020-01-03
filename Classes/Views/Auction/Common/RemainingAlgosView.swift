//
//  RemainingAlgosView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 15.05.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class RemainingAlgosView: BaseView {

    private struct LayoutConstants: AdaptiveLayoutConstants {
        let defaultInset: CGFloat = 25.0
        let verticalInset: CGFloat = 20.0
        let amountTopInset: CGFloat = 10.0
        let amountViewHeight: CGFloat = 18.0
        let percentageLabelOffset: CGFloat = 2.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    // MARK: Components
    
    private(set) lazy var explanationLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(.avenir, withWeight: .demiBold(size: 13.0)))
            .withTextColor(SharedColors.softGray)
            .withText("auction-remaining-algos".localized)
    }()
    
    private(set) lazy var algosAmountView: AlgosAmountView = {
        let view = AlgosAmountView()
        view.amountLabel.textAlignment = .left
        view.amountLabel.font = UIFont.font(.overpass, withWeight: .bold(size: 15.0))
        view.mode = .normal(amount: 0.0)
        view.algoIconImageView.image = img("icon-remaining-algo")
        return view
    }()
    
    private(set) lazy var percentageLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(.overpass, withWeight: .bold(size: 15.0)))
            .withTextColor(SharedColors.darkGray)
            .withLine(.single)
            .withAlignment(.left)
    }()
    
    // MARK: Setup
    
    override func configureAppearance() {
        backgroundColor = .white
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupExplanationLabelLayout()
        setupAlgosAmountViewLayout()
        setupPercentageLabelLayout()
    }
    
    private func setupExplanationLabelLayout() {
        addSubview(explanationLabel)
        
        explanationLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.defaultInset)
            make.trailing.lessThanOrEqualToSuperview().inset(layout.current.defaultInset)
            make.top.equalToSuperview().inset(layout.current.verticalInset)
        }
    }
    
    private func setupAlgosAmountViewLayout() {
        addSubview(algosAmountView)
        
        algosAmountView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.defaultInset)
            make.top.equalTo(explanationLabel.snp.bottom).offset(layout.current.amountTopInset)
            make.height.equalTo(layout.current.amountViewHeight)
        }
    }

    private func setupPercentageLabelLayout() {
        addSubview(percentageLabel)
        
        percentageLabel.snp.makeConstraints { make in
            make.centerY.equalTo(algosAmountView)
            make.leading.equalTo(algosAmountView.snp.trailing).offset(layout.current.percentageLabelOffset)
            make.trailing.equalToSuperview()
        }
    }
}
