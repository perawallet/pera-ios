//
//  SendTransactionPreviewView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 8.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol SendTransactionPreviewViewDelegate: class {
    func sendTransactionPreviewViewDidTapPreviewButton(_ sendTransactionPreviewView: SendTransactionPreviewView)
    func sendTransactionPreviewViewDidTapAddressButton(_ sendTransactionPreviewView: SendTransactionPreviewView)
    func sendTransactionPreviewViewDidTapMyAccountsButton(_ sendTransactionPreviewView: SendTransactionPreviewView)
    func sendTransactionPreviewViewDidTapContactsButton(_ sendTransactionPreviewView: SendTransactionPreviewView)
    func sendTransactionPreviewViewDidTapScanQRButton(_ sendTransactionPreviewView: SendTransactionPreviewView)
    func sendTransactionPreviewViewDidTapMaxButton(_ sendTransactionPreviewView: SendTransactionPreviewView)
    func sendTransactionPreviewViewDidTapAccountSelectionView(_ sendTransactionPreviewView: SendTransactionPreviewView)
}

class SendTransactionPreviewView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: SendTransactionPreviewViewDelegate?
    
    private(set) lazy var transactionParticipantView: TransactionParticipantView = {
        let transactionParticipantView = TransactionParticipantView()
        transactionParticipantView.accountSelectionView.explanationLabel.text = "send-algos-from".localized
        return transactionParticipantView
    }()
    
    private(set) lazy var amountInputView: AlgosInputView = {
        let view = AlgosInputView(shouldHandleMaxButtonStates: true)
        view.maxButton.isHidden = false
        return view
    }()
    
    private(set) lazy var transactionReceiverView: TransactionReceiverView = {
        let transactionReceiverView = TransactionReceiverView()
        transactionReceiverView.passphraseInputView.inputTextView.returnKeyType = .done
        return transactionReceiverView
    }()
    
    private(set) lazy var previewButton = MainButton(title: "title-preview".localized)
    
    override func setListeners() {
        transactionReceiverView.delegate = self
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(notifyDelegateToAccountSelectionViewTapped))
        transactionParticipantView.accountSelectionView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func linkInteractors() {
        amountInputView.delegate = self
        previewButton.addTarget(self, action: #selector(notifyDelegateToPreviewButtonTapped), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        setupTransactionParticipantViewLayout()
        setupAmountInputViewLayout()
        setupTransactionReceiverViewLayout()
        setupPreviewButtonLayout()
    }
}

extension SendTransactionPreviewView {
    private func setupTransactionParticipantViewLayout() {
        addSubview(transactionParticipantView)
        
        transactionParticipantView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }
    }
    
    private func setupAmountInputViewLayout() {
        addSubview(amountInputView)
        
        amountInputView.snp.makeConstraints { make in
            make.top.equalTo(transactionParticipantView.snp.bottom).offset(layout.current.topInset)
            make.leading.trailing.equalToSuperview()
        }
    }
    
    private func setupTransactionReceiverViewLayout() {
        addSubview(transactionReceiverView)
        
        transactionReceiverView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(layout.current.receiverViewHeight)
            make.top.equalTo(amountInputView.snp.bottom)
        }
    }
    
    private func setupPreviewButtonLayout() {
        addSubview(previewButton)
        
        previewButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.buttonHorizontalInset)
            make.top.greaterThanOrEqualTo(transactionReceiverView.snp.bottom).offset(layout.current.buttonMinimumInset)
            make.bottom.equalToSuperview().inset(layout.current.bottomInset)
        }
    }
}

extension SendTransactionPreviewView {
    @objc
    private func notifyDelegateToPreviewButtonTapped() {
        delegate?.sendTransactionPreviewViewDidTapPreviewButton(self)
    }
    
    @objc
    private func notifyDelegateToAccountSelectionViewTapped() {
        delegate?.sendTransactionPreviewViewDidTapAccountSelectionView(self)
    }
}

extension SendTransactionPreviewView: TransactionReceiverViewDelegate {
    
    func transactionReceiverViewDidTapAddressButton(_ transactionReceiverView: TransactionReceiverView) {
        delegate?.sendTransactionPreviewViewDidTapAddressButton(self)
    }
    
    func transactionReceiverViewDidTapMyAccountsButton(_ transactionReceiverView: TransactionReceiverView) {
        delegate?.sendTransactionPreviewViewDidTapMyAccountsButton(self)
    }
    
    func transactionReceiverViewDidTapContactsButton(_ transactionReceiverView: TransactionReceiverView) {
        delegate?.sendTransactionPreviewViewDidTapContactsButton(self)
    }
    
    func transactionReceiverViewDidTapScanQRButton(_ transactionReceiverView: TransactionReceiverView) {
        delegate?.sendTransactionPreviewViewDidTapScanQRButton(self)
    }
}

extension SendTransactionPreviewView: AlgosInputViewDelegate {
    func algosInputViewDidTapMaxButton(_ algosInputView: AlgosInputView) {
        delegate?.sendTransactionPreviewViewDidTapMaxButton(self)
    }
}

extension SendTransactionPreviewView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let topInset: CGFloat = 10.0
        let bottomInset: CGFloat = 18.0
        let receiverViewHeight: CGFloat = 115.0
        let buttonMinimumInset: CGFloat = 18.0 * verticalScale
        let buttonHorizontalInset: CGFloat = MainButton.Constants.horizontalInset
    }
}
