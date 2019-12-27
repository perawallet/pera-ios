//
//  AlgosInputView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 8.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol AssetInputViewDelegate: class {
    func assetInputViewDidTapMaxButton(_ assetInputView: AssetInputView)
}

class AssetInputView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private enum Colors {
        static let borderColor = rgb(0.91, 0.91, 0.92)
    }
    
    weak var delegate: AssetInputViewDelegate?
    
    private var shouldHandleMaxButtonStates: Bool
    private(set) var isMaxButtonSelected = false
    var maxAmount: Double = 0.0
    private var inputFieldFraction: Int
    
    // MARK: Components
    
    private(set) lazy var explanationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.font(.avenir, withWeight: .medium(size: 13.0))
        label.textColor = SharedColors.greenishGray
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
    
    private(set) lazy var algosImageView = UIImageView(image: img("icon-algo-black"))
    
    private(set) lazy var maxButton: UIButton = {
        let button = UIButton(type: .custom)
        button.isHidden = true
        button.titleLabel?.font = UIFont.font(.avenir, withWeight: .bold(size: 10.0))
        button.setAttributedTitle("title-max".localized.attributed([.letterSpacing(1.10), .textColor(SharedColors.gray)]), for: .normal)
        button.setBackgroundImage(img("bg-max-button"), for: .normal)
        button.layer.borderWidth = 1.0
        button.layer.borderColor = Colors.borderColor.cgColor
        button.layer.cornerRadius = 4.0
        return button
    }()
    
    private(set) lazy var inputTextField: CursorlessTextField = {
        let textField = CursorlessTextField()
        textField.textColor = .black
        textField.tintColor = .black
        textField.keyboardType = .numberPad
        textField.font = UIFont.font(.overpass, withWeight: .semiBold(size: 14.0))
        textField.attributedPlaceholder = NSAttributedString(
            string: "0".currencyInputFormatting(with: inputFieldFraction) ?? "0.000000",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.black,
                         NSAttributedString.Key.font: UIFont.font(.overpass, withWeight: .semiBold(size: 14.0))]
        )
        textField.addTarget(self, action: #selector(didChangeText(_:)), for: .editingChanged)
        textField.delegate = self
        textField.adjustsFontSizeToFitWidth = true
        textField.textAlignment = .left
        return textField
    }()
    
    var isEditing: Bool {
        return inputTextField.isFirstResponder
    }
    
    func beginEditing() {
        _ = inputTextField.becomeFirstResponder()
    }

    init(inputFieldFraction: Int = algosFraction, shouldHandleMaxButtonStates: Bool = false) {
        self.inputFieldFraction = inputFieldFraction
        self.shouldHandleMaxButtonStates = shouldHandleMaxButtonStates
        super.init(frame: .zero)
    }
    
    override func linkInteractors() {
        maxButton.addTarget(self, action: #selector(notifyDelegateToMaxButtonTapped), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        setupExplanationLabelLayout()
        setupContainerViewLayout()
        setupAlgosImageViewLayout()
        setupMaxButtonLayout()
        setupInputTextFieldLayout()
    }
}

extension AssetInputView {
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
            make.leading.equalToSuperview().inset(layout.current.defaultInset).priority(.low)
            make.trailing.lessThanOrEqualToSuperview().inset(layout.current.fieldTrailingInset)
            make.centerY.equalToSuperview()
        }
    }
}

extension AssetInputView {
    @objc
    private func didChangeText(_ textField: UITextField) {
        guard let doubleValueString = textField.text?.currencyInputFormatting(with: inputFieldFraction),
            let doubleValue = doubleValueString.doubleForSendSeparator(with: inputFieldFraction),
            doubleValue <= Double(maximumMicroAlgos) else {
            return
        }
        
        if isMaxButtonSelected && shouldHandleMaxButtonStates && doubleValue != maxAmount {
            toggleMaxButtonState(isSelected: false)
        }
        
        if doubleValue == maxAmount && shouldHandleMaxButtonStates {
            textField.text = String(maxAmount).currencyInputFormatting(with: inputFieldFraction)
            toggleMaxButtonState(isSelected: true)
            return
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
            maxButton.setAttributedTitle("title-max".localized.attributed([.letterSpacing(1.10), .textColor(.white)]), for: .normal)
            maxButton.setBackgroundImage(img("bg-max-button-selected"), for: .normal)
            maxButton.layer.borderColor = SharedColors.purple.cgColor
        } else {
            maxButton.setAttributedTitle(
                "title-max".localized.attributed([
                    .letterSpacing(1.10),
                    .textColor(SharedColors.gray)
                ]),
                for: .normal
            )
            maxButton.setBackgroundImage(img("bg-max-button"), for: .normal)
            maxButton.layer.borderColor = Colors.borderColor.cgColor
        }
    }
}

// MARK: - TextFieldDelegate
extension AssetInputView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else {
            return true
        }
        
        guard let doubleValueString = text.appending(string).currencyInputFormatting(with: inputFieldFraction),
            let doubleValue = doubleValueString.doubleForSendSeparator(with: inputFieldFraction),
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

extension AssetInputView {
    func set(enabled: Bool) {
        inputTextField.isEnabled = enabled
        
        if enabled {
            containerView.backgroundColor = .white
        } else {
            containerView.backgroundColor = Colors.borderColor
        }
    }
}

extension AssetInputView {
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
}
