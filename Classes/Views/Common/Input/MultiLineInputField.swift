//
//  MultiLineInputField.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 21.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class MultiLineInputField: BaseInputView {
    
    private let layout = Layout<LayoutConstants>()
    
    override var nextButtonMode: NextButtonMode {
        didSet {
            switch nextButtonMode {
            case .next:
                inputTextView.returnKeyType = .next
            case .submit:
                inputTextView.returnKeyType = .go
            }
        }
    }
    
    private(set) lazy var inputTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.font(withWeight: .medium(size: 14.0))
        textView.textColor = SharedColors.primaryText
        textView.tintColor = SharedColors.primaryText
        textView.backgroundColor = .clear
        textView.isSelectable = true
        textView.isEditable = true
        textView.textContainer.heightTracksTextView = false
        textView.isScrollEnabled = true
        return textView
    }()
    
    private(set) lazy var placeholderLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
            .withLine(.contained)
            .withTextColor(SharedColors.informationText)
            .withAlignment(.left)
    }()
    
    var isEditing: Bool {
        return inputTextView.isFirstResponder
    }
    
    func beginEditing() {
        _ = inputTextView.becomeFirstResponder()
    }
    
    var value: String = "" {
        didSet {
            if value == oldValue {
                return
            }
            
            placeholderLabel.isHidden = !value.isEmpty
            inputTextView.text = value
        }
    }
    
    override func linkInteractors() {
        super.linkInteractors()
        inputTextView.delegate = self
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        setupInputTextViewLayout()
        setupPlaceholderLabelLayout()
    }
}

extension MultiLineInputField {
    private func setupInputTextViewLayout() {
        contentView.addSubview(inputTextView)
        
        inputTextView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.verticalInset)
            make.bottom.equalToSuperview().inset(layout.current.verticalInset)
            
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
    
    private func setupPlaceholderLabelLayout() {
        contentView.addSubview(placeholderLabel)
        
        placeholderLabel.snp.makeConstraints { make in
            make.top.equalTo(inputTextView.textInputView).offset(layout.current.placeholderTopOffset)
            make.leading.trailing.equalTo(inputTextView.textInputView).offset(layout.current.placeholderInset)
        }
    }
}

extension MultiLineInputField: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        delegate?.inputViewDidBeginEditing(inputView: self)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        delegate?.inputViewDidEndEditing(inputView: self)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = (!textView.text.isEmpty)
        
        delegate?.inputViewDidChangeValue(inputView: self)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
        }
        
        guard let delegate = delegate else {
            return true
        }
        
        return delegate.inputViewShouldChangeText(inputView: self, with: text)
    }
}

extension MultiLineInputField {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let placeholderTopOffset: CGFloat = 7.5
        let placeholderInset: CGFloat = 3.0
        let verticalInset: CGFloat = 16.0
        let horizontalInset: CGFloat = 16.0
        let itemOffset: CGFloat = 12.0
    }
}
