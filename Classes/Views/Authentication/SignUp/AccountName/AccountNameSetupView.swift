//
//  AccountNameView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 21.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol AccountNameSetupViewDelegate: class {
    
    func accountNameSetupViewDidTapNextButton(_ accountNameSetupView: AccountNameSetupView)
    func accountNameSetupViewDidChangeValue(_ accountNameSetupView: AccountNameSetupView)
}

class AccountNameSetupView: BaseView {

    private struct LayoutConstants: AdaptiveLayoutConstants {
        let topInset: CGFloat = 220.0
        let buttonBottomInset: CGFloat = 15.0
        let buttonTopInset: CGFloat = 120.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    // MARK: Components
    
    private(set) lazy var accountNameInputView: SingleLineInputField = {
        let accountNameInputView = SingleLineInputField(separatorStyle: .colored)
        accountNameInputView.explanationLabel.text = "account-name-setup-explanation".localized
        accountNameInputView.inputTextField.attributedPlaceholder = NSAttributedString(
            string: "account-name-setup-placeholder".localized,
            attributes: [NSAttributedString.Key.foregroundColor: SharedColors.softGray,
                         NSAttributedString.Key.font: UIFont.font(.montserrat, withWeight: .semiBold(size: 13.0))]
        )
        accountNameInputView.nextButtonMode = .submit
        accountNameInputView.inputTextField.autocorrectionType = .no
        return accountNameInputView
    }()
    
    private(set) lazy var nextButton: MainButton = {
        let button = MainButton(title: "title-next".localized)
        return button
    }()
    
    weak var delegate: AccountNameSetupViewDelegate?
    
    // MARK: Configuration
    
    override func linkInteractors() {
        accountNameInputView.delegate = self
    }
    
    override func setListeners() {
        nextButton.addTarget(self, action: #selector(notifyDelegateToNextButtonTapped), for: .touchUpInside)
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupAccountNameInputViewLayout()
        setupNextButtonLayout()
    }
    
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
            make.centerX.equalToSuperview()
        }
    }
    
    // MARK: Actions
    
    @objc
    func notifyDelegateToNextButtonTapped() {
        delegate?.accountNameSetupViewDidTapNextButton(self)
    }
}

extension AccountNameSetupView: InputViewDelegate {
    
    func inputViewDidChangeValue(inputView: BaseInputView) {
        delegate?.accountNameSetupViewDidChangeValue(self)
    }
}
