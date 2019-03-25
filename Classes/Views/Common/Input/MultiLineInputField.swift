//
//  MultiLineInputField.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 21.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class MultiLineInputField: BaseInputView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let placeholderTopOffset: CGFloat = 7.0
        let textViewLeadingInset: CGFloat = -3.0
    }
    
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
    
    // MARK: Components
    
    private(set) lazy var inputTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.font(.montserrat, withWeight: .semiBold(size: 13.0))
        textView.textColor = SharedColors.black
        textView.tintColor = SharedColors.black
        textView.backgroundColor = .clear
        textView.isSelectable = true
        textView.isEditable = true
        textView.textContainer.heightTracksTextView = true
        textView.isScrollEnabled = false
        return textView
    }()
    
    private(set) lazy var placeholderLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(.montserrat, withWeight: .semiBold(size: 14.0)))
            .withLine(.contained)
            .withTextColor(SharedColors.softGray)
    }()
    
    // MARK: Helpers
    
    var isEditing: Bool {
        return inputTextView.isFirstResponder
    }
    
    func beginEditing() {
        _ = inputTextView.becomeFirstResponder()
    }
    
    // MARK: Setup
    
    override func linkInteractors() {
        super.linkInteractors()
        
        inputTextView.delegate = self
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        super.prepareLayout()
        
        setupInputTextViewLayout()
        setupPlaceholderLabelLayout()
    }
    
    private func setupInputTextViewLayout() {
        contentView.addSubview(inputTextView)
        
        inputTextView.snp.makeConstraints { make in
            make.trailing.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().inset(layout.current.textViewLeadingInset)
        }
    }
    
    private func setupPlaceholderLabelLayout() {
        contentView.addSubview(placeholderLabel)
        
        placeholderLabel.snp.makeConstraints { make in
            make.top.equalTo(inputTextView.textInputView).offset(layout.current.placeholderTopOffset)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
    }
}

// MARK: UITextViewDelegate

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
}
