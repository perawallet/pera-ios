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
        let titleLabelTopInset: CGFloat = 157.0
        let subtitleTopInset: CGFloat = 14.0
        let subtitleHorizontalInset: CGFloat = 60.0
        let inputViewTopInset: CGFloat = 45.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    // MARK: Components
    
    private(set) lazy var titleLabel: UILabel = {
        UILabel()
            .withTextColor(rgb(0.0, 0.46, 1.0))
            .withAlignment(.center)
            .withFont(UIFont.systemFont(ofSize: 22.0, weight: .bold))
    }()
    
    private(set) lazy var subtitleLabel: UILabel = {
        UILabel()
            .withTextColor(rgb(0.04, 0.05, 0.07))
            .withLine(.contained)
            .withAlignment(.center)
            .withFont(UIFont.systemFont(ofSize: 16.0, weight: .regular))
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
    
    override func configureAppearance() {
        backgroundColor = rgb(0.97, 0.97, 0.98)
    }
    
    override func linkInteractors() {
        numpadView.delegate = self
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupTitleLabelLayout()
        setupSubtitleLabelLayout()
        setupNumpadViewLayout()
        setupPasswordViewLayout()
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
    
    private func setupNumpadViewLayout() {
        addSubview(numpadView)
        
        numpadView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
            make.leading.trailing.lessThanOrEqualToSuperview()
        }
    }
    
    private func setupPasswordViewLayout() {
        addSubview(passwordInputView)
        
        passwordInputView.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(layout.current.inputViewTopInset)
            make.centerX.equalToSuperview()
        }
    }
}

extension ChoosePasswordView: NumpadViewDelegate {
    
    func numpadView(_ numpadView: NumpadView, didSelect value: NumpadValue) {
        delegate?.choosePasswordView(self, didSelect: value)
    }
}
