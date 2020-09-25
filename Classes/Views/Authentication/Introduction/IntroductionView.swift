//
//  IntroductionView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 15.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class IntroductionView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: IntroductionViewDelegate?
    
    private lazy var termsAndConditionsLabelGestureRecognizer = UITapGestureRecognizer(
        target: self,
        action: #selector(notifyDelegateToOpenTermsAndConditions)
    )
    
    private lazy var outerAnimatedImageView = UIImageView(image: img("img-introduction-bg-outer"))
    
    private lazy var middleAnimatedImageView = UIImageView(image: img("img-introduction-bg-middle"))
    
    private lazy var innerAnimatedImageView = UIImageView(image: img("img-introduction-bg-inner"))
    
    private lazy var introductionImageView = UIImageView(image: img("logo-introduction"))
    
    private lazy var titleLabel: UILabel = {
        UILabel()
            .withLine(.contained)
            .withFont(UIFont.font(withWeight: .medium(size: 24.0)))
            .withTextColor(SharedColors.primaryText)
            .withAlignment(.center)
    }()
    
    private lazy var addAccountButton = MainButton(title: "introduction-add-account-text".localized)
    
    private lazy var termsAndConditionsLabel: UILabel = {
        let label = UILabel()
            .withLine(.contained)
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
            .withTextColor(SharedColors.inputTitle)
            .withAlignment(.center)
        label.isUserInteractionEnabled = true
        
        let fullText = "introduction-title-terms-and-services".localized
        let fullAttributedText = NSMutableAttributedString(string: fullText)
        let termsRange = (fullText as NSString).range(of: "introduction-title-terms-and-services-conditions".localized)
        let privacyRange = (fullText as NSString).range(of: "introduction-title-terms-and-services-privacy".localized)
        fullAttributedText.addAttribute(NSAttributedString.Key.foregroundColor, value: SharedColors.primary, range: termsRange)
        fullAttributedText.addAttribute(NSAttributedString.Key.foregroundColor, value: SharedColors.primary, range: privacyRange)
        label.attributedText = fullAttributedText
        
        return label
    }()
    
    override func setListeners() {
        addAccountButton.addTarget(self, action: #selector(notifyDelegateToAddAccount), for: .touchUpInside)
        termsAndConditionsLabel.addGestureRecognizer(termsAndConditionsLabelGestureRecognizer)
    }
    
    override func configureAppearance() {
        backgroundColor = SharedColors.secondaryBackground
        introductionImageView.contentMode = .scaleAspectFit
    }
    
    override func prepareLayout() {
        setupOuterAnimatedImageViewLayout()
        setupMiddleAnimatedImageViewLayout()
        setupInnerAnimatedImageViewLayout()
        setupTitleLabelLayout()
        setupIntroductionImageViewLayout()
        setupTermsAndConditionsLabelLayout()
        setupAddAccountButtonLayout()
    }
}

extension IntroductionView {
    private func setupOuterAnimatedImageViewLayout() {
        addSubview(outerAnimatedImageView)
        
        outerAnimatedImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(-layout.current.outerImageOffset)
            make.trailing.equalToSuperview().offset(layout.current.outerImageOffset)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().inset(layout.current.titleCenterOffset)
            make.width.equalTo(outerAnimatedImageView.snp.height)
        }
    }
    
    private func setupMiddleAnimatedImageViewLayout() {
        addSubview(middleAnimatedImageView)
        
        middleAnimatedImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(-layout.current.middleImageOffset)
            make.trailing.equalToSuperview().offset(layout.current.middleImageOffset)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().inset(layout.current.titleCenterOffset)
            make.width.equalTo(middleAnimatedImageView.snp.height)
        }
    }
    
    private func setupInnerAnimatedImageViewLayout() {
        addSubview(innerAnimatedImageView)
        
        innerAnimatedImageView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.innerImageOffset)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().inset(layout.current.titleCenterOffset)
            make.width.equalTo(innerAnimatedImageView.snp.height)
        }
    }
    
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().inset(layout.current.titleCenterOffset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupIntroductionImageViewLayout() {
        addSubview(introductionImageView)
        
        introductionImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(titleLabel.snp.top).offset(-layout.current.verticalInset)
        }
    }
    
    private func setupTermsAndConditionsLabelLayout() {
        addSubview(termsAndConditionsLabel)
        
        termsAndConditionsLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.bottom.equalToSuperview().inset(safeAreaBottom + layout.current.verticalInset)
            make.centerX.equalToSuperview()
        }
    }
    
    private func setupAddAccountButtonLayout() {
        addSubview(addAccountButton)
        
        addAccountButton.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(titleLabel.snp.bottom).offset(layout.current.verticalInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.buttonHorizontalInset)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(termsAndConditionsLabel.snp.top).offset(-layout.current.verticalInset)
        }
    }
}

extension IntroductionView {
    func animateImages() {
        outerAnimatedImageView.rotate360Degrees(duration: 4.15, repeatCount: .greatestFiniteMagnitude, isClockwise: false)
        middleAnimatedImageView.rotate360Degrees(duration: 3.5, repeatCount: .greatestFiniteMagnitude, isClockwise: false)
        innerAnimatedImageView.rotate360Degrees(duration: 3.0, repeatCount: .greatestFiniteMagnitude, isClockwise: true)
    }
    
    func setTitle(_ title: String) {
        titleLabel.text = title
    }
}

extension IntroductionView {
    @objc
    private func notifyDelegateToAddAccount() {
        delegate?.introductionViewDidAddAccount(self)
    }
    
    @objc
    private func notifyDelegateToOpenTermsAndConditions() {
        delegate?.introductionViewDidOpenTermsAndConditions(self)
    }
}

extension IntroductionView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let outerImageOffset: CGFloat = 116.0
        let middleImageOffset: CGFloat = 36.0
        let innerImageOffset: CGFloat = 44.0
        let horizontalInset: CGFloat = 32.0
        let verticalInset: CGFloat = 20.0
        let buttonHorizontalInset: CGFloat = 20.0
        let titleCenterOffset: CGFloat = 22.0
    }
}

protocol IntroductionViewDelegate: class {
    func introductionViewDidAddAccount(_ introductionView: IntroductionView)
    func introductionViewDidOpenTermsAndConditions(_ introductionView: IntroductionView)
}
