//
//  SingleLineInputField.swift

import UIKit

class SingleLineInputField: BaseInputView {
    
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
    
    var placeholderText: String = "" {
        didSet {
            inputTextField.attributedPlaceholder = NSAttributedString(
                string: placeholderText,
                attributes: [.foregroundColor: Colors.Text.hint, .font: UIFont.font(withWeight: .medium(size: 14.0))]
            )
        }
    }
    
    private(set) lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = Colors.Background.secondary
        textField.textColor = Colors.Text.primary
        textField.tintColor = Colors.Text.primary
        textField.font = UIFont.font(withWeight: .medium(size: 14.0))
        return textField
    }()
    
    var isEditing: Bool {
        return inputTextField.isFirstResponder
    }
    
    func beginEditing() {
        _ = inputTextField.becomeFirstResponder()
    }
    
    override func setListeners() {
        super.setListeners()
        inputTextField.addTarget(self, action: #selector(didChange(textField:)), for: .editingChanged)
    }
    
    override func linkInteractors() {
        super.linkInteractors()
        inputTextField.delegate = self
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        setupInputTextFieldLayout()
    }
}

extension SingleLineInputField {
    private func setupInputTextFieldLayout() {
        contentView.addSubview(inputTextField)
        
        inputTextField.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(layout.current.verticalInset)
            
            if displaysRightInputAccessoryButton {
                make.trailing.equalTo(rightInputAccessoryButton.snp.leading).offset(-layout.current.itemOffset)
            } else {
                make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            }
            
            if displaysLeftImageView {
                make.leading.equalTo(leftImageView.snp.trailing).offset(layout.current.itemOffset)
            } else {
                make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            }
        }
    }
}

extension SingleLineInputField {
    @objc
    func didChange(textField: UITextField) {
        delegate?.inputViewDidChangeValue(inputView: self)
    }
}

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

extension SingleLineInputField {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let verticalInset: CGFloat = 14.0
        let horizontalInset: CGFloat = 16.0
        let itemOffset: CGFloat = 12.0
    }
}
