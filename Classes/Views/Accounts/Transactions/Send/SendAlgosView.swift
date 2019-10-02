//
//  SendAlgosView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 8.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol SendAlgosViewDelegate: class {
    func sendAlgosViewDidTapAccountSelectionView(_ sendAlgosView: SendAlgosView)
    func sendAlgosViewDidTapPreviewButton(_ sendAlgosView: SendAlgosView)
    func sendAlgosViewDidTapAddressButton(_ sendAlgosView: SendAlgosView)
    func sendAlgosViewDidTapMyAccountsButton(_ sendAlgosView: SendAlgosView)
    func sendAlgosViewDidTapContactsButton(_ sendAlgosView: SendAlgosView)
    func sendAlgosViewDidTapScanQRButton(_ sendAlgosView: SendAlgosView)
    func sendAlgosViewDidTapMaxButton(_ sendAlgosView: SendAlgosView)
}

class SendAlgosView: BaseView {

    private struct LayoutConstants: AdaptiveLayoutConstants {
        let topInset: CGFloat = 20.0 * verticalScale
        let horizontalInset: CGFloat = 25.0
        let buttonInset: CGFloat = 15.0
        let bottomInset: CGFloat = 18.0
        let accountSelectionHeight: CGFloat = 88.0
        let accountSelectionTopInset: CGFloat = 5.0
        let receiverViewHeight: CGFloat = 115.0
        let buttonMinimumInset: CGFloat = 18.0 * verticalScale
        let buttonHorizontalInset: CGFloat = MainButton.Constants.horizontalInset
    }
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: SendAlgosViewDelegate?
    
    // MARK: Components
    
    private(set) lazy var algosInputView: AlgosInputView = {
        let view = AlgosInputView(shouldHandleMaxButtonStates: true)
        view.maxButton.isHidden = false
        return view
    }()
    
    private(set) lazy var accountSelectionView: AccountSelectionView = {
        let accountSelectionView = AccountSelectionView()
        return accountSelectionView
    }()
    
    private(set) lazy var transactionReceiverView: TransactionReceiverView = {
        let view = TransactionReceiverView()
        return view
    }()
    
    private(set) lazy var previewButton: MainButton = {
        MainButton(title: "title-preview".localized)
    }()
    
    // MARK: Setup
    
    override func setListeners() {
        transactionReceiverView.delegate = self
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(notifyDelegateToAccountSelectionViewTapped))
        
        accountSelectionView.isUserInteractionEnabled = true
        accountSelectionView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func linkInteractors() {
        algosInputView.delegate = self
        previewButton.addTarget(self, action: #selector(notifyDelegateToPreviewButtonTapped), for: .touchUpInside)
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupAlgosInputViewLayout()
        setupAccountSelectionViewLayout()
        setupTransactionReceiverViewLayout()
        setupPreviewButtonLayout()
    }
    
    private func setupAlgosInputViewLayout() {
        addSubview(algosInputView)
        
        algosInputView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.topInset)
            make.leading.trailing.equalToSuperview()
        }
    }
    
    private func setupAccountSelectionViewLayout() {
        addSubview(accountSelectionView)
        
        accountSelectionView.snp.makeConstraints { make in
            make.top.equalTo(algosInputView.snp.bottom).offset(layout.current.accountSelectionTopInset)
            make.height.equalTo(layout.current.accountSelectionHeight)
            make.leading.trailing.equalToSuperview()
        }
    }
    
    private func setupTransactionReceiverViewLayout() {
        addSubview(transactionReceiverView)
        
        transactionReceiverView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(layout.current.receiverViewHeight)
            make.top.equalTo(accountSelectionView.snp.bottom)
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
    
    // MARK: Actions
    
    @objc
    private func notifyDelegateToPreviewButtonTapped() {
        delegate?.sendAlgosViewDidTapPreviewButton(self)
    }
    
    @objc
    private func notifyDelegateToAccountSelectionViewTapped() {
        delegate?.sendAlgosViewDidTapAccountSelectionView(self)
    }
}

// MARK: TransactionReceiverViewDelegate

extension SendAlgosView: TransactionReceiverViewDelegate {
    
    func transactionReceiverViewDidTapAddressButton(_ transactionReceiverView: TransactionReceiverView) {
        delegate?.sendAlgosViewDidTapAddressButton(self)
    }
    
    func transactionReceiverViewDidTapMyAccountsButton(_ transactionReceiverView: TransactionReceiverView) {
        delegate?.sendAlgosViewDidTapMyAccountsButton(self)
    }
    
    func transactionReceiverViewDidTapContactsButton(_ transactionReceiverView: TransactionReceiverView) {
        delegate?.sendAlgosViewDidTapContactsButton(self)
    }
    
    func transactionReceiverViewDidTapScanQRButton(_ transactionReceiverView: TransactionReceiverView) {
        delegate?.sendAlgosViewDidTapScanQRButton(self)
    }
}

// MARK: AlgosInputViewDelegate

extension SendAlgosView: AlgosInputViewDelegate {
    func algosInputViewDidTapMaxButton(_ algosInputView: AlgosInputView) {
        delegate?.sendAlgosViewDidTapMaxButton(self)
    }
}
