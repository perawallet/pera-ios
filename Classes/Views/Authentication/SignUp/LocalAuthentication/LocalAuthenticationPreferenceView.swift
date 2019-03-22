//
//  LocalAuthenticationSettingsView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 18.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol LocalAuthenticationPreferenceViewDelegate: class {
    
    func localAuthenticationPreferenceViewDidTapYesButton(_ localAuthenticationPreferenceView: LocalAuthenticationPreferenceView)
    func localAuthenticationPreferenceViewDidTapNoButton(_ localAuthenticationPreferenceView: LocalAuthenticationPreferenceView)
}

class LocalAuthenticationPreferenceView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let titleLabelTopInset: CGFloat = 157.0
        let subtitleTopInset: CGFloat = 14.0
        let subtitleHorizontalInset: CGFloat = 60.0
        let containerViewHeight: CGFloat = 150.0
        let containerViewVerticalInset: CGFloat = 40.0
        let containerViewHorizontalInset: CGFloat = 25.0
        let iconCenterOffset: CGFloat = 87.0
        let yesButtonVerticalInset: CGFloat = -29.0
        let minimumButtonOffset: CGFloat = 10.0
        let bottomInset: CGFloat = 16.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    // MARK: Components
    
    private lazy var titleLabel: UILabel = {
        UILabel()
            .withText("local-authentication-preference-title".localized)
            .withTextColor(rgb(0.0, 0.46, 1.0))
            .withAlignment(.center)
            .withFont(UIFont.systemFont(ofSize: 22.0, weight: .bold))
    }()
    
    private lazy var subtitleLabel: UILabel = {
        UILabel()
            .withText("local-authentication-preference-subtitle".localized)
            .withTextColor(rgb(0.04, 0.05, 0.07))
            .withAlignment(.center)
            .withLine(.contained)
            .withFont(UIFont.systemFont(ofSize: 16.0, weight: .regular))
    }()
    
    private lazy var iconContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20.0
        return view
    }()
    
    private lazy var faceIdIconImageView = UIImageView(image: img("icon-face-id"))
    
    private lazy var touchIdIconImageView = UIImageView(image: img("icon-touch-id"))
    
    private lazy var yesButton: MainButton = {
        let button = MainButton(title: "title-yes".localized)
        return button
    }()
    
    private lazy var noButton: UIButton = {
        UIButton(type: .custom)
            .withTitle("title-no".localized)
            .withTitleColor(rgb(0.04, 0.05, 0.07))
            .withBackgroundImage(img("bg-dark-gray-button"))
            .withFont(UIFont.systemFont(ofSize: 14.0, weight: .bold))
    }()
    
    weak var delegate: LocalAuthenticationPreferenceViewDelegate?
    
    // MARK: Configuration
    
    override func configureAppearance() {
        backgroundColor = rgb(0.97, 0.97, 0.98)
    }
    
    override func setListeners() {
        yesButton.addTarget(self, action: #selector(notifyDelegateToYesButtonTapped), for: .touchUpInside)
        noButton.addTarget(self, action: #selector(notifyDelegateToNoButtonTapped), for: .touchUpInside)
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupTitleLabelLayout()
        setupSubtitleLabelLayout()
        setupIconContainerViewLayout()
        setupFaceIdIconImageViewLayout()
        setupTouchIdIconImageViewLayout()
        setupNoButtonLayout()
        setupYesButtonLayout()
    }
    
    func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.lessThanOrEqualToSuperview().inset(layout.current.titleLabelTopInset)
            make.centerX.equalToSuperview()
        }
    }
    
    func setupSubtitleLabelLayout() {
        addSubview(subtitleLabel)
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.subtitleTopInset)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(layout.current.subtitleHorizontalInset)
        }
    }
    
    func setupIconContainerViewLayout() {
        addSubview(iconContainerView)
        
        iconContainerView.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(layout.current.containerViewVerticalInset)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(layout.current.containerViewHorizontalInset)
            make.height.equalTo(layout.current.containerViewHeight)
        }
    }
    
    func setupFaceIdIconImageViewLayout() {
        iconContainerView.addSubview(faceIdIconImageView)
        
        faceIdIconImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview().inset(-layout.current.iconCenterOffset)
        }
    }
    
    func setupTouchIdIconImageViewLayout() {
        iconContainerView.addSubview(touchIdIconImageView)
        
        touchIdIconImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview().offset(layout.current.iconCenterOffset)
        }
    }
    
    func setupNoButtonLayout() {
        addSubview(noButton)
        
        noButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(layout.current.bottomInset)
            make.centerX.equalToSuperview()
        }
    }
    
    func setupYesButtonLayout() {
        addSubview(yesButton)
        
        yesButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(noButton.snp.top).offset(layout.current.yesButtonVerticalInset)
            make.top.greaterThanOrEqualTo(iconContainerView.snp.bottom).offset(layout.current.minimumButtonOffset)
        }
    }
    
    // MARK: Actions
    
    @objc
    func notifyDelegateToYesButtonTapped() {
        delegate?.localAuthenticationPreferenceViewDidTapYesButton(self)
    }

    @objc
    func notifyDelegateToNoButtonTapped() {
        delegate?.localAuthenticationPreferenceViewDidTapNoButton(self)
    }
}
