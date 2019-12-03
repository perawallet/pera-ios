//
//  SendTransactionViewb.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 9.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol SendTransactionViewDelegate: class {
    func sendTransactionViewDidTapSendButton(_ sendTransactionView: SendTransactionView)
}

class SendTransactionView: SendTransactionPreviewView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var transactionDelegate: SendTransactionViewDelegate?
    
    private(set) lazy var feeInformationView: DetailedInformationView = {
        let feeInformationView = DetailedInformationView(mode: .algos)
        feeInformationView.explanationLabel.text = "send-algos-fee".localized
        feeInformationView.containerView.backgroundColor = rgb(0.91, 0.91, 0.92)
        feeInformationView.algosAmountView.amountLabel.font = UIFont.font(.overpass, withWeight: .bold(size: 15.0))
        return feeInformationView
    }()
    
    private(set) lazy var sendButton = MainButton(title: "title-send".localized)
    
    override func configureAppearance() {
        super.configureAppearance()
        transactionReceiverView.passphraseInputView.inputTextView.isEditable = false
        transactionReceiverView.actionMode = .none
        transactionReceiverView.passphraseInputView.contentView.backgroundColor = rgb(0.91, 0.91, 0.92)
        amountInputView.maxButton.isHidden = true
        amountInputView.set(enabled: false)
    }
    
    override func setListeners() {
        sendButton.addTarget(self, action: #selector(notifyDelegateToSendButtonTapped), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        setupFeeInformationViewLayout()
        setupSendButtonLayout()
    }
}

extension SendTransactionView {
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
}

extension SendTransactionView {
    @objc
    private func notifyDelegateToSendButtonTapped() {
        transactionDelegate?.sendTransactionViewDidTapSendButton(self)
    }
}

extension SendTransactionView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let topInset: CGFloat = 20.0
        let trailingInset: CGFloat = 15.0
        let feeViewHeight: CGFloat = 90.0
        let buttonHorizontalInset: CGFloat = MainButton.Constants.horizontalInset
        let bottomInset: CGFloat = 18.0
    }
}
