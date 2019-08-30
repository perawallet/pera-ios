//
//  FeedbackViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 22.08.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit
import SVProgressHUD
import Magpie

class FeedbackViewController: BaseScrollViewController {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let pickerRowHeight: CGFloat = 50.0
        let pickerOpenedHeight: CGFloat = 130.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    private var categories = [FeedbackCategory]()
    private var selectedCategory: FeedbackCategory? {
        didSet {
            if let selectedCategory = selectedCategory {
                self.feedbackView.categorySelectionView.detailLabel.text = selectedCategory.name
                self.feedbackView.categorySelectionView.detailLabel.textColor = SharedColors.black
            }
        }
    }
    
    private var keyboardController = KeyboardController()
    
    // MARK: Components
    
    private lazy var feedbackView: FeedbackView = {
        let view = FeedbackView()
        return view
    }()
    
    // MARK: Initialization
    
    override init(configuration: ViewControllerConfiguration) {
        super.init(configuration: configuration)
        
        hidesBottomBarWhenPushed = true
    }
    
    // MARK: Setup
    
    override func configureAppearance() {
        super.configureAppearance()
        
        title = "feedback-title".localized
        
        fetchFeedbackCategories()
    }
    
    private func fetchFeedbackCategories() {
        api?.getFeedbackCategories { response in
            switch response {
            case let .success(result):
                self.categories = result
                self.feedbackView.categoryPickerView.reloadAllComponents()
            case let .failure(error):
                print(error)
            }
        }
    }
    
    override func linkInteractors() {
        super.linkInteractors()
        
        feedbackView.delegate = self
        feedbackView.categoryPickerView.delegate = self
        feedbackView.categoryPickerView.dataSource = self
        keyboardController.dataSource = self
    }
    
    override func setListeners() {
        super.setListeners()
        
        keyboardController.beginTracking()
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        super.prepareLayout()
        
        setupFeedbackViewLayout()
    }
    
    private func setupFeedbackViewLayout() {
        contentView.addSubview(feedbackView)
        
        feedbackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

// MARK: FeedbackViewDelegate

extension FeedbackViewController: FeedbackViewDelegate {
    func feedbackViewDidTriggerCategorySelection(_ feedbackView: FeedbackView) {
        if feedbackView.categoryPickerView.isHidden {
            feedbackView.categoryPickerView.isHidden = false
            feedbackView.categoryPickerView.snp.updateConstraints { make in
                make.height.equalTo(layout.current.pickerOpenedHeight)
            }
        } else {
            feedbackView.categoryPickerView.isHidden = true
            feedbackView.categoryPickerView.snp.updateConstraints { make in
                make.height.equalTo(0.0)
            }
            
            let currentRow = feedbackView.categoryPickerView.selectedRow(inComponent: 0)
            
            if currentRow >= categories.count {
                return
            }
            
            selectedCategory = categories[currentRow]
        }
    }
    
    func feedbackViewDidTapSendButton(_ feedbackView: FeedbackView) {
        sendFeedback()
    }
    
    func feedbackView(_ feedbackView: FeedbackView, inputDidReturn inputView: BaseInputView) {
        if inputView == feedbackView.emailInputView {
            sendFeedback()
        }
    }
}

// MARK: UIPickerViewDataSource

extension FeedbackViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return layout.current.pickerRowHeight
    }
}

// MARK: UIPickerViewDelegate

extension FeedbackViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row >= categories.count {
            return
        }
        
        selectedCategory = categories[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row >= categories.count {
            return nil
        }
        return categories[row].name
    }
}

// MARK: Actions

extension FeedbackViewController {
    private func sendFeedback() {
        guard let selectedCategory = selectedCategory else {
            displaySimpleAlertWith(title: "feedback-empty-title".localized, message: "feedback-empty-category-message".localized)
            return
        }
        
        guard let feedbackNote = feedbackView.noteInputView.inputTextView.text,
            !feedbackNote.isEmpty else {
            displaySimpleAlertWith(title: "feedback-empty-title".localized, message: "feedback-empty-note-message".localized)
            return
        }
        
        var feedbackDraft = FeedbackDraft(note: feedbackNote, category: selectedCategory.slug, email: nil)
        
        if let email = feedbackView.emailInputView.inputTextField.text,
            !email.isEmpty {
            feedbackDraft.email = email
        }
        
        SVProgressHUD.show(withStatus: "title-loading".localized)
        
        api?.sendFeedback(with: feedbackDraft) { response in
            switch response {
            case .success:
                SVProgressHUD.showSuccess(withStatus: "title-done-lowercased".localized)
                SVProgressHUD.dismiss()
                
                self.displaySuccessAlert()
            case let .failure(error):
                SVProgressHUD.dismiss()
                self.parseAndDisplayErrorAlert(error)

            }
        }
    }
    
    private func displaySuccessAlert() {
        let configurator = AlertViewConfigurator(
            title: "feedback-success-title".localized,
            image: img("feedback-success-icon"),
            explanation: "",
            actionTitle: "title-close".localized,
            actionImage: img("bg-main-button")
        ) {
            self.popScreen()
        }
        
        let alertViewController = AlertViewController(mode: .default, alertConfigurator: configurator, configuration: configuration)
        alertViewController.modalPresentationStyle = .overCurrentContext
        alertViewController.modalTransitionStyle = .crossDissolve
        present(alertViewController, animated: true, completion: nil)
    }
    
    private func parseAndDisplayErrorAlert(_ error: Error) {
        switch error {
        case let .badRequest(errorData):
            guard let data = errorData else {
                self.displaySimpleAlertWith(title: "feedback-error-title".localized, message: "feedback-error-message".localized)
                return
            }
            
            let decodedError = try? AlgorandError.decoded(from: data)
            self.displaySimpleAlertWith(
                title: "feedback-error-title".localized,
                message: decodedError?.message ?? "feedback-error-message".localized
            )
            return
        default:
            self.displaySimpleAlertWith(title: "feedback-error-title".localized, message: "feedback-error-message".localized)
        }
    }
}

// MARK: KeyboardControllerDataSource

extension FeedbackViewController: KeyboardControllerDataSource {
    
    func bottomInsetWhenKeyboardPresented(for keyboardController: KeyboardController) -> CGFloat {
        return 15.0
    }
    
    func firstResponder(for keyboardController: KeyboardController) -> UIView? {
        return feedbackView.emailInputView
    }
    
    func containerView(for keyboardController: KeyboardController) -> UIView {
        return contentView
    }
    
    func bottomInsetWhenKeyboardDismissed(for keyboardController: KeyboardController) -> CGFloat {
        return 15.0
    }
}
