//
//  IntroductionView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 15.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol IntroductionViewDelegate: class {
    
    func introductionViewDidTapCreateAccountButton(_ introductionView: IntroductionView)
    func introductionViewDidTapRecoverButton(_ introductionView: IntroductionView)
    func introductionViewDidTapCloseButton(_ introductionView: IntroductionView)
}

class IntroductionView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let logoInset: CGFloat = 100.0 * verticalScale
        let verticalInset: CGFloat = 25.0 * verticalScale
        let createButtonTopInset: CGFloat = 200.0 * verticalScale
        let bottomInset: CGFloat = 20.0 * verticalScale
        let minimumHorizontalInset: CGFloat = 20.0
        let buttonMinimumTopInset: CGFloat = 40.0 * verticalScale
        let recoverButtonTopInset: CGFloat = 13.0 * verticalScale
        let closeButtonMinimumTopInset: CGFloat = 35.0 * verticalScale
    }
    
    private let layout = Layout<LayoutConstants>()
    
    private enum Colors {
        static let recoverButtonColor = rgba(0.04, 0.05, 0.07, 0.57)
        static let gradientColor = rgb(0.9, 0.9, 0.93)
    }
    
    // MARK: Components
    
    private lazy var backgroundImageView = UIImageView(image: img("bg-introduction"))
    
    private lazy var logoImageView = UIImageView(image: img("icon-logo"))
    
    private(set) lazy var welcomeLabel: UILabel = {
        UILabel()
            .withAlignment(.center)
            .withTextColor(SharedColors.blue)
            .withLine(.contained)
            .withFont(UIFont.font(.montserrat, withWeight: .medium(size: 22.0 * verticalScale)))
            .withText("introduction-welcome-title".localized)
    }()
    
    private lazy var createAccountButton: MainButton = {
        let button = MainButton(title: "introduction-create-title".localized)
        return button
    }()
    
    private lazy var subtitleLabel: UILabel = {
        UILabel()
            .withAlignment(.center)
            .withLine(.contained)
            .withTextColor(SharedColors.darkGray)
            .withFont(UIFont.font(.montserrat, withWeight: .semiBold(size: 12.0 * verticalScale)))
            .withText("introduction-has-account".localized)
    }()
    
    private lazy var recoverButton: UIButton = {
        UIButton(type: .custom)
            .withTitleColor(SharedColors.black)
            .withBackgroundImage(img("bg-dark-gray-button-big"))
            .withTitle("introduction-recover-title".localized)
            .withAlignment(.center)
            .withFont(UIFont.font(.montserrat, withWeight: .bold(size: 12.0)))
    }()
    
    private(set) lazy var closeButton: UIButton = {
        UIButton(type: .custom)
            .withFont(UIFont.font(.montserrat, withWeight: .bold(size: 12.0)))
            .withBackgroundImage(img("bg-dark-gray-button-big"))
            .withTitle("title-close".localized)
            .withTitleColor(SharedColors.black)
    }()
    
    weak var delegate: IntroductionViewDelegate?
    
    private let mode: AccountSetupMode
    
    init(mode: AccountSetupMode) {
        self.mode = mode
        super.init(frame: .zero)
    }
    
    // MARK: Configuration
    
    override func setListeners() {
        createAccountButton.addTarget(self, action: #selector(notifyDelegateToCreateAccountButtonTapped), for: .touchUpInside)
        recoverButton.addTarget(self, action: #selector(notifyDelegateToRecoverButtonTapped), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(notifyDelegateToCloseButtonTapped), for: .touchUpInside)
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupBackgroundImageViewLayout()
        setupLogoImageViewLayout()
        setupWelcomeLabelLayout()
        setupCreateAccountButtonLayout()
        setupSubtitleLabelLayout()
        setupRecoverButtonLayout()
        
        if mode == .new {
            setupCloseButtonLayout()
        }
    }
    
    private func setupBackgroundImageViewLayout() {
        addSubview(backgroundImageView)
        
        backgroundImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
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
            make.centerX.equalToSuperview()
        }
    }
    
    private func setupSubtitleLabelLayout() {
        addSubview(subtitleLabel)
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(createAccountButton.snp.bottom).offset(layout.current.buttonMinimumTopInset)
            make.centerX.equalToSuperview()
        }
    }
    
    private func setupRecoverButtonLayout() {
        addSubview(recoverButton)
        
        recoverButton.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(layout.current.recoverButtonTopInset)
            make.centerX.equalToSuperview()
            
            if mode == .initialize {
                make.bottom.equalToSuperview().inset(layout.current.bottomInset + safeAreaBottom)
            }
        }
    }
    
    private func setupCloseButtonLayout() {
        addSubview(closeButton)
        
        closeButton.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(recoverButton.snp.bottom).offset(layout.current.closeButtonMinimumTopInset)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(layout.current.bottomInset + safeAreaBottom)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setGradientBackground()
    }
    
    func setGradientBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [Colors.gradientColor.cgColor, UIColor.white.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.locations = [0, 1]
        gradientLayer.frame = bounds
        
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    // MARK: Actions
    
    @objc
    func notifyDelegateToCreateAccountButtonTapped() {
        delegate?.introductionViewDidTapCreateAccountButton(self)
    }

    @objc
    func notifyDelegateToRecoverButtonTapped() {
        delegate?.introductionViewDidTapRecoverButton(self)
    }
    
    @objc
    func notifyDelegateToCloseButtonTapped() {
        delegate?.introductionViewDidTapCloseButton(self)
    }
}
