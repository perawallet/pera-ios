//
//  ChoosePasswordView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 18.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol ChoosePasswordViewDelegate: class {
    
    func choosePasswordView(_ choosePasswordView: ChoosePasswordView, didSelect value: NumpadValue)
    func choosePasswordViewDidTapLogoutButton(_ choosePasswordView: ChoosePasswordView)
}

class ChoosePasswordView: BaseView {

    private struct LayoutConstants: AdaptiveLayoutConstants {
        let titleLabelTopInset: CGFloat = 69.0
        let subtitleTopInset: CGFloat = 14.0
        let subtitleHorizontalInset: CGFloat = 60.0
        let inputViewTopInset: CGFloat = 45.0
        let numpadBottomInset: CGFloat = 32.0
        let numpadTopInset: CGFloat = 45.0
        let passwordInputViewInset: CGFloat = -10.0
        let logoutButtonTopInset: CGFloat = 109.0
        let logoutButtonHeight: CGFloat = 49.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    // MARK: Components
    
    private(set) lazy var titleLabel: UILabel = {
        UILabel()
            .withTextColor(SharedColors.black)
            .withAlignment(.center)
            .withFont(UIFont.font(.montserrat, withWeight: .bold(size: 22.0)))
    }()
    
    private(set) lazy var subtitleLabel: UILabel = {
        UILabel()
            .withTextColor(SharedColors.black)
            .withLine(.contained)
            .withAlignment(.center)
            .withFont(UIFont.font(.opensans, withWeight: .semiBold(size: 14.0)))
    }()
    
    private(set) lazy var passwordInputView: PasswordInputView = {
        let view = PasswordInputView()
        return view
    }()
    
    private(set) lazy var logoutButton: UIButton = {
        let button = UIButton(type: .custom)
        button.isHidden = true
        return button.withTitleColor(SharedColors.darkGray)
            .withTitle("logout-title".localized)
            .withAlignment(.center)
            .withBackgroundImage(img("bg-dark-gray-button-small"))
            .withFont(UIFont.font(.montserrat, withWeight: .bold(size: 12.0)))
    }()
    
    private(set) lazy var numpadView: NumpadView = {
        let view = NumpadView()
        return view
    }()
    
    weak var delegate: ChoosePasswordViewDelegate?
    
    // MARK: Setup
    
    override func linkInteractors() {
        numpadView.delegate = self
    }
    
    override func setListeners() {
        logoutButton.addTarget(self, action: #selector(notifyDelegateToLogoutButtonTapped), for: .touchUpInside)
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupTitleLabelLayout()
        setupSubtitleLabelLayout()
        setupPasswordViewLayout()
        setupLogoutButtonLayout()
        setupNumpadViewLayout()
    }
    
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(layout.current.titleLabelTopInset)
        }
    }
    
    private func setupSubtitleLabelLayout() {
        addSubview(subtitleLabel)
        
        subtitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(layout.current.subtitleHorizontalInset)
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.subtitleTopInset)
        }
    }
    
    private func setupPasswordViewLayout() {
        addSubview(passwordInputView)
        
        passwordInputView.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(layout.current.inputViewTopInset)
            make.centerX.equalToSuperview()
        }
    }
    
    private func setupLogoutButtonLayout() {
        addSubview(logoutButton)
        
        logoutButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.greaterThanOrEqualTo(passwordInputView.snp.bottom).offset(layout.current.logoutButtonTopInset)
            make.height.equalTo(layout.current.logoutButtonHeight)
        }
    }
    
    private func setupNumpadViewLayout() {
        addSubview(numpadView)
        
        numpadView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(layout.current.numpadBottomInset)
            make.centerX.equalToSuperview()
            make.top.equalTo(logoutButton.snp.bottom).offset(layout.current.numpadTopInset)
            make.leading.trailing.lessThanOrEqualToSuperview()
        }
    }
    
    // MARK: Actions
    
    @objc
    private func notifyDelegateToLogoutButtonTapped() {
        delegate?.choosePasswordViewDidTapLogoutButton(self)
    }
}

extension ChoosePasswordView: NumpadViewDelegate {
    
    func numpadView(_ numpadView: NumpadView, didSelect value: NumpadValue) {
        delegate?.choosePasswordView(self, didSelect: value)
    }
}
