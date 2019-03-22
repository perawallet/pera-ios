//
//  WelcomeView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 15.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol WelcomeViewDelegate: class {
    
    func welcomeViewDidTapDoneButton(_ introductionView: WelcomeView)
}

class WelcomeView: BaseView {

    private struct LayoutConstants: AdaptiveLayoutConstants {
        let verticalInset: CGFloat = 94.0
        let titleLabelTopInset: CGFloat = 23.0
        let subtitleLabelTopInset: CGFloat = 14.0
        let subtitleLabelHorizontalInset: CGFloat = 50.0
        let buttonMinimumTopInset: CGFloat = 10.0
        let bottomInset: CGFloat = 59.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    // MARK: Components
    
    private lazy var logoImageView = UIImageView(image: img("logo-small"))
    
    private lazy var detailImageView = UIImageView(image: img("image-fingerprint"))
    
    private lazy var welcomteTitleLabel: UILabel = {
        UILabel()
            .withAlignment(.center)
            .withTextColor(rgb(0.0, 0.46, 1.0))
            .withFont(UIFont.systemFont(ofSize: 22.0, weight: .bold))
            .withText("welcome-title".localized)
    }()
    
    private lazy var subtitleLabel: UILabel = {
        UILabel()
            .withAlignment(.center)
            .withLine(.contained)
            .withTextColor(rgb(0.04, 0.05, 0.07))
            .withFont(UIFont.systemFont(ofSize: 16.0, weight: .regular))
            .withText("welcome-subtitle".localized)
    }()
    
    private lazy var doneButton: MainButton = {
        let button = MainButton(title: "welcome-done-title".localized)
        return button
    }()
    
    weak var delegate: WelcomeViewDelegate?
    
    // MARK: Configuration
    
    override func setListeners() {
        doneButton.addTarget(self, action: #selector(notifyDelegateToDoneButtonTapped), for: .touchUpInside)
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupLogoImageViewLayout()
        setupDetailImageViewLayout()
        setupWelcomeTitleLabelLayout()
        setupSubtitleLabelLayout()
        setupDoneButtonLayout()
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
            make.top.lessThanOrEqualTo(logoImageView.snp.bottom).offset(layout.current.verticalInset)
            make.centerX.equalToSuperview()
        }
    }
    
    private func setupWelcomeTitleLabelLayout() {
        addSubview(welcomteTitleLabel)
        
        welcomteTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(detailImageView.snp.bottom).offset(layout.current.titleLabelTopInset)
            make.centerX.equalToSuperview()
        }
    }
    
    private func setupSubtitleLabelLayout() {
        addSubview(subtitleLabel)
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(welcomteTitleLabel.snp.bottom).offset(layout.current.subtitleLabelTopInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.subtitleLabelHorizontalInset)
            make.centerX.equalToSuperview()
        }
    }
    
    private func setupDoneButtonLayout() {
        addSubview(doneButton)
        
        doneButton.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(subtitleLabel.snp.bottom).offset(layout.current.buttonMinimumTopInset)
            make.bottom.equalToSuperview().inset(layout.current.bottomInset)
            make.centerX.equalToSuperview()
        }
    }
    
    // MARK: Actions
    
    @objc
    func notifyDelegateToDoneButtonTapped() {
        delegate?.welcomeViewDidTapDoneButton(self)
    }
}
