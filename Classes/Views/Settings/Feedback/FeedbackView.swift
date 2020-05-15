//
//  FeedbackView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 22.08.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class FeedbackView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: FeedbackViewDelegate?
    
    private lazy var categorySelectionGestureRecognizer = UITapGestureRecognizer(
        target: self,
        action: #selector(didTriggerCategorySelection(tapGestureRecognizer:))
    )
    
    private(set) lazy var categorySelectionView: SelectionView = {
        let categorySelectionView = SelectionView()
        categorySelectionView.backgroundColor = .clear
        categorySelectionView.containerView.isUserInteractionEnabled = true
        categorySelectionView.leftExplanationLabel.text = "feedback-title-category".localized
        categorySelectionView.detailLabel.text = "feedback-subtitle-category".localized
        categorySelectionView.rightInputAccessoryButton.setImage(img("icon-picker-selection-down"), for: .normal)
        categorySelectionView.layer.cornerRadius = 12.0
        return categorySelectionView
    }()
    
    private(set) lazy var categoryPickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.isHidden = true
        return pickerView
    }()
    
    private(set) lazy var emailInputView: SingleLineInputField = {
        let accountNameInputView = SingleLineInputField()
        accountNameInputView.explanationLabel.text = "feedback-title-email".localized
        accountNameInputView.placeholderText = "feedback-subtitle-email".localized
        accountNameInputView.nextButtonMode = .next
        accountNameInputView.inputTextField.autocorrectionType = .no
        accountNameInputView.inputTextField.autocapitalizationType = .none
        accountNameInputView.inputTextField.keyboardType = .emailAddress
        return accountNameInputView
    }()
    
    private(set) lazy var noteInputView: MultiLineInputField = {
        let noteInputView = MultiLineInputField()
        noteInputView.explanationLabel.text = "feedback-title-note".localized
        noteInputView.placeholderLabel.text = "feedback-subtitle-note".localized
        noteInputView.nextButtonMode = .submit
        noteInputView.inputTextView.autocorrectionType = .no
        noteInputView.inputTextView.autocapitalizationType = .none
        return noteInputView
    }()
    
    private lazy var sendButton = MainButton(title: "title-send".localized)
    
    override func configureAppearance() {
        super.configureAppearance()
        categorySelectionView.applySmallShadow()
    }
    
    override func linkInteractors() {
        emailInputView.delegate = self
    }
    
    override func setListeners() {
        sendButton.addTarget(self, action: #selector(notifyDelegateToSendButtonTapped), for: .touchUpInside)
        categorySelectionView.containerView.addGestureRecognizer(categorySelectionGestureRecognizer)
    }
    
    override func prepareLayout() {
        setupCategorySelectionViewLayout()
        setupCategoryPickerViewLayout()
        setupEmailInputViewLayout()
        setupNoteInputViewLayout()
        setupSendButtonLayout()
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if !categorySelectionView.frame.contains(point) &&
            !categoryPickerView.frame.contains(point) &&
            !sendButton.frame.contains(point) &&
            !categoryPickerView.isHidden {
            delegate?.feedbackViewDidTriggerCategorySelection(self)
        }
        
        return super.hitTest(point, with: event)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        categorySelectionView.setShadowFrames()
    }
}

extension FeedbackView {
    @objc
    private func didTriggerCategorySelection(tapGestureRecognizer: UITapGestureRecognizer) {
        delegate?.feedbackViewDidTriggerCategorySelection(self)
    }
    
    @objc
    private func notifyDelegateToSendButtonTapped() {
        delegate?.feedbackViewDidTapSendButton(self)
    }
}

extension FeedbackView {
    private func setupCategorySelectionViewLayout() {
        addSubview(categorySelectionView)
        
        categorySelectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview().inset(layout.current.topInset)
        }
    }
    
    private func setupCategoryPickerViewLayout() {
        addSubview(categoryPickerView)
        
        categoryPickerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(categorySelectionView.snp.bottom)
            make.height.equalTo(layout.current.pickerInitialHeight)
        }
    }
    
    private func setupEmailInputViewLayout() {
        addSubview(emailInputView)
        
        emailInputView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(categoryPickerView.snp.bottom).offset(layout.current.verticalInset)
        }
    }
    
    private func setupNoteInputViewLayout() {
        addSubview(noteInputView)
        
        noteInputView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(emailInputView.snp.bottom).offset(layout.current.verticalInset)
            make.height.equalTo(layout.current.noteViewHeight)
        }
    }
    
    private func setupSendButtonLayout() {
        addSubview(sendButton)
        
        sendButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.buttonHorizontalInset)
            make.top.equalTo(noteInputView.snp.bottom).offset(layout.current.buttonTopInset)
            make.bottom.lessThanOrEqualToSuperview().inset(layout.current.bottomInset)
        }
    }
}

extension FeedbackView: InputViewDelegate {
    func inputViewDidReturn(inputView: BaseInputView) {
        delegate?.feedbackView(self, inputDidReturn: inputView)
    }
}

extension FeedbackView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let pickerInitialHeight: CGFloat = 0.0
        let topInset: CGFloat = 12.0
        let noteViewHeight: CGFloat = 136.0
        let verticalInset: CGFloat = 20.0
        let buttonHorizontalInset: CGFloat = 20.0
        let bottomInset: CGFloat = 30.0
        let buttonTopInset: CGFloat = 28.0
    }
}

protocol FeedbackViewDelegate: class {
    func feedbackViewDidTriggerCategorySelection(_ feedbackView: FeedbackView)
    func feedbackViewDidTapSendButton(_ feedbackView: FeedbackView)
    func feedbackView(_ feedbackView: FeedbackView, inputDidReturn inputView: BaseInputView)
}
