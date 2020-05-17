//
//  AlgosInputView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 8.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AssetInputView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: AssetInputViewDelegate?
    
    private var shouldHandleMaxButtonStates: Bool
    private(set) var isMaxButtonSelected = false
    var maxAmount: Double = 0.0
    private var inputFieldFraction: Int
    private let maximumAmount: Int64
    
    private lazy var explanationLabel: UILabel = {
        UILabel()
            .withTextColor(SharedColors.subtitleText)
            .withLine(.single)
            .withAlignment(.left)
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
            .withText("send-algos-amount".localized)
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12.0
        view.backgroundColor = SharedColors.secondaryBackground
        return view
    }()
    
    private lazy var maxButton: UIButton = {
        let button = UIButton(type: .custom)
        button.isHidden = true
        button.titleLabel?.font = UIFont.font(withWeight: .semiBold(size: 12.0))
        button.setTitleColor(SharedColors.gray500, for: .normal)
        button.setTitle("title-max".localized, for: .normal)
        button.backgroundColor = SharedColors.secondaryBackground
        button.layer.borderWidth = 2.0
        button.layer.borderColor = SharedColors.gray200.cgColor
        button.layer.cornerRadius = 8.0
        return button
    }()
    
    private(set) lazy var inputTextField: CursorlessTextField = {
        let textField = CursorlessTextField()
        textField.textColor = SharedColors.primaryText
        textField.tintColor = SharedColors.primaryText
        textField.keyboardType = .numberPad
        textField.font = UIFont.font(withWeight: .medium(size: 14.0))
        textField.attributedPlaceholder = NSAttributedString(
            string: "0".currencyInputFormatting(with: inputFieldFraction) ?? "0.000000",
            attributes: [NSAttributedString.Key.foregroundColor: SharedColors.informationText,
                         NSAttributedString.Key.font: UIFont.font(withWeight: .medium(size: 14.0))]
        )
        textField.textAlignment = .left
        return textField
    }()
    
    func beginEditing() {
        _ = inputTextField.becomeFirstResponder()
    }

    init(inputFieldFraction: Int = algosFraction, shouldHandleMaxButtonStates: Bool = false) {
        self.inputFieldFraction = inputFieldFraction
        self.shouldHandleMaxButtonStates = shouldHandleMaxButtonStates
        maximumAmount = Int64.max / (pow(10, inputFieldFraction) as NSDecimalNumber).int64Value
        super.init(frame: .zero)
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        containerView.applySmallShadow()
    }
    
    override func setListeners() {
        inputTextField.delegate = self
    }
    
    override func linkInteractors() {
        maxButton.addTarget(self, action: #selector(notifyDelegateToMaxButtonTapped), for: .touchUpInside)
        inputTextField.addTarget(self, action: #selector(didChangeText(_:)), for: .editingChanged)
    }
    
    override func prepareLayout() {
        setupExplanationLabelLayout()
        setupContainerViewLayout()
        setupMaxButtonLayout()
        setupInputTextFieldLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.setShadowFrames()
    }
}

extension AssetInputView {
    private func setupExplanationLabelLayout() {
        addSubview(explanationLabel)
        
        explanationLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.trailing.lessThanOrEqualToSuperview().inset(layout.current.horizontalInset)
            make.top.equalToSuperview()
        }
    }
    
    private func setupContainerViewLayout() {
        addSubview(containerView)
        
        containerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.bottom.equalToSuperview()
            make.top.equalTo(explanationLabel.snp.bottom).offset(layout.current.contentViewInset)
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
            make.leading.equalToSuperview().inset(layout.current.fieldInset)
            make.top.bottom.equalToSuperview().inset(layout.current.verticalInset)
            make.trailing.equalTo(maxButton.snp.leading).offset(-layout.current.fieldInset)
            make.trailing.equalToSuperview().inset(layout.current.fieldInset).priority(.low)
        }
    }
}

extension AssetInputView {
    @objc
    private func didChangeText(_ textField: UITextField) {
        guard let doubleValueString = textField.text?.currencyInputFormatting(with: inputFieldFraction),
            let doubleValue = doubleValueString.doubleForSendSeparator(with: inputFieldFraction),
            doubleValue <= Double(maximumAmount) else {
            return
        }
        
        if isMaxButtonSelected && shouldHandleMaxButtonStates && doubleValue != maxAmount {
            toggleMaxButtonState(isSelected: false)
        }
        
        if doubleValue == maxAmount && shouldHandleMaxButtonStates {
            toggleMaxButtonState(isSelected: true)
        }
        
        textField.text = doubleValueString
    }
    
    @objc
    private func notifyDelegateToMaxButtonTapped() {
        toggleMaxButtonState()
        delegate?.assetInputViewDidTapMaxButton(self)
    }
    
    private func toggleMaxButtonState(isSelected: Bool? = nil) {
        if !shouldHandleMaxButtonStates {
            return
        }
        
        if let isSelected = isSelected {
            isMaxButtonSelected = isSelected
        } else {
            isMaxButtonSelected = !isMaxButtonSelected
        }
        
        if isMaxButtonSelected {
            maxButton.backgroundColor = SharedColors.primary
            maxButton.setTitleColor(SharedColors.primaryButtonTitle, for: .normal)
        } else {
            maxButton.backgroundColor = SharedColors.secondaryBackground
            maxButton.setTitleColor(SharedColors.gray500, for: .normal)
        }
    }
}

extension AssetInputView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else {
            return true
        }
        
        guard let doubleValueString = text.appending(string).currencyInputFormatting(with: inputFieldFraction),
            let doubleValue = doubleValueString.doubleForSendSeparator(with: inputFieldFraction),
            doubleValue <= Double(maximumAmount) else {
                return false
        }
        
        if range.location + range.length < text.count {
            return false
        } else {
            return true
        }
    }
}

extension AssetInputView {
    func setEnabled(_ enabled: Bool) {
        inputTextField.isEnabled = enabled
        
        if enabled {
            containerView.backgroundColor = SharedColors.secondaryBackground
        } else {
            containerView.backgroundColor = SharedColors.disabledBackground
        }
    }
    
    func setMaxButtonHidden(_ hidden: Bool) {
        maxButton.isHidden = hidden
    }
}

extension AssetInputView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let contentViewInset: CGFloat = 8.0
        let horizontalInset: CGFloat = 20.0
        let buttonTrailingInset: CGFloat = 8.0
        let buttonSize = CGSize(width: 53.0, height: 32.0)
        let verticalInset: CGFloat = 14.0
        let fieldInset: CGFloat = 16.0
    }
}

protocol AssetInputViewDelegate: class {
    func assetInputViewDidTapMaxButton(_ assetInputView: AssetInputView)
}
