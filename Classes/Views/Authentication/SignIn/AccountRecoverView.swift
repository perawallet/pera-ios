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
        let fieldTopInset: CGFloat = 30.0
        let nextButtonTopInset: CGFloat = 52.0
        let multiFieldHeight: CGFloat = 160.0
        let bottomInset: CGFloat = 15.0
    }
    
    private let layout = Layout<LayoutConstants>()

    private enum Colors {
        static let separatorColor = rgba(0.67, 0.67, 0.72, 0.31)
    }
    
    weak var delegate: AccountRecoverViewDelegate?
    
    // MARK: Components
    
    private(set) lazy var accountNameInputView: SingleLineInputField = {
        let accountNameInputView = SingleLineInputField()
        accountNameInputView.explanationLabel.text = "account-name-setup-explanation".localized
        accountNameInputView.inputTextField.attributedPlaceholder = NSAttributedString(
            string: "account-name-setup-placeholder".localized,
            attributes: [NSAttributedString.Key.foregroundColor: SharedColors.softGray,
                         NSAttributedString.Key.font: UIFont.font(.overpass, withWeight: .semiBold(size: 14.0))]
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
        passPhraseInputView.rightInputAccessoryButton.setImage(img("icon-qr-scan"), for: .normal)
        return passPhraseInputView
    }()
    
    private(set) lazy var nextButton: MainButton = {
        let button = MainButton(title: "title-verify".localized)
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
        setupAccountNameInputViewLayout()
        setupPassPhraseInputViewLayout()
        setupNextButtonLayout()
    }
    
    private func setupAccountNameInputViewLayout() {
        addSubview(accountNameInputView)
        
        accountNameInputView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview().inset(layout.current.fieldTopInset)
        }
    }

    private func setupPassPhraseInputViewLayout() {
        addSubview(passPhraseInputView)
        
        passPhraseInputView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(accountNameInputView.snp.bottom)
            make.height.equalTo(layout.current.multiFieldHeight)
        }
    }
    
    private func setupNextButtonLayout() {
        addSubview(nextButton)
        
        nextButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(passPhraseInputView.snp.bottom).offset(layout.current.nextButtonTopInset)
            make.bottom.lessThanOrEqualToSuperview().inset(layout.current.bottomInset)
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
