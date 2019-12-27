//
//  AccountsHeaderView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 29.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

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

class AssetDetailHeaderView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var dollarValueGestureRecognizer: UILongPressGestureRecognizer = {
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(notifyDelegateToDollarValueLabelTapped))
        recognizer.minimumPressDuration = 0.0
        return recognizer
    }()
    
    private lazy var assetIdCopyValueGestureRecognizer: UILongPressGestureRecognizer = {
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(notifyDelegateToAssetIdLabelTapped))
        recognizer.minimumPressDuration = 1.0
        return recognizer
    }()
    
    private lazy var rewardsTapGestureRecognizer = UITapGestureRecognizer(
        target: self,
        action: #selector(notifyDelegateToRewardsViewTapped)
    )
    
    // MARK: Components
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 1.0
        view.layer.borderColor = Colors.borderColor.cgColor
        view.layer.cornerRadius = 4.0
        view.backgroundColor = .white
        return view
    }()
    
    private(set) lazy var assetNameLabel: UILabel = {
        UILabel()
            .withAlignment(.left)
            .withTextColor(SharedColors.black)
            .withFont(UIFont.font(.avenir, withWeight: .demiBold(size: 14.0)))
            .withText("accounts-algos-available-title".localized)
    }()
    
    private(set) lazy var algosAmountLabel: UILabel = {
        let label = UILabel()
            .withAlignment(.left)
            .withTextColor(SharedColors.black)
            .withFont(UIFont.font(.overpass, withWeight: .regular(size: 38.0)))
            .withText("0.000000")
        label.minimumScaleFactor = 0.8
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private(set) lazy var dollarImageView = UIImageView(image: img("icon-dollar-black"))
    
    private(set) lazy var dollarAmountLabel: UILabel = {
        UILabel()
            .withAlignment(.left)
            .withTextColor(SharedColors.black)
            .withFont(UIFont.font(.overpass, withWeight: .regular(size: 38.0)))
    }()
    
    private(set) lazy var dollarValueLabel: UILabel = {
        let label = UILabel()
            .withAlignment(.center)
            .withFont(UIFont.font(.avenir, withWeight: .demiBold(size: 14.0)))
            .withText("$")
            .withTextColor(.black)
        
        label.isUserInteractionEnabled = true
        label.clipsToBounds = true
        label.backgroundColor = .white
        label.layer.borderWidth = 1.0
        label.layer.borderColor = Colors.borderColor.cgColor
        label.layer.cornerRadius = 20.0
        return label
    }()
    
    private(set) lazy var assetIdLabel: UILabel = {
        let label = UILabel()
            .withAlignment(.right)
            .withTextColor(Colors.idLabelColor)
            .withFont(UIFont.font(.avenir, withWeight: .demiBold(size: 14.0)))
        label.isHidden = true
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private lazy var sendButton: AlignedButton = {
        let positions: AlignedButton.StylePositionAdjustment = (image: CGPoint(x: 10.0, y: 0.0), title: CGPoint(x: -12.0, y: 0.0))
        
        let button = AlignedButton(style: .imageLeftTitleCentered(positions))
        button.setImage(img("icon-arrow-up"), for: .normal)
        button.setTitle("title-send".localized, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.font(.avenir, withWeight: .demiBold(size: 12.0))
        button.backgroundColor = SharedColors.orange
        button.layer.cornerRadius = 23.0
        button.titleLabel?.textAlignment = .center
        return button
    }()
    
    private lazy var requestButton: AlignedButton = {
        let positions: AlignedButton.StylePositionAdjustment = (image: CGPoint(x: 10.0, y: 0.0), title: CGPoint(x: -12.0, y: 0.0))
        
        let button = AlignedButton(style: .imageLeftTitleCentered(positions))
        button.setImage(img("icon-arrow-down"), for: .normal)
        button.setTitle("title-request".localized, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.font(.avenir, withWeight: .demiBold(size: 12.0))
        button.backgroundColor = SharedColors.turquois
        button.layer.cornerRadius = 23.0
        button.titleLabel?.textAlignment = .center
        return button
    }()
    
    private(set) lazy var rewardTotalAmountView: RewardTotalAmountView = {
        let view = RewardTotalAmountView()
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private lazy var historyLabel: UILabel = {
        UILabel()
            .withAlignment(.center)
            .withTextColor(SharedColors.softGray)
            .withFont(UIFont.font(.avenir, withWeight: .medium(size: 12.0)))
            .withText("accounts-transaction-history-title".localized)
    }()
    
    weak var delegate: AssetDetailHeaderViewDelegate?
    
    // MARK: Setup
    
    override func configureAppearance() {
        super.configureAppearance()
        dollarAmountLabel.isHidden = true
        dollarImageView.isHidden = true
    }
    
    override func setListeners() {
        sendButton.addTarget(self, action: #selector(notifyDelegateToSendButtonTapped), for: .touchUpInside)
        requestButton.addTarget(self, action: #selector(notifyDelegateToReceiveButtonTapped), for: .touchUpInside)
        dollarValueLabel.addGestureRecognizer(dollarValueGestureRecognizer)
        assetIdLabel.addGestureRecognizer(assetIdCopyValueGestureRecognizer)
        rewardTotalAmountView.addGestureRecognizer(rewardsTapGestureRecognizer)
    }
    
    override func prepareLayout() {
        setupContainerViewLayout()
        setupDollarValueLabelLayout()
        setupAssetNameLabelLayout()
        setupAmountLabelLayout()
        setupDollarImageViewLayout()
        setupDollarAmountLabelLayout()
        setupAssetIdLabelLayout()
        setupSendButtonLayout()
        setupRequestButtonLayout()
        setupRewardTotalAmountView()
        setupHistoryLabelLayout()
    }
}

extension AssetDetailHeaderView {
    private func setupContainerViewLayout() {
        addSubview(containerView)
        
        containerView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(layout.current.containerViewInset)
        }
    }
    
    private func setupDollarValueLabelLayout() {
        addSubview(dollarValueLabel)
        
        dollarValueLabel.snp.makeConstraints { make in
            make.top.equalTo(containerView).inset(-layout.current.dollarValueInset)
            make.trailing.equalTo(containerView).offset(layout.current.dollarValueInset)
            make.size.equalTo(layout.current.dollarValueSize)
        }
    }
    
    private func setupAssetNameLabelLayout() {
        containerView.addSubview(assetNameLabel)
        
        assetNameLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.lessThanOrEqualToSuperview().inset(layout.current.availableTitleInset)
        }
    }

    private func setupAmountLabelLayout() {
        containerView.addSubview(algosAmountLabel)
        
        algosAmountLabel.snp.makeConstraints { make in
            make.trailing.lessThanOrEqualToSuperview().inset(layout.current.horizontalInset)
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalTo(assetNameLabel.snp.bottom).offset(layout.current.amountTopInset)
        }
    }
    
    private func setupDollarImageViewLayout() {
        containerView.addSubview(dollarImageView)
        
        dollarImageView.snp.makeConstraints { make in
            make.top.equalTo(assetNameLabel.snp.bottom).offset(layout.current.verticalInset)
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupDollarAmountLabelLayout() {
        containerView.addSubview(dollarAmountLabel)
        
        dollarAmountLabel.snp.makeConstraints { make in
            make.leading.equalTo(dollarImageView.snp.trailing).offset(layout.current.dollarValueInset)
            make.top.equalTo(assetNameLabel.snp.bottom).offset(layout.current.amountTopInset)
            make.trailing.lessThanOrEqualToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupAssetIdLabelLayout() {
        containerView.addSubview(assetIdLabel)
        
        assetIdLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(layout.current.availableTitleInset)
            make.top.equalTo(assetNameLabel)
            make.leading.greaterThanOrEqualTo(assetNameLabel.snp.trailing).offset(layout.current.containerViewInset)
        }
    }
    
    private func setupSendButtonLayout() {
        containerView.addSubview(sendButton)
        
        sendButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalTo(algosAmountLabel.snp.bottom).offset(layout.current.buttonTopInset)
            make.height.equalTo(layout.current.buttonHeight)
            make.bottom.equalToSuperview().inset(layout.current.buttonTopInset).priority(.medium)
        }
    }
    
    private func setupRequestButtonLayout() {
        containerView.addSubview(requestButton)
        
        requestButton.snp.makeConstraints { make in
            make.leading.equalTo(sendButton.snp.trailing).offset(layout.current.horizontalInset)
            make.width.height.equalTo(sendButton)
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.bottom.equalTo(sendButton)
        }
    }
    
    private func setupRewardTotalAmountView() {
        containerView.addSubview(rewardTotalAmountView)
        
        rewardTotalAmountView.snp.makeConstraints { make in
            make.top.equalTo(sendButton.snp.bottom).offset(layout.current.availableTitleInset)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func setupHistoryLabelLayout() {
        addSubview(historyLabel)

        historyLabel.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.bottom).offset(layout.current.verticalInset)
            make.bottom.equalToSuperview().inset(layout.current.historyLabelBottomInset)
            make.centerX.equalToSuperview()
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
        let containerViewInset: CGFloat = 10.0
        let availableTitleInset: CGFloat = 15.0
        let dollarValueSize = CGSize(width: 44.0, height: 44.0)
        let dollarValueInset: CGFloat = 5.0
        let horizontalInset: CGFloat = 15.0
        let amountTopInset: CGFloat = 9.0
        let verticalInset: CGFloat = 20.0
        let buttonHeight: CGFloat = 46.0
        let historyLabelBottomInset: CGFloat = 10.0
        let amountLabelTopInset: CGFloat = -10.0
        let amountLabelLeadingInset: CGFloat = 6.0
        let buttonTopInset: CGFloat = 18.0
    }
}

extension AssetDetailHeaderView {
    private enum Colors {
        static let borderColor = rgb(0.91, 0.91, 0.92)
        static let idLabelColor = rgb(0.53, 0.53, 0.53)
    }
}
