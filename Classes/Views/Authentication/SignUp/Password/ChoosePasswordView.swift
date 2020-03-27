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
}

class ChoosePasswordView: BaseView {

    private struct LayoutConstants: AdaptiveLayoutConstants {
        let titleLabelTopInset: CGFloat = 69.0 * verticalScale
        let subtitleTopInset: CGFloat = 14.0 * verticalScale
        let subtitleHorizontalInset: CGFloat = 60.0
        let inputViewTopInset: CGFloat = 45.0 * verticalScale
        let numpadBottomInset: CGFloat = 32.0
        let numpadTopInset: CGFloat = 10.0 * verticalScale
        let passwordInputViewInset: CGFloat = -10.0
        let logoutButtonTopInset: CGFloat = 40.0 * verticalScale
        let logoutButtonHeight: CGFloat = 50.0
        let logoutButtonWidth: CGFloat = 115.0 * horizontalScale
    }
    
    private let layout = Layout<LayoutConstants>()
    
    // MARK: Components
    
    private(set) lazy var titleLabel: UILabel = {
        UILabel()
            .withTextColor(SharedColors.black)
            .withAlignment(.center)
            .withFont(UIFont.font(.overpass, withWeight: .semiBold(size: 20.0)))
    }()
    
    private(set) lazy var subtitleLabel: UILabel = {
        UILabel()
            .withTextColor(SharedColors.purple)
            .withLine(.contained)
            .withAlignment(.center)
            .withFont(UIFont.font(.avenir, withWeight: .medium(size: 16.0)))
    }()
    
    private(set) lazy var passwordInputView: PasswordInputView = {
        let view = PasswordInputView()
        return view
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
    
    override func configureAppearance() {
        backgroundColor = .white
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupTitleLabelLayout()
        setupSubtitleLabelLayout()
        setupPasswordViewLayout()
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
    
    private func setupNumpadViewLayout() {
        addSubview(numpadView)
        
        numpadView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(layout.current.numpadBottomInset + safeAreaBottom)
            make.centerX.equalToSuperview()
            make.leading.trailing.lessThanOrEqualToSuperview()
        }
    }
}

extension ChoosePasswordView: NumpadViewDelegate {
    
    func numpadView(_ numpadView: NumpadView, didSelect value: NumpadValue) {
        delegate?.choosePasswordView(self, didSelect: value)
    }
}
