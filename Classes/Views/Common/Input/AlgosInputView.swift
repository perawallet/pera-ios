//
//  AlgosInputView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 8.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AlgosInputView: BaseView {

    private struct LayoutConstants: AdaptiveLayoutConstants {
        let defaultInset: CGFloat = 25.0
        let contentViewInset: CGFloat = 55.0
        let separatorHeight: CGFloat = 1.0
        let separatorTopInset: CGFloat = 25.0
        let imageViewTopInset: CGFloat = 14.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    private enum Colors {
        static let separatorColor = rgba(0.67, 0.67, 0.72, 0.31)
    }
    
    // MARK: Components
    
    private lazy var algosImageView = UIImageView(image: img("algo-icon-accounts"))
    
    private(set) lazy var inputTextField: CursorlessTextField = {
        let textField = CursorlessTextField()
        textField.textColor = SharedColors.black
        textField.tintColor = SharedColors.darkGray
        textField.keyboardType = .numberPad
        textField.font = UIFont.font(.overpass, withWeight: .bold(size: 40.0))
        textField.attributedPlaceholder = NSAttributedString(
            string: "0.000000",
            attributes: [NSAttributedString.Key.foregroundColor: SharedColors.black,
                         NSAttributedString.Key.font: UIFont.font(.overpass, withWeight: .bold(size: 40.0))]
        )
        textField.addTarget(self, action: #selector(didChangeText(_:)), for: .editingChanged)
        textField.delegate = self
        textField.adjustsFontSizeToFitWidth = true
        textField.textAlignment = .left
        return textField
    }()
    
    private(set) lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.separatorColor
        return view
    }()
    
    // MARK: Helpers
    
    var isEditing: Bool {
        return inputTextField.isFirstResponder
    }
    
    func beginEditing() {
        _ = inputTextField.becomeFirstResponder()
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        
        setupSeparatorViewLayout()
        setupInputTextFieldLayout()
        setupAlgosImageViewLayout()
    }
    
    private func setupSeparatorViewLayout() {
        addSubview(separatorView)
        
        separatorView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.height.equalTo(layout.current.separatorHeight)
            make.leading.trailing.equalToSuperview()
        }
    }
    
    private func setupInputTextFieldLayout() {
        addSubview(inputTextField)
        
        inputTextField.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.contentViewInset)
            make.trailing.equalToSuperview().inset(15.0)
            make.bottom.equalToSuperview().inset(layout.current.defaultInset)
            make.top.equalToSuperview()
        }
    }
    
    private func setupAlgosImageViewLayout() {
        addSubview(algosImageView)
        
        algosImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.defaultInset)
            make.top.equalTo(inputTextField).offset(layout.current.imageViewTopInset)
        }
    }
    
    // MARK: Helper
    @objc
    private func didChangeText(_ textField: UITextField) {
        guard let doubleValueString = textField.text?.currencyAlgosInputFormatting(),
            let doubleValue = doubleValueString.doubleForSendSeparator,
            doubleValue <= Double(maximumMicroAlgos) else {
            return
        }
        
        textField.text = doubleValueString
    }
}

// MARK: - TextFieldDelegate
extension AlgosInputView: UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard let text = textField.text else {
            return true
        }
        
        guard let doubleValueString = text.appending(string).currencyAlgosInputFormatting(),
            let doubleValue = doubleValueString.doubleForSendSeparator,
            doubleValue <= Double(maximumMicroAlgos) else {
                return false
        }
        
        if range.location + range.length < text.count {
            return false
        } else {
            return true
        }
    }
}
