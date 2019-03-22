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
}

class IntroductionView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let verticalInset: CGFloat = 94.0
        let createButtonTopInset: CGFloat = 42.0
        let bottomInset: CGFloat = 83.0
        let buttonMinimumTopInset: CGFloat = 120.0
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
    
    weak var delegate: IntroductionViewDelegate?
    
    // MARK: Configuration
    
    override func setListeners() {
        createAccountButton.addTarget(self, action: #selector(notifyDelegateToCreateAccountButtonTapped), for: .touchUpInside)
        recoverButton.addTarget(self, action: #selector(notifyDelegateToRecoverButtonTapped), for: .touchUpInside)
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupLogoImageViewLayout()
        setupDetailImageViewLayout()
        setupCreateAccountButtonLayout()
        setupRecoverButtonLayout()
    }
    
    private func setupLogoImageViewLayout() {
        addSubview(logoImageView)
        
        logoImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(layout.current.verticalInset)
        }
    }
    
    private func setupDetailImageViewLayout() {
        addSubview(detailImageView)
        
        detailImageView.snp.makeConstraints { make in
            make.top.equalTo(logoImageView.snp.bottom).offset(layout.current.verticalInset)
            make.centerX.equalToSuperview()
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
            make.top.greaterThanOrEqualTo(createAccountButton.snp.bottom).offset(layout.current.buttonMinimumTopInset)
            make.bottom.equalToSuperview().inset(layout.current.bottomInset)
            make.centerX.equalToSuperview()
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
}
