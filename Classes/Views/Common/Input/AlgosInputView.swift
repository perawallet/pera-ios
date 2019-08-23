//
//  AlgosInputView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 8.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol AlgosInputViewDelegate: class {
    func algosInputViewDidTapMaxButton(_ algosInputView: AlgosInputView)
}

class AlgosInputView: BaseView {

    private struct LayoutConstants: AdaptiveLayoutConstants {
        let defaultInset: CGFloat = 15.0
        let horizontalInset: CGFloat = 30.0
        let contentViewInset: CGFloat = 7.0
        let topInset: CGFloat = 10.0
        let imageViewHeight: CGFloat = 10.0
        let containerHeight: CGFloat = 50.0
        let fieldLeadingInset: CGFloat = 3.0
        let fieldTrailingInset: CGFloat = 70.0
        let buttonSize = CGSize(width: 60.0, height: 34.0)
        let buttonTrailingInset: CGFloat = 8.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    private enum Colors {
        static let borderColor = rgb(0.94, 0.94, 0.94)
    }
    
    weak var delegate: AlgosInputViewDelegate?
    
    // MARK: Components
    
    private(set) lazy var explanationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.font(.avenir, withWeight: .medium(size: 13.0))
        label.textColor = SharedColors.gray
        label.text = "send-algos-amount".localized
        return label
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 1.0
        view.layer.borderColor = Colors.borderColor.cgColor
        view.layer.cornerRadius = 4.0
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var algosImageView = UIImageView(image: img("icon-algo-black"))
    
    private(set) lazy var maxButton: UIButton = {
        let button = UIButton(type: .custom)
        button.isHidden = true
        return button
    }()
    
    private(set) lazy var inputTextField: CursorlessTextField = {
        let textField = CursorlessTextField()
        textField.textColor = .black
        textField.tintColor = .black
        textField.keyboardType = .numberPad
        textField.font = UIFont.font(.overpass, withWeight: .semiBold(size: 14.0))
        textField.attributedPlaceholder = NSAttributedString(
            string: "0.000000",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.black,
                         NSAttributedString.Key.font: UIFont.font(.overpass, withWeight: .semiBold(size: 14.0))]
        )
        textField.addTarget(self, action: #selector(didChangeText(_:)), for: .editingChanged)
        textField.delegate = self
        textField.adjustsFontSizeToFitWidth = true
        textField.textAlignment = .left
        return textField
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
        setupExplanationLabelLayout()
        setupContainerViewLayout()
        setupAlgosImageViewLayout()
        setupMaxButtonLayout()
        setupInputTextFieldLayout()
    }
    
    private func setupExplanationLabelLayout() {
        addSubview(explanationLabel)
        
        explanationLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.trailing.lessThanOrEqualToSuperview().inset(layout.current.horizontalInset)
            make.top.equalToSuperview().inset(layout.current.topInset)
        }
    }
    
    private func setupContainerViewLayout() {
        addSubview(containerView)
        
        containerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.defaultInset)
            make.bottom.equalToSuperview()
            make.height.equalTo(layout.current.containerHeight)
            make.top.equalTo(explanationLabel.snp.bottom).offset(layout.current.contentViewInset)
        }
    }
    
    private func setupAlgosImageViewLayout() {
        containerView.addSubview(algosImageView)
        
        algosImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.defaultInset)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(layout.current.imageViewHeight)
        }
    }
    
    private func setupMaxButtonLayout() {
        containerView.addSubview(maxButton)
        
        maxButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(layout.current.buttonTrailingInset)
            make.size.equalTo(layout.current.buttonSize)
            make.centerY.equalToSuperview()
        }
    }
    
    private func setupInputTextFieldLayout() {
        containerView.addSubview(inputTextField)
        
        inputTextField.snp.makeConstraints { make in
            make.leading.equalTo(algosImageView.snp.trailing).offset(layout.current.fieldLeadingInset)
            make.trailing.equalToSuperview().inset(layout.current.fieldTrailingInset)
            make.centerY.equalToSuperview()
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
    
    @objc
    private func notifyDelegateToMaxButtonTapped() {
        delegate?.algosInputViewDidTapMaxButton(self)
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
