//
//  SendAlgosPreviewView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 9.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol SendAlgosPreviewViewDelegate: class {
    
    func sendAlgosPreviewViewDidTapSendButton(_ sendAlgosView: SendAlgosView)
}

class SendAlgosPreviewView: SendAlgosView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let topInset: CGFloat = 20.0
        let bottomInset: CGFloat = 18.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    weak var previewViewDelegate: SendAlgosPreviewViewDelegate?
    
    private(set) lazy var sendButton = MainButton(title: "title-send".localized)
    
    private(set) lazy var feeInformationView: SingleLineInputField = {
        let selectAccountView = SingleLineInputField(displaysRightInputAccessoryButton: true)
        selectAccountView.explanationLabel.text = "send-algos-fee".localized
        selectAccountView.rightInputAccessoryButton.setImage(img("icon-info"), for: .normal)
        selectAccountView.inputTextField.isEnabled = false
        selectAccountView.inputTextField.textColor = SharedColors.black
        selectAccountView.inputTextField.tintColor = SharedColors.black
        return selectAccountView
    }()
    
    override func configureAppearance() {
        super.configureAppearance()
        
        algosInputView.inputTextField.isEnabled = false
        accountSelectionView.isUserInteractionEnabled = false
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        
        setupFeeInformationViewLayout()
        setupSendButtonLayout()
    }
    
    private func setupFeeInformationViewLayout() {
        addSubview(feeInformationView)
        
        feeInformationView.snp.makeConstraints { make in
            make.top.equalTo(transactionReceiverView.snp.bottom).offset(layout.current.topInset)
            make.leading.trailing.equalToSuperview()
        }
    }
    
    private func setupSendButtonLayout() {
        previewButton.removeFromSuperview()
        
        addSubview(sendButton)
        
        sendButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(layout.current.bottomInset)
        }
    }
}
