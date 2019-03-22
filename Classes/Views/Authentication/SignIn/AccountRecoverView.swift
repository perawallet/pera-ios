//
//  AccountRecoverView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 21.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol AccountRecoverViewDelegate: class {
    
    func accountRecoverViewDidTapQRCodeButton(_ accountRecoverView: AccountRecoverView)
    func accountRecoverViewDidTapNextButton(_ accountRecoverView: AccountRecoverView)
}

class AccountRecoverView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let verticalInset: CGFloat = 94.0
        let createButtonTopInset: CGFloat = 42.0
        let bottomInset: CGFloat = 83.0
        let buttonMinimumTopInset: CGFloat = 10.0
    }
    
    private let layout = Layout<LayoutConstants>()

    weak var delegate: AccountRecoverViewDelegate?
    
    // MARK: Components
    
    private lazy var topSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = rgba(0.67, 0.67, 0.72, 0.31)
        return view
    }()
    
    private(set) lazy var accountNameInputView: SingleLineInputField = {
        let accountNameInputView = SingleLineInputField()
        accountNameInputView.explanationLabel.text = "account-name-setup-explanation".localized
        accountNameInputView.inputTextField.attributedPlaceholder = NSAttributedString(
            string: "account-name-setup-placeholder".localized,
            attributes: [NSAttributedString.Key.foregroundColor: rgb(0.67, 0.67, 0.72),
                         NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13.0, weight: .semibold)]
        )
        accountNameInputView.nextButtonMode = .next
        accountNameInputView.inputTextField.autocorrectionType = .no
        return accountNameInputView
    }()
    
    private(set) lazy var passPhraseInputView: MultiLineInputField = {
        let passPhraseInputView = MultiLineInputField(displaysExplanationText: false, displaysRightInputAccessoryButton: true)
        passPhraseInputView.placeholderLabel.text = "pass-pharase-enter-placeholder".localized
        passPhraseInputView.nextButtonMode = .submit
        passPhraseInputView.inputTextView.autocorrectionType = .no
        passPhraseInputView.inputTextView.autocapitalizationType = .none
        passPhraseInputView.rightInputAccessoryButton.setImage(img("icon-qr"), for: .normal)
        return passPhraseInputView
    }()
    
    private(set) lazy var nextButton: MainButton = {
        let button = MainButton(title: "title-next".localized)
        return button
    }()
    
    // MARK: Configuration
    
    override func linkInteractors() {
        accountNameInputView.delegate = self
        passPhraseInputView.delegate = self
    }
    
    override func setListeners() {
        nextButton.addTarget(self, action: #selector(notifyDelegateToNextButtonTapped), for: .touchUpInside)
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupTopSeparatorViewLayout()
        setupAccountNameInputViewLayout()
        setupPassPhraseInputViewLayout()
        setupNextButtonLayout()
    }
    
    private func setupTopSeparatorViewLayout() {
        addSubview(topSeparatorView)
        
        topSeparatorView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(1.0)
        }
    }
    
    private func setupAccountNameInputViewLayout() {
        addSubview(accountNameInputView)
        
        accountNameInputView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(topSeparatorView.snp.bottom).offset(20.0)
        }
    }

    private func setupPassPhraseInputViewLayout() {
        addSubview(passPhraseInputView)
        
        passPhraseInputView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(accountNameInputView.snp.bottom)
        }
    }
    
    private func setupNextButtonLayout() {
        addSubview(nextButton)
        
        nextButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(passPhraseInputView.snp.bottom).offset(144.0)
            make.bottom.lessThanOrEqualToSuperview().inset(15.0)
        }
    }
    
    // MARK: Actions
    
    @objc
    func notifyDelegateToNextButtonTapped() {
        delegate?.accountRecoverViewDidTapNextButton(self)
    }
}

// MARK: InputViewDelegate

extension AccountRecoverView: InputViewDelegate {
    
    func inputViewDidTapAccessoryButton(inputView: BaseInputView) {
        delegate?.accountRecoverViewDidTapQRCodeButton(self)
    }
    
    func inputViewDidReturn(inputView: BaseInputView) {
        if inputView == accountNameInputView {
            passPhraseInputView.beginEditing()
        } else {
            delegate?.accountRecoverViewDidTapNextButton(self)
        }
    }
}
