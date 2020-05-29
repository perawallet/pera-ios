//
//  SendTransactionPreviewView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 8.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class SendTransactionPreviewView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: SendTransactionPreviewViewDelegate?
    
    var inputFieldFraction: Int
    
    private lazy var assetSelectionView: SelectionView = {
        let view = SelectionView()
        view.isHidden = true
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private(set) lazy var transactionAccountInformationView = TransactionAccountInformationView()
    
    private(set) lazy var amountInputView: AssetInputView = {
        let view = AssetInputView(inputFieldFraction: inputFieldFraction, shouldHandleMaxButtonStates: true)
        view.setMaxButtonHidden(false)
        return view
    }()
    
    private(set) lazy var transactionReceiverView = TransactionReceiverView()

    private(set) lazy var noteInputView: MultiLineInputField = {
        let noteInputView = MultiLineInputField()
        noteInputView.explanationLabel.text = "send-enter-note-title".localized
        noteInputView.placeholderLabel.text = "send-enter-note-placeholder".localized
        noteInputView.nextButtonMode = .submit
        noteInputView.inputTextView.autocorrectionType = .no
        noteInputView.inputTextView.autocapitalizationType = .none
        noteInputView.inputTextView.textContainer.heightTracksTextView = true
        noteInputView.inputTextView.isScrollEnabled = false
        return noteInputView
    }()
    
    private(set) lazy var previewButton: MainButton = {
        if accountType == .ledger {
            return MainButton(title: "title-preview-and-sign-with-ledger-title".localized)
        } else {
            return MainButton(title: "title-preview".localized)
        }
    }()
    
    private let accountType: AccountType
    
    init(accountType: AccountType = .standard, inputFieldFraction: Int = algosFraction) {
        self.accountType = accountType
        self.inputFieldFraction = inputFieldFraction
        super.init(frame: .zero)
    }
    
    override func setListeners() {
        transactionReceiverView.delegate = self
        transactionAccountInformationView.delegate = self
    }
    
    override func linkInteractors() {
        amountInputView.delegate = self
        assetSelectionView.addTarget(self, action: #selector(notifyDelegateToSelectAsset), for: .touchUpInside)
        previewButton.addTarget(self, action: #selector(notifyDelegateToPreviewTransaction), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        setupAssetSelectionViewLayout()
        setupTransactionAccountInformationViewLayout()
        setupAmountInputViewLayout()
        setupTransactionReceiverViewLayout()
        setupNoteInputViewLayout()
        setupPreviewButtonLayout()
    }
}

extension SendTransactionPreviewView {
    private func setupAssetSelectionViewLayout() {
        addSubview(assetSelectionView)
        
        assetSelectionView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.topInset)
            make.leading.trailing.equalToSuperview()
        }
    }
    
    private func setupTransactionAccountInformationViewLayout() {
        addSubview(transactionAccountInformationView)
        
        transactionAccountInformationView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.topInset)
            make.leading.trailing.equalToSuperview()
        }
    }
    
    private func setupAmountInputViewLayout() {
        addSubview(amountInputView)
        
        amountInputView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.amountFieldTopInset)
            make.leading.trailing.equalToSuperview()
        }
    }
    
    private func setupTransactionReceiverViewLayout() {
        addSubview(transactionReceiverView)
        
        transactionReceiverView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(amountInputView.snp.bottom).offset(layout.current.verticalInset)
        }
    }
    
    private func setupNoteInputViewLayout() {
        addSubview(noteInputView)
        
        noteInputView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(transactionReceiverView.snp.bottom).offset(layout.current.verticalInset)
        }
    }
    
    private func setupPreviewButtonLayout() {
        addSubview(previewButton)
        
        previewButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.buttonHorizontalInset)
            make.top.equalTo(noteInputView.snp.bottom).offset(layout.current.buttonVerticalInset)
            make.bottom.lessThanOrEqualToSuperview().inset(layout.current.buttonVerticalInset + safeAreaBottom)
        }
    }
}

extension SendTransactionPreviewView {
    @objc
    private func notifyDelegateToPreviewTransaction() {
        delegate?.sendTransactionPreviewViewDidTapPreviewButton(self)
    }
    
    @objc
    private func notifyDelegateToSelectAsset() {
        delegate?.sendTransactionPreviewViewDidTapAccountSelectionView(self)
    }
}

extension SendTransactionPreviewView: TransactionReceiverViewDelegate {
    func transactionReceiverViewDidTapCloseButton(_ transactionReceiverView: TransactionReceiverView) {
        delegate?.sendTransactionPreviewViewDidTapCloseButton(self)
    }
    
    func transactionReceiverViewDidTapAccountsButton(_ transactionReceiverView: TransactionReceiverView) {
        delegate?.sendTransactionPreviewViewDidTapAccountsButton(self)
    }
    
    func transactionReceiverViewDidTapContactsButton(_ transactionReceiverView: TransactionReceiverView) {
        delegate?.sendTransactionPreviewViewDidTapContactsButton(self)
    }
    
    func transactionReceiverViewDidTapAddressButton(_ transactionReceiverView: TransactionReceiverView) {
        delegate?.sendTransactionPreviewViewDidTapAddressButton(self)
    }
    
    func transactionReceiverViewDidTapScanQRButton(_ transactionReceiverView: TransactionReceiverView) {
        delegate?.sendTransactionPreviewViewDidTapScanQRButton(self)
    }
}

extension SendTransactionPreviewView: AssetInputViewDelegate {
    func assetInputViewDidTapMaxButton(_ assetInputView: AssetInputView) {
        delegate?.sendTransactionPreviewViewDidTapMaxButton(self)
    }
}

extension SendTransactionPreviewView: TransactionAccountInformationViewDelegate {
    func transactionAccountInformationViewDidTapRemoveButton(_ transactionAccountInformationView: TransactionAccountInformationView) {
        delegate?.sendTransactionPreviewViewDidTapRemoveButton(self)
    }
}

extension SendTransactionPreviewView {
    func setAssetSelectionHidden(_ hidden: Bool) {
        transactionAccountInformationView.isHidden = !hidden
        assetSelectionView.isHidden = hidden
        assetSelectionView.isUserInteractionEnabled = !hidden
        
        amountInputView.snp.updateConstraints { make in
            if hidden {
                make.top.equalToSuperview().inset(layout.current.amountFieldTopInset)
            } else {
                make.top.equalToSuperview().inset(layout.current.amountFieldTopInsetToAssetSelection)
            }
        }
    }
}

extension SendTransactionPreviewView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let topInset: CGFloat = 12.0
        let verticalInset: CGFloat = 20.0
        let buttonHorizontalInset: CGFloat = 20.0
        let buttonVerticalInset: CGFloat = 20.0
        let amountFieldTopInset: CGFloat = 154.0
        let amountFieldTopInsetToAssetSelection: CGFloat = 108.0
    }
}

protocol SendTransactionPreviewViewDelegate: class {
    func sendTransactionPreviewViewDidTapPreviewButton(_ sendTransactionPreviewView: SendTransactionPreviewView)
    func sendTransactionPreviewViewDidTapCloseButton(_ sendTransactionPreviewView: SendTransactionPreviewView)
    func sendTransactionPreviewViewDidTapAddressButton(_ sendTransactionPreviewView: SendTransactionPreviewView)
    func sendTransactionPreviewViewDidTapAccountsButton(_ sendTransactionPreviewView: SendTransactionPreviewView)
    func sendTransactionPreviewViewDidTapContactsButton(_ sendTransactionPreviewView: SendTransactionPreviewView)
    func sendTransactionPreviewViewDidTapScanQRButton(_ sendTransactionPreviewView: SendTransactionPreviewView)
    func sendTransactionPreviewViewDidTapMaxButton(_ sendTransactionPreviewView: SendTransactionPreviewView)
    func sendTransactionPreviewViewDidTapAccountSelectionView(_ sendTransactionPreviewView: SendTransactionPreviewView)
    func sendTransactionPreviewViewDidTapRemoveButton(_ sendTransactionPreviewView: SendTransactionPreviewView)
}
