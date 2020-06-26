//
//  PinLimitView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 25.06.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class PinLimitView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var lockImageView: UIImageView = {
        let imageView = UIImageView(image: img("icon-lock", isTemplate: true))
        imageView.tintColor = SharedColors.red
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        UILabel()
            .withAlignment(.center)
            .withFont(UIFont.font(withWeight: .medium(size: 24.0)))
            .withTextColor(SharedColors.primaryText)
            .withText("pin-limit-title".localized)
    }()
    
    private lazy var tryAgainLabel: UILabel = {
        UILabel()
            .withAlignment(.center)
            .withFont(UIFont.font(withWeight: .regular(size: 16.0)))
            .withTextColor(SharedColors.detailText)
            .withText("pin-limit-try-again".localized)
    }()
    
    private lazy var counterLabel: UILabel = {
        UILabel()
            .withAlignment(.center)
            .withFont(UIFont.font(withWeight: .medium(size: 24.0)))
            .withTextColor(SharedColors.primaryText)
    }()
    
    override func configureAppearance() {
        backgroundColor = SharedColors.secondaryBackground
    }
    
    override func prepareLayout() {
        setupLockImageViewLayout()
        setupTryAgainLabelLayout()
        setupTitleLabelLayout()
        setupCounterLabelLayout()
    }
}

extension PinLimitView {
    private func setupLockImageViewLayout() {
        addSubview(lockImageView)
        
        lockImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(layout.current.imageViewTopInset)
            make.size.equalTo(layout.current.unlockImageSize)
        }
    }
    
    private func setupTryAgainLabelLayout() {
        addSubview(tryAgainLabel)
        
        tryAgainLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.bottom.equalTo(tryAgainLabel.snp.top).offset(layout.current.titleLabelBottomInset)
            make.centerX.equalToSuperview()
        }
    }
    
    private func setupCounterLabelLayout() {
        addSubview(counterLabel)
        
        counterLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(tryAgainLabel.snp.bottom).offset(layout.current.counterLabelTopInset)
        }
    }
}

extension PinLimitView {
    func setCounterText(_ counter: String) {
        counterLabel.text = counter
    }
}

extension PinLimitView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let titleLabelBottomInset: CGFloat = -24.0
        let imageViewTopInset: CGFloat = 90.0
        let counterLabelTopInset: CGFloat = 4.0
        let unlockImageSize = CGSize(width: 48.0, height: 48.0)
    }
}
