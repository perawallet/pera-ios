//
//  FeedbackView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 22.08.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol FeedbackViewDelegate: class {
    func feedbackViewDidTriggerCategorySelection(_ feedbackView: FeedbackView)
    func feedbackViewDidTapSendButton(_ feedbackView: FeedbackView)
}

class FeedbackView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let pickerInitialHeight: CGFloat = 0.0
        let topInset: CGFloat = 10.0
        let noteViewHeight: CGFloat = 232.0
        let verticalInset: CGFloat = 15.0
        let buttonHorizontalInset: CGFloat = MainButton.Constants.horizontalInset
        let bottomInset: CGFloat = 57.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: FeedbackViewDelegate?
    
    private lazy var categorySelectionGestureRecognizer = UITapGestureRecognizer(
        target: self,
        action: #selector(didTriggerCategorySelection(tapGestureRecognizer:))
    )
    
    // MARK: Components
    
    private(set) lazy var categorySelectionView: AccountSelectionView = {
        let categorySelectionView = AccountSelectionView()
        categorySelectionView.backgroundColor = .clear
        categorySelectionView.containerView.isUserInteractionEnabled = true
        categorySelectionView.explanationLabel.text = "feedback-title-category".localized
        categorySelectionView.detailLabel.text = "feedback-subtitle-category".localized
        categorySelectionView.detailLabel.textColor = SharedColors.softGray
        categorySelectionView.rightInputAccessoryButton.setImage(img("icon-picker-selection-down"), for: .normal)
        return categorySelectionView
    }()
    
    private(set) lazy var categoryPickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.isHidden = true
        return pickerView
    }()
    
    private(set) lazy var noteInputView: MultiLineInputField = {
        let passPhraseInputView = MultiLineInputField()
        passPhraseInputView.explanationLabel.text = "feedback-title-note".localized
        passPhraseInputView.placeholderLabel.text = "feedback-subtitle-note".localized
        passPhraseInputView.nextButtonMode = .next
        passPhraseInputView.inputTextView.autocorrectionType = .no
        passPhraseInputView.inputTextView.autocapitalizationType = .none
        return passPhraseInputView
    }()
    
    private(set) lazy var emailInputView: SingleLineInputField = {
        let accountNameInputView = SingleLineInputField()
        accountNameInputView.explanationLabel.text = "feedback-title-email".localized
        accountNameInputView.inputTextField.attributedPlaceholder = NSAttributedString(
            string: "feedback-subtitle-email".localized,
            attributes: [NSAttributedString.Key.foregroundColor: SharedColors.softGray,
                         NSAttributedString.Key.font: UIFont.font(.overpass, withWeight: .semiBold(size: 14.0))]
        )
        accountNameInputView.nextButtonMode = .submit
        accountNameInputView.inputTextField.autocorrectionType = .no
        accountNameInputView.inputTextField.autocapitalizationType = .none
        accountNameInputView.inputTextField.keyboardType = .emailAddress
        return accountNameInputView
    }()
    
    private lazy var sendButton: MainButton = {
        let button = MainButton(title: "title-send".localized)
        return button
    }()
    
    // MARK: Setup
    
    override func setListeners() {
        sendButton.addTarget(self, action: #selector(notifyDelegateToSendButtonTapped), for: .touchUpInside)
        categorySelectionView.containerView.addGestureRecognizer(categorySelectionGestureRecognizer)
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupCategorySelectionViewLayout()
        setupCategoryPickerViewLayout()
        setupNoteInputViewLayout()
        setupEmailInputViewLayout()
        setupSendButtonLayout()
    }
    
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
    
    private func setupNoteInputViewLayout() {
        addSubview(noteInputView)
        
        noteInputView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(categoryPickerView.snp.bottom).offset(layout.current.verticalInset)
            make.height.equalTo(layout.current.noteViewHeight)
        }
    }
    
    private func setupEmailInputViewLayout() {
        addSubview(emailInputView)
        
        emailInputView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(noteInputView.snp.bottom).offset(layout.current.verticalInset)
        }
    }
    
    private func setupSendButtonLayout() {
        addSubview(sendButton)
        
        sendButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.buttonHorizontalInset)
            make.top.greaterThanOrEqualTo(emailInputView.snp.bottom).offset(layout.current.verticalInset)
            make.bottom.equalToSuperview().inset(layout.current.bottomInset)
        }
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
    
    // MARK: Actions
    
    @objc
    private func didTriggerCategorySelection(tapGestureRecognizer: UITapGestureRecognizer) {
        delegate?.feedbackViewDidTriggerCategorySelection(self)
    }
    
    @objc
    private func notifyDelegateToSendButtonTapped() {
        delegate?.feedbackViewDidTapSendButton(self)
    }
}
