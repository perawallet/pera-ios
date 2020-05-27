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
    
    private(set) lazy var leftExplanationLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(.avenir, withWeight: .medium(size: 13.0)))
            .withTextColor(SharedColors.greenishGray)
            .withText("send-algos-from".localized)
    }()
    
    private(set) lazy var rightExplanationLabel: UILabel = {
        let label = UILabel()
            .withFont(UIFont.font(.avenir, withWeight: .medium(size: 13.0)))
            .withTextColor(SharedColors.greenishGray)
            .withAlignment(.right)
        label.isHidden = true
        return label
    }()
    
    private(set) lazy var containerView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 1.0
        view.layer.borderColor = Colors.borderColor.cgColor
        view.layer.cornerRadius = 4.0
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var leftImageView = UIImageView()
    
    private(set) lazy var detailLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(.overpass, withWeight: .semiBold(size: 13.0)))
            .withTextColor(SharedColors.black)
            .withText("send-algos-select".localized)
            .withLine(.single)
    }()
    
    private(set) lazy var verifiedImageView: UIImageView = {
        let imageView = UIImageView(image: img("icon-verified"))
        imageView.isHidden = true
        return imageView
    }()
    
    private(set) lazy var amountView: TransactionAmountView = {
        let amountView = TransactionAmountView()
        amountView.signLabel.isHidden = true
        amountView.isHidden = true
        amountView.amountLabel.font = UIFont.font(.overpass, withWeight: .bold(size: 14.0))
        return amountView
    }()
    
    private(set) lazy var rightInputAccessoryButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(img("icon-arrow-right"), for: .normal)
        button.contentMode = .center
        return button
    }()
    
    private let hasLeftImageView: Bool
    
    init(hasLeftImageView: Bool = false) {
        self.hasLeftImageView = hasLeftImageView
        super.init(frame: .zero)
    }
    
    override func prepareLayout() {
        setupLeftExplanationLabelLayout()
        setupRightExplanationLabelLayout()
        setupContainerViewLayout()
        setupLeftImageViewLayout()
        setupRightInputAccessoryButtonLayout()
        setupAmountViewLayout()
        setupDetailLabelLayout()
        setupVerifiedImageViewLayout()
    }
}

extension SelectionView {
    private func setupLeftExplanationLabelLayout() {
        addSubview(leftExplanationLabel)
        
        leftExplanationLabel.setContentHuggingPriority(.required, for: .horizontal)
        leftExplanationLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        leftExplanationLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalToSuperview().inset(layout.current.verticalInset)
        }
    }
    
    private func setupRightExplanationLabelLayout() {
        addSubview(rightExplanationLabel)
        
        rightExplanationLabel.setContentHuggingPriority(.required, for: .horizontal)
        rightExplanationLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        rightExplanationLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.leading.greaterThanOrEqualTo(leftExplanationLabel.snp.trailing).offset(layout.current.horizontalInset)
            make.top.equalToSuperview().inset(layout.current.verticalInset)
        }
    }
    
    private func setupContainerViewLayout() {
        addSubview(containerView)
        
        containerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.defaultInset)
            make.bottom.equalToSuperview()
            make.top.equalTo(leftExplanationLabel.snp.bottom).offset(layout.current.containerViewTopInset)
        }
    }
    
    private func setupLeftImageViewLayout() {
        if !hasLeftImageView {
            return
        }
        
        containerView.addSubview(leftImageView)
        
        leftImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.defaultInset)
            make.centerY.equalToSuperview()
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
            if hasLeftImageView {
                make.leading.equalTo(leftImageView.snp.trailing).offset(layout.current.detailLabelLeadingInset)
            } else {
                make.leading.equalToSuperview().inset(layout.current.defaultInset)
            }
            make.top.bottom.equalToSuperview().inset(layout.current.detailVerticalInset)
        }
    }
    
    private func setupVerifiedImageViewLayout() {
        containerView.addSubview(verifiedImageView)
        
        verifiedImageView.snp.makeConstraints { make in
            make.leading.equalTo(detailLabel.snp.trailing).offset(layout.current.imageViewOffset)
            make.centerY.equalTo(detailLabel)
            make.trailing.lessThanOrEqualTo(amountView.snp.leading).offset(layout.current.nameTrailingInset)
            make.size.equalTo(layout.current.imageSize)
        }
    }
}

extension SelectionView {
    func set(amount: Double, assetFraction: Int? = nil) {
        amountView.isHidden = false
        rightInputAccessoryButton.isHidden = true
        amountView.mode = .normal(amount: amount, fraction: assetFraction)
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
    
    func setLedgerAccount() {
        leftImageView.image = img("icon-account-type-ledger")
    }
    
    func setStandardAccount() {
        leftImageView.image = img("icon-account-type-standard")
    }
}

extension SelectionView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let defaultInset: CGFloat = 15.0
        let amountViewTrailingInset: CGFloat = 20.0
        let horizontalInset: CGFloat = 30.0
        let verticalInset: CGFloat = 15.0
        let containerViewTopInset: CGFloat = 7.0
        let detailLabelLeadingInset: CGFloat = 12.0
        let amountViewHeight: CGFloat = 22.0
        let detailVerticalInset: CGFloat = 16.0
        let buttonTrailingInset: CGFloat = 12.0
        let nameTrailingInset: CGFloat = -5.0
        let buttonTopInset: CGFloat = 13.0
        let buttonWidth: CGFloat = 25.0
        let imageSize = CGSize(width: 13.0, height: 13.0)
        let imageViewOffset: CGFloat = 6.0
    }
}

extension SelectionView {
    private enum Colors {
        static let borderColor = rgb(0.91, 0.91, 0.92)
    }
}
