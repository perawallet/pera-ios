//
//  ChoosePasswordView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 18.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class ChoosePasswordView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: ChoosePasswordViewDelegate?
    
    private let mode: ChoosePasswordViewController.Mode
    
    private lazy var unlockImageView = UIImageView(image: img("icon-lock"))
    
    private(set) lazy var titleLabel: UILabel = {
        UILabel()
            .withTextColor(SharedColors.primaryText)
            .withAlignment(.center)
            .withFont(UIFont.font(withWeight: .regular(size: 16.0 * verticalScale)))
    }()
    
    private(set) lazy var passwordInputView = PasswordInputView()
    
    private(set) lazy var numpadView = NumpadView()
    
    init(mode: ChoosePasswordViewController.Mode) {
        self.mode = mode
        super.init(frame: .zero)
    }
    
    override func linkInteractors() {
        numpadView.delegate = self
    }
    
    override func configureAppearance() {
        backgroundColor = SharedColors.secondaryBackground
    }
    
    override func prepareLayout() {
        setupUnlockImageViewLayout()
        setupTitleLabelLayout()
        setupPasswordViewLayout()
        setupNumpadViewLayout()
    }
}

extension ChoosePasswordView {
    private func setupUnlockImageViewLayout() {
        if mode != .login {
            return
        }
        
        addSubview(unlockImageView)
        
        unlockImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(layout.current.imageViewTopInset)
        }
    }
    
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            if mode == .login {
                make.top.equalTo(unlockImageView.snp.bottom).offset(layout.current.titleLabelImageOffset)
            } else {
                make.top.equalToSuperview().inset(layout.current.titleLabelTopInset)
            }
        }
    }
    
    private func setupPasswordViewLayout() {
        addSubview(passwordInputView)
        
        passwordInputView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.inputViewTopInset)
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
    func numpadView(_ numpadView: NumpadView, didSelect value: NumpadKey) {
        delegate?.choosePasswordView(self, didSelect: value)
    }
}

extension ChoosePasswordView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let imageViewHorizontalInset: CGFloat = 20.0
        let imageViewTopInset: CGFloat = 70.0 * verticalScale
        let titleLabelImageOffset: CGFloat = 40.0 * verticalScale
        let titleLabelTopInset: CGFloat = 100.0 * verticalScale
        let inputViewTopInset: CGFloat = 20.0 * verticalScale
        let numpadBottomInset: CGFloat = 32.0 * verticalScale
        let passwordInputViewInset: CGFloat = -10.0
    }
}

protocol ChoosePasswordViewDelegate: class {
    func choosePasswordView(_ choosePasswordView: ChoosePasswordView, didSelect value: NumpadKey)
}
