//
//  SingleLineInputField.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 21.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class SingleLineInputField: BaseInputView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let verticalInset: CGFloat = 16.0
        let horizontalInset: CGFloat = 15.0
        let minimumHorizontalInset: CGFloat = -3.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    override var nextButtonMode: NextButtonMode {
        didSet {
            switch nextButtonMode {
            case .next:
                inputTextField.returnKeyType = .next
            case .submit:
                inputTextField.returnKeyType = .go
            }
        }
    }
    
    // MARK: Components

    private(set) lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.textColor = SharedColors.black
        textField.tintColor = SharedColors.black
        textField.font = UIFont.font(.overpass, withWeight: .semiBold(size: 13.0))
        return textField
    }()
    
    // MARK: Helpers
    
    var isEditing: Bool {
        return inputTextField.isFirstResponder
    }
    
    func beginEditing() {
        _ = inputTextField.becomeFirstResponder()
    }
    
    // MARK: Setup
    
    override func setListeners() {
        super.setListeners()
        
        inputTextField.addTarget(self, action: #selector(didChange(textField:)), for: .editingChanged)
    }
    
    override func linkInteractors() {
        super.linkInteractors()
        
        inputTextField.delegate = self
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        super.prepareLayout()
        
        setupInputTextFieldLayout()
    }
    
    private func setupInputTextFieldLayout() {
        contentView.addSubview(inputTextField)
        
        inputTextField.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.bottom.equalToSuperview().inset(layout.current.verticalInset)
            
            if displaysRightInputAccessoryButton {
                make.trailing.equalTo(rightInputAccessoryButton.snp.leading).offset(layout.current.minimumHorizontalInset)
            } else {
                make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            }
        }
    }
    
    // MARK: Actions
    
    @objc
    func didChange(textField: UITextField) {
        delegate?.inputViewDidChangeValue(inputView: self)
    }
}

// MARK: UITextFieldDelegate

extension SingleLineInputField: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        inputTextField.layoutIfNeeded()
        
        delegate?.inputViewDidEndEditing(inputView: self)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.inputViewDidBeginEditing(inputView: self)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        delegate?.inputViewDidReturn(inputView: self)
        
        return true
    }
}
