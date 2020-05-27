//
//  LedgerPairingView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 23.02.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class LedgerPairingView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: LedgerPairingViewDelegate?

    private(set) lazy var accountNameInputView: SingleLineInputField = {
        let accountNameInputView = SingleLineInputField(displaysLeftImageView: true)
        accountNameInputView.explanationLabel.text = "account-name-setup-explanation".localized
        accountNameInputView.placeholderText = "account-name-setup-placeholder".localized
        accountNameInputView.leftImageView.image = img("img-ledger-small")
        accountNameInputView.nextButtonMode = .submit
        accountNameInputView.inputTextField.autocorrectionType = .no
        return accountNameInputView
    }()
    
    private(set) lazy var addressInputView: MultiLineInputField = {
        let addressInputView = MultiLineInputField()
        addressInputView.explanationLabel.text = "ledger-pairing-key-title".localized
        addressInputView.inputTextView.isSelectable = false
        addressInputView.inputTextView.isEditable = false
        return addressInputView
    }()
    
    private(set) lazy var createAccountButton = MainButton(title: "ledger-pairing-create-title".localized)
    
    override func linkInteractors() {
        accountNameInputView.delegate = self
    }
    
    override func setListeners() {
        createAccountButton.addTarget(self, action: #selector(notifyDelegateToCreateAccount), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        setupAccountNameInputViewLayout()
        setupAddressInputViewLayout()
        setupCreateAccountButtonLayout()
    }
}

extension LedgerPairingView {
    @objc
    func notifyDelegateToCreateAccount() {
        delegate?.ledgerPairingViewDidTapCreateAccountButton(self)
    }
}

extension LedgerPairingView {
    private func setupAccountNameInputViewLayout() {
        addSubview(accountNameInputView)
        
        accountNameInputView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview().inset(layout.current.topInset)
        }
    }

    private func setupAddressInputViewLayout() {
        addSubview(addressInputView)
        
        addressInputView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(accountNameInputView.snp.bottom).offset(layout.current.fieldTopInset)
            make.height.equalTo(layout.current.multiFieldHeight)
        }
    }
    
    private func setupCreateAccountButtonLayout() {
        addSubview(createAccountButton)
        
        createAccountButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(addressInputView.snp.bottom).offset(layout.current.buttonTopInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.bottom.lessThanOrEqualToSuperview().inset(layout.current.bottomInset)
        }
    }
}

extension LedgerPairingView {
    func setAddress(_ address: String) {
        addressInputView.inputTextView.text = address
    }
}

extension LedgerPairingView: InputViewDelegate {
    func inputViewDidReturn(inputView: BaseInputView) {
        if inputView == accountNameInputView {
            delegate?.ledgerPairingViewDidTapCreateAccountButton(self)
        }
    }
}

extension LedgerPairingView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let topInset: CGFloat = 36.0
        let fieldTopInset: CGFloat = 20.0
        let buttonTopInset: CGFloat = 24.0
        let multiFieldHeight: CGFloat = 96.0
        let bottomInset: CGFloat = 30.0
        let horizontalInset: CGFloat = 20.0
    }
}

protocol LedgerPairingViewDelegate: class {
    func ledgerPairingViewDidTapCreateAccountButton(_ ledgerPairingView: LedgerPairingView)
}
