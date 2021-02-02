//
//  AccountRecoverView.swift

import UIKit

class AccountRecoverView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: AccountRecoverViewDelegate?
    
    private(set) lazy var accountNameInputView: SingleLineInputField = {
        let accountNameInputView = SingleLineInputField()
        accountNameInputView.explanationLabel.text = "recover-from-seed-name-title".localized
        accountNameInputView.placeholderText = "recover-from-seed-name-placeholder".localized
        accountNameInputView.nextButtonMode = .next
        accountNameInputView.inputTextField.autocorrectionType = .no
        return accountNameInputView
    }()
    
    private(set) lazy var passPhraseInputView: MultiLineInputField = {
        let passPhraseInputView = MultiLineInputField(displaysRightInputAccessoryButton: true)
        passPhraseInputView.explanationLabel.text = "recover-from-seed-passphrase-title".localized
        passPhraseInputView.placeholderLabel.text = "pass-pharase-enter-placeholder".localized
        passPhraseInputView.nextButtonMode = .submit
        passPhraseInputView.inputTextView.autocorrectionType = .no
        passPhraseInputView.inputTextView.autocapitalizationType = .none
        passPhraseInputView.rightInputAccessoryButton.setImage(img("icon-qr-scan"), for: .normal)
        passPhraseInputView.inputTextView.textContainer.heightTracksTextView = true
        passPhraseInputView.inputTextView.isScrollEnabled = false
        return passPhraseInputView
    }()
    
    private(set) lazy var nextButton = MainButton(title: "title-verify".localized)
    
    override func linkInteractors() {
        accountNameInputView.delegate = self
        passPhraseInputView.delegate = self
    }
    
    override func setListeners() {
        nextButton.addTarget(self, action: #selector(notifyDelegateToNextButtonTapped), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        setupAccountNameInputViewLayout()
        setupPassPhraseInputViewLayout()
        setupNextButtonLayout()
    }
}

extension AccountRecoverView {
    @objc
    func notifyDelegateToNextButtonTapped() {
        delegate?.accountRecoverViewDidTapNextButton(self)
    }
}

extension AccountRecoverView {
    private func setupAccountNameInputViewLayout() {
        addSubview(accountNameInputView)
        
        accountNameInputView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview().inset(layout.current.topInset)
        }
    }

    private func setupPassPhraseInputViewLayout() {
        addSubview(passPhraseInputView)
        
        passPhraseInputView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(accountNameInputView.snp.bottom).offset(layout.current.fieldTopInset)
        }
    }
    
    private func setupNextButtonLayout() {
        addSubview(nextButton)
        
        nextButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(passPhraseInputView.snp.bottom).offset(layout.current.nextButtonTopInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.bottom.lessThanOrEqualToSuperview().inset(layout.current.bottomInset)
        }
    }
}

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

extension AccountRecoverView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let topInset: CGFloat = 36.0
        let horizontalInset: CGFloat = 20.0
        let fieldTopInset: CGFloat = 20.0
        let nextButtonTopInset: CGFloat = 28.0
        let multiFieldHeight: CGFloat = 160.0
        let bottomInset: CGFloat = 20.0
    }
}

protocol AccountRecoverViewDelegate: class {
    func accountRecoverViewDidTapQRCodeButton(_ accountRecoverView: AccountRecoverView)
    func accountRecoverViewDidTapNextButton(_ accountRecoverView: AccountRecoverView)
}
