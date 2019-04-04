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
        let logoInset: CGFloat = 14.0 * verticalScale
        let verticalInset: CGFloat = 94.0 * verticalScale
        let titleLabelTopInset: CGFloat = 23.0 * verticalScale
        let subtitleLabelTopInset: CGFloat = 14.0 * verticalScale
        let subtitleLabelHorizontalInset: CGFloat = 50.0
        let buttonMinimumTopInset: CGFloat = 78.0 * verticalScale
        let bottomInset: CGFloat = 59.0 * verticalScale
        let imageSize: CGFloat = 250.0 * verticalScale
    }
    
    private let layout = Layout<LayoutConstants>()
    
    // MARK: Components
    
    private lazy var logoImageView = UIImageView(image: img("logo-small"))
    
    private lazy var detailImageView = UIImageView(image: img("image-registration"))
    
    private lazy var welcomteTitleLabel: UILabel = {
        UILabel()
            .withAlignment(.center)
            .withTextColor(SharedColors.black)
            .withFont(UIFont.font(.montserrat, withWeight: .bold(size: 22.0)))
            .withText("welcome-title".localized)
    }()
    
    private lazy var subtitleLabel: UILabel = {
        UILabel()
            .withAlignment(.center)
            .withLine(.contained)
            .withTextColor(SharedColors.black)
            .withFont(UIFont.font(.opensans, withWeight: .semiBold(size: 14.0)))
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
