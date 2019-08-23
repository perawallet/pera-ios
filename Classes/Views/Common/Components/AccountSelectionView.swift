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
        let defaultInset: CGFloat = 15.0
        let horizontalInset: CGFloat = 30.0
        let verticalInset: CGFloat = 10.0
        let containerViewTopInset: CGFloat = 7.0
        let amountViewHeight: CGFloat = 22.0
        let detailVerticalInset: CGFloat = 16.0
        let buttonTrailingInset: CGFloat = 12.0
        let nameTrailingInset: CGFloat = -5.0
        let buttonTopInset: CGFloat = 13.0
        let buttonWidth: CGFloat = 25.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    private enum Colors {
        static let borderColor = rgb(0.94, 0.94, 0.94)
    }
    
    // MARK: Components
    
    private(set) lazy var explanationLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(.avenir, withWeight: .medium(size: 13.0)))
            .withTextColor(SharedColors.softGray)
            .withText("send-algos-from".localized)
    }()
    
    private(set) lazy var containerView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 1.0
        view.layer.borderColor = Colors.borderColor.cgColor
        view.layer.cornerRadius = 4.0
        view.backgroundColor = .white
        return view
    }()
    
    private(set) lazy var detailLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(.overpass, withWeight: .semiBold(size: 13.0)))
            .withTextColor(SharedColors.black)
            .withText("send-algos-select".localized)
            .withLine(.single)
    }()
    
    private(set) lazy var algosAmountView: AlgosAmountView = {
        let view = AlgosAmountView()
        view.amountLabel.font = UIFont.font(.overpass, withWeight: .semiBold(size: 14.0))
        view.signLabel.isHidden = true
        view.amountLabel.textColor = SharedColors.turquois
        view.isHidden = true
        view.algoIconImageView.tintColor = SharedColors.turquois
        return view
    }()
    
    private(set) lazy var rightInputAccessoryButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(img("icon-arrow-right"), for: .normal)
        return button
    }()
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupExplanationLabelLayout()
        setupContainerViewLayout()
        setupRightInputAccessoryButtonLayout()
        setupAlgosAmountViewLayout()
        setupDetailLabelLayout()
    }
    
    private func setupExplanationLabelLayout() {
        addSubview(explanationLabel)
        
        explanationLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.trailing.lessThanOrEqualToSuperview().inset(layout.current.horizontalInset)
            make.top.equalToSuperview().inset(layout.current.verticalInset)
        }
    }
    
    private func setupContainerViewLayout() {
        addSubview(containerView)
        
        containerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.defaultInset)
            make.bottom.equalToSuperview()
            make.top.equalTo(explanationLabel.snp.bottom).offset(layout.current.containerViewTopInset)
        }
    }
    
    private func setupRightInputAccessoryButtonLayout() {
        containerView.addSubview(rightInputAccessoryButton)
        
        rightInputAccessoryButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(layout.current.buttonTrailingInset)
            make.top.equalTo(explanationLabel.snp.bottom).offset(layout.current.buttonTopInset)
            make.width.equalTo(layout.current.buttonWidth)
        }
    }
    
    private func setupAlgosAmountViewLayout() {
        containerView.addSubview(algosAmountView)
        
        algosAmountView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.height.equalTo(layout.current.amountViewHeight)
            make.trailing.equalToSuperview().inset(layout.current.defaultInset)
        }
    }
    
    private func setupDetailLabelLayout() {
        containerView.addSubview(detailLabel)
        
        detailLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.defaultInset)
            make.top.bottom.equalToSuperview().inset(layout.current.detailVerticalInset)
            make.trailing.lessThanOrEqualTo(algosAmountView.snp.leading).offset(layout.current.nameTrailingInset)
        }
    }
    
    func set(amount: Double) {
        algosAmountView.isHidden = false
        rightInputAccessoryButton.isHidden = true
        algosAmountView.amountLabel.text = amount.toDecimalStringForLabel
    }
}
