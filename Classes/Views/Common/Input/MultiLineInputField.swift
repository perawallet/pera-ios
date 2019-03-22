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
        let placeholderTopOffset: CGFloat = 9.0
        let placeholderLeftInset: CGFloat = 4.0
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
        textView.font = UIFont.systemFont(ofSize: 16.0, weight: .semibold)
        textView.textColor = rgb(0.04, 0.05, 0.07)
        textView.tintColor = rgb(0.04, 0.05, 0.07)
        textView.backgroundColor = .clear
        textView.isSelectable = true
        textView.isEditable = true
        textView.textContainer.heightTracksTextView = true
        textView.isScrollEnabled = false
        return textView
    }()
    
    private(set) lazy var placeholderLabel: UILabel = {
        UILabel()
            .withFont(UIFont.systemFont(ofSize: 14.0, weight: .semibold))
            .withLine(.contained)
            .withTextColor(rgb( 0.67, 0.67, 0.72))
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
            make.edges.equalToSuperview()
        }
    }
    
    private func setupPlaceholderLabelLayout() {
        contentView.addSubview(placeholderLabel)
        
        placeholderLabel.snp.makeConstraints { make in
            make.top.equalTo(inputTextView.textInputView).offset(layout.current.placeholderTopOffset)
            make.leading.equalToSuperview().inset(layout.current.placeholderLeftInset)
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
