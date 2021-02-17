// Copyright 2019 Algorand, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//  AccountNameSetupView.swift

import UIKit

class AccountNameSetupView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: AccountNameSetupViewDelegate?
    
    private(set) lazy var accountNameInputView: SingleLineInputField = {
        let accountNameInputView = SingleLineInputField()
        accountNameInputView.explanationLabel.text = "account-name-setup-explanation".localized
        accountNameInputView.placeholderText = "account-name-setup-placeholder".localized
        accountNameInputView.nextButtonMode = .submit
        accountNameInputView.inputTextField.autocorrectionType = .no
        return accountNameInputView
    }()
    
    private(set) lazy var nextButton = MainButton(title: "title-next".localized)
    
    override func linkInteractors() {
        accountNameInputView.delegate = self
    }
    
    override func setListeners() {
        nextButton.addTarget(self, action: #selector(notifyDelegateToNextButtonTapped), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        setupAccountNameInputViewLayout()
        setupNextButtonLayout()
    }
}

extension AccountNameSetupView {
    @objc
    func notifyDelegateToNextButtonTapped() {
        delegate?.accountNameSetupViewDidTapNextButton(self)
    }
}

extension AccountNameSetupView {
    private func setupAccountNameInputViewLayout() {
        addSubview(accountNameInputView)
        
        accountNameInputView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview().inset(layout.current.topInset)
        }
    }

    private func setupNextButtonLayout() {
        addSubview(nextButton)
        
        nextButton.snp.makeConstraints { make in
            make.top.equalTo(accountNameInputView.snp.bottom).offset(layout.current.buttonTopInset)
            make.bottom.lessThanOrEqualToSuperview().inset(layout.current.buttonBottomInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.centerX.equalToSuperview()
        }
    }
}

extension AccountNameSetupView {
    func beginEditing() {
        accountNameInputView.beginEditing()
    }
}

extension AccountNameSetupView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let topInset: CGFloat = 36.0
        let buttonBottomInset: CGFloat = 15.0
        let buttonTopInset: CGFloat = 24.0
        let horizontalInset: CGFloat = 20.0
    }
}

extension AccountNameSetupView: InputViewDelegate {
    func inputViewDidChangeValue(inputView: BaseInputView) {
        delegate?.accountNameSetupViewDidChangeValue(self)
    }
}

protocol AccountNameSetupViewDelegate: class {
    func accountNameSetupViewDidTapNextButton(_ accountNameSetupView: AccountNameSetupView)
    func accountNameSetupViewDidChangeValue(_ accountNameSetupView: AccountNameSetupView)
}
