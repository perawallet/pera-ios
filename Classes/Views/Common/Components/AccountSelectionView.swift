//
//  AccountSelectionView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 6.05.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AccountSelectionView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let defaultInset: CGFloat = 25.0
        let verticalInset: CGFloat = 20.0
        let contentViewTopInset: CGFloat = 7.0
        let amountViewHeight: CGFloat = 16.0
        let amountTrailingInset: CGFloat = -14.0
        let nameTrailingInset: CGFloat = -5.0
        let separatorTopInset: CGFloat = 20.0
        let buttonTopInset: CGFloat = 5.0
        let separatorHeight: CGFloat = 1.0
        let buttonWidth: CGFloat = 20.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    private enum Colors {
        static let separatorColor = rgba(0.67, 0.67, 0.72, 0.31)
    }
    
    // MARK: Components
    
    private(set) lazy var explanationLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(.opensans, withWeight: .semiBold(size: 12.0)))
            .withTextColor(SharedColors.softGray)
            .withText("send-algos-from".localized)
    }()
    
    private(set) lazy var detailLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(.montserrat, withWeight: .semiBold(size: 13.0)))
            .withTextColor(SharedColors.black)
            .withText("send-algos-select".localized)
            .withLine(.single)
    }()
    
    private(set) lazy var algosAmountView: AlgosAmountView = {
        let view = AlgosAmountView()
        view.algoIconImageView.image = img("icon-algo-small-gray")
        view.amountLabel.font = UIFont.font(.opensans, withWeight: .bold(size: 15.0))
        view.signLabel.isHidden = true
        view.amountLabel.textColor = SharedColors.darkGray
        view.isHidden = true
        return view
    }()
    
    private(set) lazy var rightInputAccessoryButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(img("icon-arrow"), for: .normal)
        return button
    }()
    
    private(set) lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.separatorColor
        return view
    }()
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupExplanationLabelLayout()
        setupRightInputAccessoryButtonLayout()
        setupAlgosAmountViewLayout()
        setupDetailLabelLayout()
        setupSeparatorViewLayout()
    }
    
    private func setupExplanationLabelLayout() {
        addSubview(explanationLabel)
        
        explanationLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.defaultInset)
            make.trailing.lessThanOrEqualToSuperview().inset(layout.current.defaultInset)
            make.top.equalToSuperview().inset(layout.current.verticalInset)
        }
    }
    
    private func setupRightInputAccessoryButtonLayout() {
        addSubview(rightInputAccessoryButton)
        
        rightInputAccessoryButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(layout.current.defaultInset)
            make.top.equalTo(explanationLabel.snp.bottom).offset(layout.current.buttonTopInset)
            make.width.equalTo(layout.current.buttonWidth)
        }
    }
    
    private func setupAlgosAmountViewLayout() {
        addSubview(algosAmountView)
        
        algosAmountView.snp.makeConstraints { make in
            make.top.equalTo(explanationLabel.snp.bottom).offset(layout.current.contentViewTopInset)
            make.height.equalTo(layout.current.amountViewHeight)
            make.trailing.equalTo(rightInputAccessoryButton.snp.leading).offset(layout.current.amountTrailingInset)
        }
    }
    
    private func setupDetailLabelLayout() {
        addSubview(detailLabel)
        
        detailLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.defaultInset)
            make.top.equalTo(explanationLabel.snp.bottom).offset(layout.current.contentViewTopInset)
            make.bottom.equalToSuperview().inset(layout.current.verticalInset)
            make.trailing.lessThanOrEqualTo(algosAmountView.snp.leading).offset(layout.current.nameTrailingInset)
        }
    }
    
    private func setupSeparatorViewLayout() {
        addSubview(separatorView)
        
        separatorView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.height.equalTo(layout.current.separatorHeight)
            make.leading.trailing.equalToSuperview()
        }
    }
    
    func set(amount: Double) {
        algosAmountView.isHidden = false
        algosAmountView.amountLabel.text = amount.toDecimalStringForLabel
    }
}
