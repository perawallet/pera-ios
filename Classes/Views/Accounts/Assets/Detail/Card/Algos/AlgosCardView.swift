//
//  AlgosCardView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 15.10.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class AlgosCardView: BaseView {
    
    weak var delegate: AlgosCardViewDelegate?
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var rewardsTapGestureRecognizer = UITapGestureRecognizer(
        target: self,
        action: #selector(notifyDelegateToOpenRewardDetails)
    )
    
    private lazy var backgroundImageView = UIImageView(image: img("bg-card-green"))
    
    private lazy var verifiedImageView = UIImageView(image: img("icon-verified-white"))
    
    private lazy var assetNameLabel: UILabel = {
        UILabel()
            .withText("accounts-algos-available-title".localized)
            .withAlignment(.left)
            .withTextColor(Colors.Main.white)
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
    }()
    
    private lazy var assetAmountLabel: UILabel = {
        let label = UILabel()
            .withAlignment(.left)
            .withTextColor(Colors.Main.white)
            .withFont(UIFont.font(withWeight: .medium(size: 32.0)))
        label.minimumScaleFactor = 0.7
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private lazy var algosImageView = UIImageView(image: img("icon-algorand-asset-detail"))
    
    private lazy var currencyAmountLabel: UILabel = {
        let label = UILabel()
            .withAlignment(.left)
            .withTextColor(Colors.Main.white.withAlphaComponent(0.7))
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
        return label
    }()
    
    private lazy var rewardAmountButton: AlignedButton = {
        let button = AlignedButton(.imageAtLeft(spacing: 4.0))
        button.layer.cornerRadius = 18.0
        button.backgroundColor = Colors.Main.white.withAlphaComponent(0.1)
        button.setImage(img("icon-info-24", isTemplate: true), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.tintColor = Colors.Main.white
        button.setTitleColor(Colors.Main.white, for: .normal)
        button.titleLabel?.font = UIFont.font(withWeight: .regular(size: 12.0))
        button.titleLabel?.textAlignment = .left
        button.contentEdgeInsets = UIEdgeInsets(top: 8.0, left: 12.0, bottom: 8.0, right: 12.0)
        return button
    }()
    
    override func configureAppearance() {
        backgroundColor = .clear
        algosImageView.contentMode = .scaleAspectFit
    }
    
    override func setListeners() {
        rewardAmountButton.addGestureRecognizer(rewardsTapGestureRecognizer)
    }
    
    override func prepareLayout() {
        setupBackgroundImageViewLayout()
        setupVerifiedImageViewLayout()
        setupAssetNameLabelLayout()
        setupAssetAmountLabelLayout()
        setupAlgosImageViewLayout()
        setupCurrencyAmountLabelLayout()
        setupRewardAmountButtonLayout()
    }
}

extension AlgosCardView {
    @objc
    private func notifyDelegateToOpenRewardDetails() {
        delegate?.algosCardViewDidOpenRewardDetails(self)
    }
}

extension AlgosCardView {
    private func setupBackgroundImageViewLayout() {
        addSubview(backgroundImageView)
        
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
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
            make.leading.equalTo(verifiedImageView.snp.trailing).offset(layout.current.verifiedImageOffset)
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
    
    private func setupRewardAmountButtonLayout() {
        addSubview(rewardAmountButton)
        
        rewardAmountButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.defaultInset)
            make.height.equalTo(layout.current.rewardButtonHeight)
            make.bottom.equalToSuperview().inset(layout.current.defaultInset)
        }
    }
}

extension AlgosCardView {
    func bind(_ viewModel: AlgosCardViewModel) {
        assetAmountLabel.text = viewModel.amount
        currencyAmountLabel.text = viewModel.currency
        rewardAmountButton.setTitle(viewModel.reward, for: .normal)
    }
}

extension AlgosCardView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let defaultInset: CGFloat = 24.0
        let imageSize = CGSize(width: 20.0, height: 20.0)
        let verifiedImageOffset: CGFloat = 4.0
        let amountTopInset: CGFloat = 20.0
        let amountTrailingInset: CGFloat = 40.0
        let minimumOffset: CGFloat = 4.0
        let algosImageSize = CGSize(width: 24.0, height: 24.0)
        let algosImageTopInset: CGFloat = 28.0
        let rewardButtonHeight: CGFloat = 36.0
        let rewardButtonTopInset: CGFloat = 20.0
    }
}

protocol AlgosCardViewDelegate: class {
    func algosCardViewDidOpenRewardDetails(_ algosCardView: AlgosCardView)
}
