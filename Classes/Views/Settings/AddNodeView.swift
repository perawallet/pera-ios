//
//  AddNodeView.swift
//  algorand
//
//  Created by Omer Emre Aslan on 11.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AddNodeView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let labelTopInset: CGFloat = 20.0
        let inputHeight: CGFloat = 87.0
        let verticalOffset: CGFloat = 20.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    private(set) lazy var nameInputView: SingleLineInputField = {
        let inputView = SingleLineInputField(separatorStyle: .full)
        inputView.explanationLabel.text = "node-settings-enter-node-name".localized
        inputView.inputTextField.attributedPlaceholder = NSAttributedString(
            string: "node-settings-placeholder-name".localized,
            attributes: [NSAttributedString.Key.foregroundColor: SharedColors.softGray,
                         NSAttributedString.Key.font: UIFont.font(.opensans, withWeight: .semiBold(size: 12.0))]
        )
        
        inputView.inputTextField.textColor = SharedColors.black
        inputView.inputTextField.tintColor = SharedColors.black
        inputView.inputTextField.font = UIFont.font(.opensans, withWeight: .semiBold(size: 12.0))
        inputView.nextButtonMode = .next
        inputView.inputTextField.autocorrectionType = .no
        inputView.backgroundColor = .white
        return inputView
    }()
    
    private(set) lazy var addressInputView: SingleLineInputField = {
        let inputView = SingleLineInputField(separatorStyle: .full)
        inputView.explanationLabel.text = "node-settings-enter-node-address".localized
        inputView.inputTextField.attributedPlaceholder = NSAttributedString(
            string: "node-settings-placeholder-address".localized,
            attributes: [NSAttributedString.Key.foregroundColor: SharedColors.softGray,
                         NSAttributedString.Key.font: UIFont.font(.opensans, withWeight: .semiBold(size: 12.0))]
        )
        
        inputView.inputTextField.textColor = SharedColors.black
        inputView.inputTextField.tintColor = SharedColors.black
        inputView.inputTextField.font = UIFont.font(.opensans, withWeight: .semiBold(size: 12.0))
        inputView.nextButtonMode = .next
        inputView.inputTextField.autocorrectionType = .no
        inputView.backgroundColor = .white
        return inputView
    }()
    
    private(set) lazy var tokenInputView: SingleLineInputField = {
        let inputView = SingleLineInputField(separatorStyle: .full)
        inputView.explanationLabel.text = "node-settings-api-key".localized
        inputView.inputTextField.attributedPlaceholder = NSAttributedString(
            string: "node-settings-placeholder-api-key".localized,
            attributes: [NSAttributedString.Key.foregroundColor: SharedColors.softGray,
                         NSAttributedString.Key.font: UIFont.font(.opensans, withWeight: .semiBold(size: 12.0))]
        )
        
        inputView.inputTextField.textColor = SharedColors.black
        inputView.inputTextField.tintColor = SharedColors.black
        inputView.inputTextField.font = UIFont.font(.opensans, withWeight: .semiBold(size: 12.0))
        inputView.nextButtonMode = .next
        inputView.inputTextField.autocorrectionType = .no
        inputView.backgroundColor = .white
        return inputView
    }()
    
    private(set) lazy var testButton: MainButton = {
        let button = MainButton(title: "node-settings-test-button-title".localized)
        return button
    }()
    
    override func prepareLayout() {
        super.prepareLayout()
        
        setupNameInputViewLayout()
        setupAddressInputViewLayout()
        setupTokenInputViewLayout()
        setupTestButtonLayout()
    }
    
    private func setupNameInputViewLayout() {
        addSubview(nameInputView)
        
        nameInputView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(layout.current.inputHeight)
        }
        
        nameInputView.explanationLabel.snp.updateConstraints { make in
            make.top.equalToSuperview().inset(layout.current.labelTopInset)
        }
    }
    
    private func setupAddressInputViewLayout() {
        addSubview(addressInputView)
        
        addressInputView.snp.makeConstraints { make in
            make.top.equalTo(nameInputView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(layout.current.inputHeight)
        }
        
        addressInputView.explanationLabel.snp.updateConstraints { make in
            make.top.equalToSuperview().inset(layout.current.labelTopInset)
        }
    }
    
    private func setupTokenInputViewLayout() {
        addSubview(tokenInputView)
        
        tokenInputView.snp.makeConstraints { make in
            make.top.equalTo(addressInputView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(layout.current.inputHeight)
        }
        
        tokenInputView.explanationLabel.snp.updateConstraints { make in
            make.top.equalToSuperview().inset(layout.current.labelTopInset)
        }
    }
    
    private func setupTestButtonLayout() {
        addSubview(testButton)
        
        testButton.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(tokenInputView.snp.bottom).offset(layout.current.verticalOffset)
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-layout.current.verticalOffset)
            make.centerX.equalToSuperview()
        }
    }
}
