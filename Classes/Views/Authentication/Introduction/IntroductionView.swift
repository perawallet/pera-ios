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
    
    private lazy var logoImageView = UIImageView(image: img("icon-logo-small"))
    
    private(set) lazy var welcomeLabel: UILabel = {
        UILabel()
            .withLine(.contained)
            .withFont(UIFont.font(.overpass, withWeight: .regular(size: 22.0 * verticalScale)))
            .withAttributedText("introduction-welcome-title".localized.attributed([.lineSpacing(1.5), .textColor(SharedColors.purple)]))
            .withAlignment(.center)
    }()
    
    private lazy var createAccountButton = MainButton(title: "introduction-create-title".localized)
    
    private lazy var pairLedgerAccountButton = MainButton(title: "introduction-title-pair-ledger".localized)
    
    private lazy var subtitleLabel: UILabel = {
        UILabel()
            .withAlignment(.center)
            .withLine(.contained)
            .withTextColor(SharedColors.softGray)
            .withFont(UIFont.font(.avenir, withWeight: .demiBold(size: 13.0 * verticalScale)))
            .withText("introduction-has-account".localized)
    }()
    
    private lazy var recoverButton: UIButton = {
        UIButton(type: .custom)
            .withBackgroundImage(img("bg-blue-button-big"))
            .withAttributedTitle("introduction-recover-title".localized.attributed([.letterSpacing(1.20), .textColor(.white)]))
            .withAlignment(.center)
            .withFont(UIFont.font(.avenir, withWeight: .demiBold(size: 12.0)))
    }()
    
    private(set) lazy var closeButton: UIButton = {
        UIButton(type: .custom)
            .withFont(UIFont.font(.avenir, withWeight: .demiBold(size: 12.0)))
            .withBackgroundImage(img("bg-black-button-big"))
            .withAttributedTitle("title-close".localized.attributed([.letterSpacing(1.20), .textColor(.white)]))
    }()
    
    weak var delegate: IntroductionViewDelegate?
    
    private let mode: AccountSetupMode
    
    init(mode: AccountSetupMode) {
        self.mode = mode
        super.init(frame: .zero)
    }
    
    override func setListeners() {
        createAccountButton.addTarget(self, action: #selector(notifyDelegateToCreateAccount), for: .touchUpInside)
        pairLedgerAccountButton.addTarget(self, action: #selector(notifyDelegateToPairLedgerAccount), for: .touchUpInside)
        recoverButton.addTarget(self, action: #selector(notifyDelegateToRecoverAccount), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(notifyDelegateToClose), for: .touchUpInside)
    }
    
    override func configureAppearance() {
        backgroundColor = .white
    }
    
    override func prepareLayout() {
        setupLogoImageViewLayout()
        setupWelcomeLabelLayout()
        setupCreateAccountButtonLayout()
        setupPairLedgerAccountButtonLayout()
        setupSubtitleLabelLayout()
        setupRecoverButtonLayout()
        
        if mode == .new {
            setupCloseButtonLayout()
        }
    }
}

extension IntroductionView {
    private func setupLogoImageViewLayout() {
        addSubview(logoImageView)
        
        logoImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(layout.current.logoInset)
        }
    }
    
    private func setupWelcomeLabelLayout() {
        addSubview(welcomeLabel)
        
        welcomeLabel.snp.makeConstraints { make in
            make.top.equalTo(logoImageView.snp.bottom).offset(layout.current.verticalInset)
            make.centerX.equalToSuperview()
            make.leading.trailing.lessThanOrEqualToSuperview().inset(layout.current.minimumHorizontalInset)
        }
    }
    
    private func setupCreateAccountButtonLayout() {
        addSubview(createAccountButton)
        
        createAccountButton.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(welcomeLabel.snp.bottom).offset(layout.current.bottomInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.buttonHorizontalInset)
            make.centerX.equalToSuperview()
        }
    }
    
    private func setupPairLedgerAccountButtonLayout() {
        addSubview(pairLedgerAccountButton)
        
        pairLedgerAccountButton.snp.makeConstraints { make in
            make.top.equalTo(createAccountButton.snp.bottom).offset(layout.current.bottomInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.buttonHorizontalInset)
            make.centerX.equalToSuperview()
        }
    }
    
    private func setupSubtitleLabelLayout() {
        addSubview(subtitleLabel)
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(pairLedgerAccountButton.snp.bottom).offset(layout.current.buttonMinimumTopInset)
            make.centerX.equalToSuperview()
        }
    }
    
    private func setupRecoverButtonLayout() {
        addSubview(recoverButton)
        
        recoverButton.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(layout.current.recoverButtonTopInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.buttonHorizontalInset)
            
            if mode == .initialize {
                make.bottom.equalToSuperview().inset(layout.current.bottomInset + safeAreaBottom)
            }
        }
    }
    
    private func setupCloseButtonLayout() {
        addSubview(closeButton)
        
        closeButton.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(recoverButton.snp.bottom).offset(layout.current.closeButtonMinimumTopInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.buttonHorizontalInset)
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
    
    @objc
    func notifyDelegateToClose() {
        delegate?.introductionViewDidTapCloseButton(self)
    }
}

extension IntroductionView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let logoInset: CGFloat = 100.0 * verticalScale
        let verticalInset: CGFloat = 25.0 * verticalScale
        let createButtonTopInset: CGFloat = 200.0 * verticalScale
        let bottomInset: CGFloat = 20.0 * verticalScale
        let minimumHorizontalInset: CGFloat = 20.0
        let buttonMinimumTopInset: CGFloat = 40.0 * verticalScale
        let recoverButtonTopInset: CGFloat = 13.0 * verticalScale
        let closeButtonMinimumTopInset: CGFloat = 35.0 * verticalScale
        let buttonHorizontalInset: CGFloat = MainButton.Constants.horizontalInset
    }
}

extension IntroductionView {
    private enum Colors {
        static let recoverButtonColor = rgba(0.04, 0.05, 0.07, 0.57)
        static let gradientColor = rgb(0.9, 0.9, 0.93)
    }
}

protocol IntroductionViewDelegate: class {
    func introductionViewDidTapCreateAccountButton(_ introductionView: IntroductionView)
    func introductionViewDidTapPairLedgerAccountButton(_ introductionView: IntroductionView)
    func introductionViewDidTapRecoverButton(_ introductionView: IntroductionView)
    func introductionViewDidTapCloseButton(_ introductionView: IntroductionView)
}
