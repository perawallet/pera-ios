//
//  AccountSelectionView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 6.05.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class SelectionView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
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
    
    private(set) lazy var amountView: AlgosAmountView = {
        let amountView = AlgosAmountView()
        amountView.signLabel.isHidden = true
        amountView.isHidden = true
        return amountView
    }()
    
    private(set) lazy var rightInputAccessoryButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(img("icon-arrow-right"), for: .normal)
        button.contentMode = .center
        return button
    }()
    
    override func prepareLayout() {
        setupExplanationLabelLayout()
        setupContainerViewLayout()
        setupRightInputAccessoryButtonLayout()
        setupAmountViewLayout()
        setupDetailLabelLayout()
    }
}

extension SelectionView {
    private func setupExplanationLabelLayout() {
        addSubview(explanationLabel)
        
        explanationLabel.setContentHuggingPriority(.required, for: .horizontal)
        explanationLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
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
            make.centerY.equalToSuperview()
            make.width.equalTo(layout.current.buttonWidth)
        }
    }
    
    private func setupAmountViewLayout() {
        containerView.addSubview(amountView)
        
        amountView.setContentHuggingPriority(.required, for: .horizontal)
        amountView.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        amountView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.height.equalTo(layout.current.amountViewHeight)
            make.trailing.equalToSuperview().inset(layout.current.amountViewTrailingInset)
        }
    }
    
    private func setupDetailLabelLayout() {
        containerView.addSubview(detailLabel)
        
        detailLabel.setContentHuggingPriority(.required, for: .horizontal)
        detailLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        detailLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.defaultInset)
            make.top.bottom.equalToSuperview().inset(layout.current.detailVerticalInset)
            make.trailing.lessThanOrEqualTo(amountView.snp.leading).offset(layout.current.nameTrailingInset)
        }
    }
}

extension SelectionView {
    func set(amount: Double) {
        amountView.isHidden = false
        rightInputAccessoryButton.isHidden = true
        amountView.amountLabel.text = amount.toDecimalStringForLabel
    }
    
    func set(enabled: Bool) {
        isUserInteractionEnabled = enabled
        
        if enabled {
            containerView.backgroundColor = .white
        } else {
            rightInputAccessoryButton.isHidden = true
            containerView.backgroundColor = Colors.borderColor
        }
    }
}

extension SelectionView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let defaultInset: CGFloat = 15.0
        let amountViewTrailingInset: CGFloat = 20.0
        let horizontalInset: CGFloat = 30.0
        let verticalInset: CGFloat = 15.0
        let containerViewTopInset: CGFloat = 7.0
        let amountViewHeight: CGFloat = 22.0
        let detailVerticalInset: CGFloat = 16.0
        let buttonTrailingInset: CGFloat = 12.0
        let nameTrailingInset: CGFloat = -5.0
        let buttonTopInset: CGFloat = 13.0
        let buttonWidth: CGFloat = 25.0
    }
}

extension SelectionView {
    private enum Colors {
        static let borderColor = rgb(0.91, 0.91, 0.92)
    }
}
