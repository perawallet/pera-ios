//
//  AddNodeView.swift
//  algorand
//
//  Created by Omer Emre Aslan on 11.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AddNodeView: BaseView {
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
        
        addSubview(addressInputView)
        
        addressInputView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(87)
        }
        
        addressInputView.explanationLabel.snp.updateConstraints { make in
            make.top.equalToSuperview().inset(20)
        }
        
        addSubview(tokenInputView)
        
        tokenInputView.snp.makeConstraints { make in
            make.top.equalTo(addressInputView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(87)
        }
        
        tokenInputView.explanationLabel.snp.updateConstraints { make in
            make.top.equalToSuperview().inset(20)
        }
        
        addSubview(testButton)
        
        testButton.snp.makeConstraints { make in
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-20)
            make.centerX.equalToSuperview()
        }
        
    }
}
