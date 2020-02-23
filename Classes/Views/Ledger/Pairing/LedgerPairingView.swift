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
        let accountNameInputView = SingleLineInputField()
        accountNameInputView.explanationLabel.text = "account-name-setup-explanation".localized
        accountNameInputView.inputTextField.attributedPlaceholder = NSAttributedString(
            string: "account-name-setup-placeholder".localized,
            attributes: [NSAttributedString.Key.foregroundColor: SharedColors.softGray,
                         NSAttributedString.Key.font: UIFont.font(.overpass, withWeight: .semiBold(size: 13.0))]
        )
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
            make.top.equalToSuperview().inset(layout.current.fieldTopInset)
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
            make.top.greaterThanOrEqualTo(addressInputView.snp.bottom).offset(layout.current.fieldTopInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.buttonHorizontalInset)
            make.bottom.equalToSuperview().inset(layout.current.bottomInset)
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
        let fieldTopInset: CGFloat = 30.0
        let nextButtonTopInset: CGFloat = 52.0
        let multiFieldHeight: CGFloat = 95.0
        let bottomInset: CGFloat = 60.0
        let buttonHorizontalInset: CGFloat = MainButton.Constants.horizontalInset
    }
}

protocol LedgerPairingViewDelegate: class {
    func ledgerPairingViewDidTapCreateAccountButton(_ ledgerPairingView: LedgerPairingView)
}
