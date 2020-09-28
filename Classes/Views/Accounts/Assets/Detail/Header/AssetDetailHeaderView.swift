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
    
    private lazy var assetIdCopyValueGestureRecognizer: UILongPressGestureRecognizer = {
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(notifyDelegateToCopyAssetId))
        recognizer.minimumPressDuration = 1.5
        return recognizer
    }()
    
    private lazy var rewardsTapGestureRecognizer = UITapGestureRecognizer(
        target: self,
        action: #selector(notifyDelegateToOpenRewardDetails)
    )
    
    private(set) lazy var verifiedImageView = UIImageView(image: img("icon-verified"))
    
    private(set) lazy var assetNameLabel: UILabel = {
        UILabel()
            .withAlignment(.left)
            .withTextColor(SharedColors.primaryText)
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
    }()
    
    private(set) lazy var assetAmountLabel: UILabel = {
        let label = UILabel()
            .withAlignment(.left)
            .withTextColor(SharedColors.primaryText)
            .withFont(UIFont.font(withWeight: .semiBold(size: 28.0)))
        label.minimumScaleFactor = 0.7
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private(set) lazy var algosImageView = UIImageView(image: img("icon-algorand-asset-detail"))
    
    private(set) lazy var currencyAmountLabel: UILabel = {
        let label = UILabel()
            .withAlignment(.left)
            .withTextColor(SharedColors.gray700)
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
        label.minimumScaleFactor = 0.8
        label.adjustsFontSizeToFitWidth = true
        return label
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
    
    private(set) lazy var rewardTotalAmountView: RewardTotalAmountView = {
        let view = RewardTotalAmountView()
        view.isUserInteractionEnabled = true
        return view
    }()
    
    weak var delegate: AssetDetailHeaderViewDelegate?
    
    override func configureAppearance() {
        backgroundColor = SharedColors.secondaryBackground
        algosImageView.contentMode = .scaleAspectFit
        layer.cornerRadius = 12.0
        applyMediumShadow()
    }
    
    override func setListeners() {
        assetIdLabel.addGestureRecognizer(assetIdCopyValueGestureRecognizer)
        rewardTotalAmountView.addGestureRecognizer(rewardsTapGestureRecognizer)
    }
    
    override func prepareLayout() {
        setupVerifiedImageViewLayout()
        setupAssetNameLabelLayout()
        setupAssetIdLabelLayout()
        setupAssetAmountLabelLayout()
        setupAlgosImageViewLayout()
        setupCurrencyAmountLabelLayout()
        setupRewardTotalAmountView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateShadowLayoutWhenViewDidLayoutSubviews()
    }
}

extension AssetDetailHeaderView {
    private func setupVerifiedImageViewLayout() {
        addSubview(verifiedImageView)
        
        verifiedImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.defaultInset)
            make.top.equalToSuperview().inset(layout.current.defaultInset)
            make.size.equalTo(layout.current.imageSize)
        }
    }
    
    private func setupAssetNameLabelLayout() {
        addSubview(assetNameLabel)
        
        assetNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.defaultInset)
            make.leading.equalToSuperview().inset(layout.current.defaultInset).priority(.medium)
            make.leading.equalTo(verifiedImageView.snp.trailing).offset(layout.current.verifiedImageOffset)
        }
    }
    
    private func setupAssetIdLabelLayout() {
        addSubview(assetIdLabel)
        
        assetIdLabel.setContentHuggingPriority(.required, for: .horizontal)
        assetIdLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        assetIdLabel.snp.makeConstraints { make in
            make.trailing.top.equalToSuperview().inset(layout.current.defaultInset)
            make.leading.greaterThanOrEqualTo(assetNameLabel.snp.trailing).offset(layout.current.minimumOffset)
        }
    }

    private func setupAssetAmountLabelLayout() {
        addSubview(assetAmountLabel)
        
        assetAmountLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.defaultInset)
            make.trailing.lessThanOrEqualToSuperview().inset(layout.current.amountTrailingInset)
            make.top.equalTo(assetNameLabel.snp.bottom).offset(layout.current.amountTopInset)
        }
    }
    
    private func setupAlgosImageViewLayout() {
        addSubview(algosImageView)
        
        algosImageView.snp.makeConstraints { make in
            make.size.equalTo(layout.current.algosImageSize)
            make.leading.equalTo(assetAmountLabel.snp.trailing).offset(layout.current.minimumOffset)
            make.top.equalTo(assetNameLabel.snp.bottom).offset(layout.current.algosImageTopInset)
        }
    }
    
    private func setupCurrencyAmountLabelLayout() {
        addSubview(currencyAmountLabel)
        
        currencyAmountLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.defaultInset)
            make.top.equalTo(assetAmountLabel.snp.bottom).offset(layout.current.verifiedImageOffset)
            make.trailing.lessThanOrEqualToSuperview().inset(layout.current.amountTrailingInset)
        }
    }
    
    private func setupRewardTotalAmountView() {
        addSubview(rewardTotalAmountView)
        
        rewardTotalAmountView.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(currencyAmountLabel.snp.bottom).offset(layout.current.defaultInset)
            make.leading.bottom.trailing.equalToSuperview()
        }
    }
}

extension AssetDetailHeaderView {
    @objc
    private func notifyDelegateToCopyAssetId() {
        delegate?.assetDetailHeaderViewDidCopyAssetId(self)
    }
    
    @objc
    private func notifyDelegateToOpenRewardDetails() {
        delegate?.assetDetailHeaderViewDidOpenRewardDetails(self)
    }
}

extension AssetDetailHeaderView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let defaultInset: CGFloat = 20.0
        let imageSize = CGSize(width: 20.0, height: 20.0)
        let verifiedImageOffset: CGFloat = 8.0
        let minimumOffset: CGFloat = 4.0
        let algosImageSize = CGSize(width: 24.0, height: 24.0)
        let algosImageTopInset: CGFloat = 30.0
        let amountTrailingInset: CGFloat = 60.0
        let amountTopInset: CGFloat = 24.0
    }
}

protocol AssetDetailHeaderViewDelegate: class {
    func assetDetailHeaderViewDidCopyAssetId(_ assetDetailHeaderView: AssetDetailHeaderView)
    func assetDetailHeaderViewDidOpenRewardDetails(_ assetDetailHeaderView: AssetDetailHeaderView)
}
