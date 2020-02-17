//
//  RequestTransactionPreviewView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 11.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol RequestTransactionPreviewViewDelegate: class {
    func requestTransactionPreviewViewDidTapPreviewButton(_ requestTransactionPreviewView: RequestTransactionPreviewView)
}

class RequestTransactionPreviewView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: RequestTransactionPreviewViewDelegate?
    
    private var inputFieldFraction: Int
    
    private(set) lazy var transactionParticipantView: TransactionParticipantView = {
        let transactionParticipantView = TransactionParticipantView()
        transactionParticipantView.accountSelectionView.leftExplanationLabel.text = "send-algos-to".localized
        return transactionParticipantView
    }()
    
    private(set) lazy var amountInputView = AssetInputView(inputFieldFraction: inputFieldFraction)
    
    private(set) lazy var previewButton = MainButton(title: "title-preview".localized)
    
    init(inputFieldFraction: Int) {
        self.inputFieldFraction = inputFieldFraction
        super.init(frame: .zero)
    }
    
    override func linkInteractors() {
        previewButton.addTarget(self, action: #selector(notifyDelegateToPreviewButtonTapped), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        setupTransactionParticipantViewLayout()
        setupAmountInputViewLayout()
        setupPreviewButtonLayout()
    }
}

extension RequestTransactionPreviewView {
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
    
    private func setupPreviewButtonLayout() {
        addSubview(previewButton)
        
        previewButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.buttonHorizontalInset)
            make.top.greaterThanOrEqualTo(amountInputView.snp.bottom).offset(layout.current.buttonMinimumInset)
            make.bottom.equalToSuperview().inset(layout.current.bottomInset)
        }
    }
}

extension RequestTransactionPreviewView {
    @objc
    private func notifyDelegateToPreviewButtonTapped() {
        delegate?.requestTransactionPreviewViewDidTapPreviewButton(self)
    }
}

extension RequestTransactionPreviewView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let topInset: CGFloat = 10.0
        let bottomInset: CGFloat = 18.0
        let buttonMinimumInset: CGFloat = 18.0
        let buttonHorizontalInset: CGFloat = MainButton.Constants.horizontalInset
    }
}
