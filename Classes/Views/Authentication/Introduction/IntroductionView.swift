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
    
    private lazy var introductionImageView = UIImageView()
    
    private lazy var titleLabel: UILabel = {
        UILabel()
            .withLine(.contained)
            .withFont(UIFont.font(withWeight: .bold(size: 28.0 * verticalScale)))
            .withText("introduction-title-text".localized)
            .withTextColor(SharedColors.primaryText)
            .withAlignment(.left)
    }()
    
    private lazy var createAccountButton = MainButton(title: "introduction-create-title".localized)
    
    private lazy var pairLedgerAccountButton: UIButton = {
        UIButton(type: .custom)
            .withBackgroundImage(img("bg-orange-button"))
            .withTitle("introduction-title-pair-ledger".localized)
            .withTitleColor(SharedColors.primaryButtonTitle)
            .withAlignment(.center)
            .withFont(UIFont.font(withWeight: .semiBold(size: 16.0)))
    }()
    
    private lazy var separatorView = LineSeparatorView()
    
    private lazy var subtitleLabel: UILabel = {
        UILabel()
            .withAlignment(.center)
            .withLine(.single)
            .withTextColor(SharedColors.gray500)
            .withFont(UIFont.font(withWeight: .medium(size: 14.0 * verticalScale)))
            .withText("introduction-has-account".localized)
    }()
    
    private lazy var recoverButton: UIButton = {
        UIButton(type: .custom)
            .withBackgroundImage(img("bg-light-gray-button"))
            .withTitle("introduction-recover-title".localized)
            .withTitleColor(SharedColors.secondaryButtonTitle)
            .withAlignment(.center)
            .withFont(UIFont.font(withWeight: .semiBold(size: 16.0)))
    }()
    
    override func setListeners() {
        createAccountButton.addTarget(self, action: #selector(notifyDelegateToCreateAccount), for: .touchUpInside)
        pairLedgerAccountButton.addTarget(self, action: #selector(notifyDelegateToPairLedgerAccount), for: .touchUpInside)
        recoverButton.addTarget(self, action: #selector(notifyDelegateToRecoverAccount), for: .touchUpInside)
    }
    
    override func configureAppearance() {
        backgroundColor = SharedColors.secondaryBackground
    }
    
    override func prepareLayout() {
        setupIntroductionImageViewLayout()
        setupTitleLabelLayout()
        setupCreateAccountButtonLayout()
        setupPairLedgerAccountButtonLayout()
        setupSeparatorViewLayout()
        setupSubtitleLabelLayout()
        setupRecoverButtonLayout()
    }
}

extension IntroductionView {
    private func setupIntroductionImageViewLayout() {
        addSubview(introductionImageView)
        
        introductionImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.imageViewLeadingInset)
            make.trailing.equalToSuperview()
            make.top.equalToSuperview().inset(layout.current.imageViewTopInset)
            make.height.equalTo(layout.current.imageViewHeight)
        }
    }
    
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.lessThanOrEqualTo(introductionImageView.snp.bottom).offset(layout.current.titleLabelTopInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupCreateAccountButtonLayout() {
        addSubview(createAccountButton)
        
        createAccountButton.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.createButtonTopInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.centerX.equalToSuperview()
        }
    }
    
    private func setupPairLedgerAccountButtonLayout() {
        addSubview(pairLedgerAccountButton)
        
        pairLedgerAccountButton.snp.makeConstraints { make in
            make.top.equalTo(createAccountButton.snp.bottom).offset(layout.current.pairButtonTopInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.centerX.equalToSuperview()
        }
    }
    
    private func setupSeparatorViewLayout() {
        addSubview(separatorView)
        
        separatorView.snp.makeConstraints { make in
            make.top.equalTo(pairLedgerAccountButton.snp.bottom).offset(layout.current.separatorVerticalInset)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.height.equalTo(layout.current.separatorHeight)
        }
    }
    
    private func setupSubtitleLabelLayout() {
        addSubview(subtitleLabel)
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(separatorView.snp.bottom).offset(layout.current.separatorVerticalInset)
            make.centerX.equalToSuperview()
        }
    }
    
    private func setupRecoverButtonLayout() {
        addSubview(recoverButton)
        
        recoverButton.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(layout.current.recoverButtonTopInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.bottom.equalToSuperview().inset(layout.current.bottomInset + safeAreaBottom)
        }
    }
}

extension IntroductionView {
    @objc
    func notifyDelegateToCreateAccount() {
        delegate?.introductionViewDidTapCreateAccountButton(self)
    }
    
    @objc
    func notifyDelegateToPairLedgerAccount() {
        delegate?.introductionViewDidTapPairLedgerAccountButton(self)
    }

    @objc
    func notifyDelegateToRecoverAccount() {
        delegate?.introductionViewDidTapRecoverButton(self)
    }
}

extension IntroductionView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let imageViewHeight: CGFloat = 192.0 * verticalScale
        let imageViewLeadingInset: CGFloat = 28.0
        let imageViewTopInset: CGFloat = 50.0 * verticalScale
        let titleLabelTopInset: CGFloat = 80.0 * verticalScale
        let separatorHeight: CGFloat = 1.0
        let separatorVerticalInset: CGFloat = 32.0 * verticalScale
        let createButtonTopInset: CGFloat = 40.0 * verticalScale
        let pairButtonTopInset: CGFloat = 20.0 * verticalScale
        let bottomInset: CGFloat = 20.0 * verticalScale
        let recoverButtonTopInset: CGFloat = 16.0 * verticalScale
        let horizontalInset: CGFloat = 32.0
    }
}

protocol IntroductionViewDelegate: class {
    func introductionViewDidTapCreateAccountButton(_ introductionView: IntroductionView)
    func introductionViewDidTapPairLedgerAccountButton(_ introductionView: IntroductionView)
    func introductionViewDidTapRecoverButton(_ introductionView: IntroductionView)
}
