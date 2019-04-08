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
        let logoInset: CGFloat = 14.0 * verticalScale
        let verticalInset: CGFloat = 94.0 * verticalScale
        let createButtonTopInset: CGFloat = 28.0 * verticalScale
        let bottomInset: CGFloat = 20.0 * verticalScale
        let buttonMinimumTopInset: CGFloat = 110.0 * verticalScale
        let imageSize: CGFloat = 250.0 * verticalScale
        let closeButtonMinimumTopInset: CGFloat = 35.0 * verticalScale
    }
    
    private let layout = Layout<LayoutConstants>()
    
    private enum Colors {
        static let recoverButtonColor = rgba(0.04, 0.05, 0.07, 0.57)
    }
    
    // MARK: Components
    
    private lazy var logoImageView = UIImageView(image: img("logo-small"))
    
    private lazy var detailImageView = UIImageView(image: img("image-registration"))
    
    private lazy var createAccountButton: MainButton = {
        let button = MainButton(title: "introduction-create-title".localized)
        return button
    }()
    
    private lazy var recoverButton: UIButton = {
        UIButton(type: .custom)
            .withTitleColor(Colors.recoverButtonColor)
            .withTitle("introduction-recover-title".localized)
            .withAlignment(.center)
            .withFont(UIFont.font(.montserrat, withWeight: .semiBold(size: 14.0)))
    }()
    
    private(set) lazy var closeButton: UIButton = {
        UIButton(type: .custom)
            .withFont(UIFont.font(.montserrat, withWeight: .bold(size: 14.0)))
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
        setupLogoImageViewLayout()
        setupDetailImageViewLayout()
        setupCreateAccountButtonLayout()
        setupRecoverButtonLayout()
        
        if mode == .new {
            setupCloseButtonLayout()
        }
    }
    
    private func setupLogoImageViewLayout() {
        addSubview(logoImageView)
        
        logoImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(layout.current.logoInset)
        }
    }
    
    private func setupDetailImageViewLayout() {
        addSubview(detailImageView)
        
        detailImageView.snp.makeConstraints { make in
            make.top.equalTo(logoImageView.snp.bottom).offset(layout.current.verticalInset)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(layout.current.imageSize)
        }
    }
    
    private func setupCreateAccountButtonLayout() {
        addSubview(createAccountButton)
        
        createAccountButton.snp.makeConstraints { make in
            make.top.equalTo(detailImageView.snp.bottom).offset(layout.current.createButtonTopInset)
            make.centerX.equalToSuperview()
        }
    }
    
    private func setupRecoverButtonLayout() {
        addSubview(recoverButton)
        
        recoverButton.snp.makeConstraints { make in
            make.top.equalTo(createAccountButton.snp.bottom).offset(layout.current.buttonMinimumTopInset)
            make.centerX.equalToSuperview()
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
