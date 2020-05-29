//
//  AccountsHeaderView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 29.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AssetDetailHeaderView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var dollarValueGestureRecognizer: UILongPressGestureRecognizer = {
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(notifyDelegateToDollarValueLabelTapped))
        recognizer.minimumPressDuration = 0.0
        return recognizer
    }()
    
    private lazy var assetIdCopyValueGestureRecognizer: UILongPressGestureRecognizer = {
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(notifyDelegateToAssetIdLabelTapped))
        recognizer.minimumPressDuration = 1.5
        return recognizer
    }()
    
    private lazy var rewardsTapGestureRecognizer = UITapGestureRecognizer(
        target: self,
        action: #selector(notifyDelegateToRewardsViewTapped)
    )
    
    private(set) lazy var assetNameLabel: UILabel = {
        UILabel()
            .withAlignment(.left)
            .withTextColor(SharedColors.detailText)
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
            .withText("accounts-algos-available-title".localized)
    }()
    
    private(set) lazy var verifiedImageView: UIImageView = {
        let imageView = UIImageView(image: img("icon-verified"))
        imageView.isHidden = true
        return imageView
    }()
    
    private(set) lazy var algosImageView = UIImageView(image: img("icon-algorand-asset-detail"))
    
    private(set) lazy var algosAmountLabel: UILabel = {
        let label = UILabel()
            .withAlignment(.left)
            .withTextColor(SharedColors.primaryText)
            .withFont(UIFont.font(withWeight: .semiBold(size: 28.0)))
            .withText("0.000000")
        label.minimumScaleFactor = 0.8
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private(set) lazy var dollarAmountLabel: UILabel = {
        let label = UILabel()
            .withAlignment(.left)
            .withTextColor(SharedColors.primaryText)
            .withFont(UIFont.font(withWeight: .semiBold(size: 28.0)))
        label.minimumScaleFactor = 0.8
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private(set) lazy var dollarValueImageView: UIImageView = {
        let imageView = UIImageView(image: img("icon-dollar"))
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private(set) lazy var assetIdLabel: UILabel = {
        let label = UILabel()
            .withAlignment(.right)
            .withTextColor(SharedColors.gray400)
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
        label.isHidden = true
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private lazy var sendButton: AlignedButton = {
        let positions: AlignedButton.StylePositionAdjustment = (
            image: CGPoint(x: 40.0 * horizontalScale, y: 0.0),
            title: CGPoint(x: 0.0, y: 0.0)
        )
        
        let button = AlignedButton(style: .imageLeftTitleCentered(positions))
        button.setImage(img("icon-arrow-up"), for: .normal)
        button.setTitle("title-send".localized, for: .normal)
        button.setTitleColor(SharedColors.primaryButtonTitle, for: .normal)
        button.titleLabel?.font = UIFont.font(withWeight: .semiBold(size: 14.0))
        button.backgroundColor = SharedColors.secondary
        button.layer.cornerRadius = 24.0
        button.titleLabel?.textAlignment = .center
        return button
    }()
    
    private lazy var requestButton: AlignedButton = {
        let positions: AlignedButton.StylePositionAdjustment = (
            image: CGPoint(x: 30.0 * horizontalScale, y: 0.0),
            title: CGPoint(x: 0.0, y: 0.0)
        )
        
        let button = AlignedButton(style: .imageLeftTitleCentered(positions))
        button.setImage(img("icon-arrow-down"), for: .normal)
        button.setTitle("title-request".localized, for: .normal)
        button.setTitleColor(SharedColors.primaryButtonTitle, for: .normal)
        button.titleLabel?.font = UIFont.font(withWeight: .semiBold(size: 14.0))
        button.backgroundColor = SharedColors.primary
        button.layer.cornerRadius = 24.0
        button.titleLabel?.textAlignment = .center
        return button
    }()
    
    private(set) lazy var rewardTotalAmountView: RewardTotalAmountView = {
        let view = RewardTotalAmountView()
        view.isUserInteractionEnabled = true
        return view
    }()
    
    weak var delegate: AssetDetailHeaderViewDelegate?
    
    override func configureAppearance() {
        backgroundColor = SharedColors.secondaryBackground
        algosImageView.contentMode = .scaleAspectFit
        dollarValueImageView.contentMode = .center
        dollarAmountLabel.isHidden = true
        layer.cornerRadius = 12.0
        applyMediumShadow()
    }
    
    override func setListeners() {
        sendButton.addTarget(self, action: #selector(notifyDelegateToSendButtonTapped), for: .touchUpInside)
        requestButton.addTarget(self, action: #selector(notifyDelegateToReceiveButtonTapped), for: .touchUpInside)
        dollarValueImageView.addGestureRecognizer(dollarValueGestureRecognizer)
        assetIdLabel.addGestureRecognizer(assetIdCopyValueGestureRecognizer)
        rewardTotalAmountView.addGestureRecognizer(rewardsTapGestureRecognizer)
    }
    
    override func prepareLayout() {
        setupAssetNameLabelLayout()
        setupVerifiedImageViewLayout()
        setupAssetIdLabelLayout()
        setupAlgosImageViewLayout()
        setupAmountLabelLayout()
        setupDollarAmountLabelLayout()
        setupDollarValueImageViewLayout()
        setupSendButtonLayout()
        setupRequestButtonLayout()
        setupRewardTotalAmountView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setShadowFrames()
    }
}

extension AssetDetailHeaderView {
    private func setupAssetNameLabelLayout() {
        addSubview(assetNameLabel)
        
        assetNameLabel.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().inset(layout.current.defaultInset)
        }
    }
    
    private func setupVerifiedImageViewLayout() {
        addSubview(verifiedImageView)
        
        verifiedImageView.snp.makeConstraints { make in
            make.leading.equalTo(assetNameLabel.snp.trailing).offset(layout.current.verifiedImageOffset)
            make.centerY.equalTo(assetNameLabel)
            make.size.equalTo(layout.current.imageSize)
        }
    }
    
    private func setupAssetIdLabelLayout() {
        addSubview(assetIdLabel)
        
        assetIdLabel.setContentHuggingPriority(.required, for: .horizontal)
        assetIdLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        assetIdLabel.snp.makeConstraints { make in
            make.trailing.top.equalToSuperview().inset(layout.current.defaultInset)
            make.leading.greaterThanOrEqualTo(verifiedImageView.snp.trailing).offset(layout.current.minimumOffset)
        }
    }
    
    private func setupAlgosImageViewLayout() {
        addSubview(algosImageView)
        
        algosImageView.snp.makeConstraints { make in
            make.size.equalTo(layout.current.algosImageSize)
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalTo(assetNameLabel.snp.bottom).offset(layout.current.algosImageTopInset)
        }
    }

    private func setupAmountLabelLayout() {
        addSubview(algosAmountLabel)
        
        algosAmountLabel.snp.makeConstraints { make in
            make.trailing.lessThanOrEqualToSuperview().inset(layout.current.amountTrailingInset)
            make.leading.equalToSuperview().inset(layout.current.horizontalInset).priority(.low)
            make.leading.equalTo(algosImageView.snp.trailing).offset(layout.current.minimumOffset)
            make.top.equalTo(assetNameLabel.snp.bottom).offset(layout.current.amountTopInset)
        }
    }
    
    private func setupDollarAmountLabelLayout() {
        addSubview(dollarAmountLabel)
        
        dollarAmountLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalTo(assetNameLabel.snp.bottom).offset(layout.current.amountTopInset)
            make.trailing.lessThanOrEqualToSuperview().inset(layout.current.amountTrailingInset)
        }
    }
    
    private func setupDollarValueImageViewLayout() {
        addSubview(dollarValueImageView)
        
        dollarValueImageView.snp.makeConstraints { make in
            make.size.equalTo(layout.current.dollarValueSize)
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalTo(assetIdLabel.snp.bottom).offset(layout.current.minimumOffset)
        }
    }
    
    private func setupSendButtonLayout() {
        addSubview(sendButton)
        
        sendButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.defaultInset)
            make.top.equalTo(algosAmountLabel.snp.bottom).offset(layout.current.defaultInset)
            make.width.equalTo(layout.current.buttonWidth)
            make.height.equalTo(layout.current.buttonHeight)
        }
    }
    
    private func setupRequestButtonLayout() {
        addSubview(requestButton)
        
        requestButton.snp.makeConstraints { make in
            make.leading.greaterThanOrEqualTo(sendButton.snp.trailing).offset(layout.current.minimumOffset)
            make.width.height.equalTo(sendButton)
            make.trailing.equalToSuperview().inset(layout.current.defaultInset)
            make.top.bottom.equalTo(sendButton)
        }
    }
    
    private func setupRewardTotalAmountView() {
        addSubview(rewardTotalAmountView)
        
        rewardTotalAmountView.snp.makeConstraints { make in
            make.top.equalTo(sendButton.snp.bottom).offset(layout.current.defaultInset)
            make.leading.trailing.equalToSuperview()
        }
    }
}

extension AssetDetailHeaderView {
    @objc
    private func notifyDelegateToSendButtonTapped() {
        delegate?.assetDetailHeaderViewDidTapSendButton(self)
    }
    
    @objc
    private func notifyDelegateToReceiveButtonTapped() {
        delegate?.assetDetailHeaderViewDidTapReceiveButton(self)
    }
    
    @objc
    private func notifyDelegateToDollarValueLabelTapped(dollarValueGestureRecognizer: UILongPressGestureRecognizer) {
        delegate?.assetDetailHeaderView(self, didTrigger: dollarValueGestureRecognizer)
    }
    
    @objc
    private func notifyDelegateToAssetIdLabelTapped(assetIdCopyValueGestureRecognizer: UILongPressGestureRecognizer) {
        delegate?.assetDetailHeaderView(self, didTriggerAssetIdCopyValue: assetIdCopyValueGestureRecognizer)
    }
    
    @objc
    private func notifyDelegateToRewardsViewTapped() {
        delegate?.assetDetailHeaderViewDidTapRewardView(self)
    }
}

extension AssetDetailHeaderView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let defaultInset: CGFloat = 20.0
        let imageSize = CGSize(width: 20.0, height: 20.0)
        let verifiedImageOffset: CGFloat = 6.0
        let minimumOffset: CGFloat = 4.0
        let algosImageSize = CGSize(width: 24.0, height: 24.0)
        let horizontalInset: CGFloat = 16.0
        let algosImageTopInset: CGFloat = 12.0
        let amountTrailingInset: CGFloat = 60.0
        let amountTopInset: CGFloat = 8.0
        let dollarValueSize = CGSize(width: 40.0, height: 40.0)
        let buttonHeight: CGFloat = 48.0
        let buttonWidth: CGFloat = 142.0
    }
}

protocol AssetDetailHeaderViewDelegate: class {
    func assetDetailHeaderViewDidTapSendButton(_ assetDetailHeaderView: AssetDetailHeaderView)
    func assetDetailHeaderViewDidTapReceiveButton(_ assetDetailHeaderView: AssetDetailHeaderView)
    func assetDetailHeaderView(
        _ assetDetailHeaderView: AssetDetailHeaderView,
        didTrigger dollarValueGestureRecognizer: UILongPressGestureRecognizer
    )
    func assetDetailHeaderView(
        _ assetDetailHeaderView: AssetDetailHeaderView,
        didTriggerAssetIdCopyValue gestureRecognizer: UILongPressGestureRecognizer
    )
    func assetDetailHeaderViewDidTapRewardView(_ assetDetailHeaderView: AssetDetailHeaderView)
}
