//
//  FeedbackViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 22.08.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

enum FeedbackType: String, CaseIterable {
    case feature = "Feature Request"
    case general = "General"
    case bug = "Bug"
}

class FeedbackViewController: BaseScrollViewController {
    
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
    }
    
    override func linkInteractors() {
        super.linkInteractors()
        
        feedbackView.delegate = self
        feedbackView.categoryPickerView.delegate = self
        feedbackView.categoryPickerView.dataSource = self
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
    func feedbackViewDidTapSendButton(_ feedbackView: FeedbackView) {
        
    }
}

// MARK: UIPickerViewDataSource

extension FeedbackViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return FeedbackType.allCases.count
    }
}

// MARK: UIPickerViewDelegate

extension FeedbackViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return FeedbackType.allCases[row].rawValue
    }
}
