//
//  LocalAuthenticationSettingsView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 18.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class LocalAuthenticationPreferenceView: BaseView {
    private let layout = Layout<LayoutConstants>()
    
    private lazy var faceIdIconImageView = UIImageView(image: img("icon-face-id"))
    
    private lazy var touchIdIconImageView = UIImageView(image: img("icon-touch-id"))
    
    private lazy var titleLabel: UILabel = {
        UILabel()
            .withText("local-authentication-preference-title".localized)
            .withTextColor(color("primaryText"))
            .withAlignment(.center)
            .withFont(UIFont.font(.publicSans, withWeight: .bold(size: 28.0)))
    }()
    
    private lazy var subtitleLabel: UILabel = {
        UILabel()
            .withText("local-authentication-preference-subtitle".localized)
            .withTextColor(color("primaryText"))
            .withAlignment(.center)
            .withLine(.contained)
            .withFont(UIFont.font(.publicSans, withWeight: .regular(size: 16.0)))
    }()
    
    private lazy var enableButton = MainButton(title: "local-authentication-enable".localized)
    
    private lazy var noButton: UIButton = {
        UIButton(type: .custom)
            .withFont(UIFont.font(.publicSans, withWeight: .medium(size: 16.0)))
            .withTitleColor(color("primaryText"))
            .withTitle("local-authentication-no".localized)
            .withAlignment(.center)
    }()
    
    weak var delegate: LocalAuthenticationPreferenceViewDelegate?
    
    override func setListeners() {
        enableButton.addTarget(self, action: #selector(notifyDelegateToYesButtonTapped), for: .touchUpInside)
        noButton.addTarget(self, action: #selector(notifyDelegateToNoButtonTapped), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        setupSubtitleLabelLayout()
        setupTitleLabelLayout()
        setupFaceIdIconImageViewLayout()
        setupTouchIdIconImageViewLayout()
        setupEnableButtonLayout()
        setupNoButtonLayout()
    }
}

extension LocalAuthenticationPreferenceView {
    @objc
    private func notifyDelegateToYesButtonTapped() {
        delegate?.localAuthenticationPreferenceViewDidTapYesButton(self)
    }

    @objc
    private func notifyDelegateToNoButtonTapped() {
        delegate?.localAuthenticationPreferenceViewDidTapNoButton(self)
    }
}

extension LocalAuthenticationPreferenceView {
    private func setupSubtitleLabelLayout() {
        addSubview(subtitleLabel)
        
        subtitleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(layout.current.subtitleHorizontalInset)
        }
    }
    
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.bottom.equalTo(subtitleLabel.snp.top).offset(-layout.current.verticalInset)
            make.centerX.equalToSuperview()
        }
    }
    
    private func setupFaceIdIconImageViewLayout() {
        addSubview(faceIdIconImageView)
        
        faceIdIconImageView.snp.makeConstraints { make in
            make.bottom.equalTo(titleLabel.snp.top).offset(layout.current.iconBottomOffset)
            make.centerX.equalToSuperview().offset(-layout.current.iconCenterOffset)
        }
    }
    
    private func setupTouchIdIconImageViewLayout() {
        addSubview(touchIdIconImageView)
        
        touchIdIconImageView.snp.makeConstraints { make in
            make.bottom.equalTo(faceIdIconImageView)
            make.centerX.equalToSuperview().offset(layout.current.iconCenterOffset)
        }
    }
    
    private func setupEnableButtonLayout() {
        addSubview(enableButton)
        
        enableButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(layout.current.buttonHorizontalInset)
            make.top.equalTo(subtitleLabel.snp.bottom).offset(layout.current.buttonTopOffset)
        }
    }
    
    private func setupNoButtonLayout() {
        addSubview(noButton)
        
        noButton.snp.makeConstraints { make in
            make.top.equalTo(enableButton.snp.bottom).offset(layout.current.verticalInset)
            make.bottom.lessThanOrEqualToSuperview().inset(layout.current.verticalInset)
            make.centerX.equalToSuperview()
        }
    }
}

extension LocalAuthenticationPreferenceView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let subtitleHorizontalInset: CGFloat = 24.0
        let iconCenterOffset: CGFloat = 50.0
        let buttonTopOffset: CGFloat = 50.0
        let verticalInset: CGFloat = 16.0
        let iconBottomOffset: CGFloat = -40.0
        let buttonHorizontalInset: CGFloat = 32.0
    }
}

protocol LocalAuthenticationPreferenceViewDelegate: class {
    func localAuthenticationPreferenceViewDidTapYesButton(_ localAuthenticationPreferenceView: LocalAuthenticationPreferenceView)
    func localAuthenticationPreferenceViewDidTapNoButton(_ localAuthenticationPreferenceView: LocalAuthenticationPreferenceView)
}
