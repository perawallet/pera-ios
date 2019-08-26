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
        let trailingInset: CGFloat = 15.0
        let feeViewHeight: CGFloat = 90.0
        let buttonHorizontalInset: CGFloat = MainButton.Constants.horizontalInset
        let bottomInset: CGFloat = 18.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    weak var previewViewDelegate: SendAlgosPreviewViewDelegate?
    
    // MARK: Components
    
    private(set) lazy var feeInformationView: DetailedInformationView = {
        let feeInformationView = DetailedInformationView(mode: .algos)
        feeInformationView.explanationLabel.text = "send-algos-fee".localized
        feeInformationView.algosAmountView.amountLabel.font = UIFont.font(.overpass, withWeight: .semiBold(size: 14.0))
        return feeInformationView
    }()
    
    private(set) lazy var sendButton = MainButton(title: "title-send".localized)
    
    // MARK: Setup
    
    override func configureAppearance() {
        super.configureAppearance()
        
        algosInputView.inputTextField.isEnabled = false
        algosInputView.maxButton.isHidden = true
        transactionReceiverView.passphraseInputView.inputTextView.isEditable = false
        transactionReceiverView.actionMode = .none
        accountSelectionView.isUserInteractionEnabled = false
    }
    
    override func setListeners() {
        sendButton.addTarget(self, action: #selector(notifyDelegateToSendButtonTapped), for: .touchUpInside)
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        super.prepareLayout()
        
        updateAccountSelectionViewLayout()
        setupFeeInformationViewLayout()
        setupSendButtonLayout()
    }
    
    private func updateAccountSelectionViewLayout() {
        accountSelectionView.rightInputAccessoryButton.snp.updateConstraints { make in
            make.trailing.equalToSuperview().inset(layout.current.trailingInset)
        }
    }
    
    private func setupFeeInformationViewLayout() {
        addSubview(feeInformationView)
        
        feeInformationView.snp.makeConstraints { make in
            make.top.equalTo(transactionReceiverView.snp.bottom)
            make.height.equalTo(layout.current.feeViewHeight)
            make.leading.trailing.equalToSuperview()
        }
    }
    
    private func setupSendButtonLayout() {
        previewButton.removeFromSuperview()
        
        addSubview(sendButton)
        
        sendButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(layout.current.bottomInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.buttonHorizontalInset)
        }
    }
    
    // MARK: Actions
    
    @objc
    private func notifyDelegateToSendButtonTapped() {
        previewViewDelegate?.sendAlgosPreviewViewDidTapSendButton(self)
    }
}
