//
//  SendTransactionView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 9.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class SendTransactionView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var transactionDelegate: SendTransactionViewDelegate?
    
    private lazy var containerView = UIView()
    
    private lazy var accountInformationView = TransactionAccountNameView()
    
    private lazy var assetInformationView = TransactionAssetView()
    
    private lazy var amountInformationView = TransactionAmountInformationView()
    
    private lazy var receiverInformationView = TransactionContactInformationView()
    
    private lazy var feeInformationView = TransactionAmountInformationView()
    
    private lazy var noteInformationView = TransactionTitleInformationView()
    
    private lazy var sendButton = MainButton(title: "title-send".localized)
    
    override func configureAppearance() {
        super.configureAppearance()
        containerView.backgroundColor = Colors.Background.secondary
        containerView.layer.cornerRadius = 12.0
        if !isDarkModeDisplay {
            containerView.applySmallShadow()
        }
        amountInformationView.backgroundColor = Colors.Background.secondary
        receiverInformationView.backgroundColor = Colors.Background.secondary
        feeInformationView.backgroundColor = Colors.Background.secondary
        noteInformationView.backgroundColor = Colors.Background.secondary
        amountInformationView.setTitle("transaction-detail-amount".localized)
        receiverInformationView.setTitle("transaction-detail-to".localized)
        receiverInformationView.removeContactAction()
        feeInformationView.setTitle("transaction-detail-fee".localized)
        noteInformationView.setTitle("transaction-detail-note".localized)
    }
    
    override func setListeners() {
        sendButton.addTarget(self, action: #selector(notifyDelegateToSendTransaction), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        setupContainerViewLayout()
        setupAccountInformationViewLayout()
        setupAssetInformationViewLayout()
        setupAmountInformationViewLayout()
        setupReceiverInformationViewLayout()
        setupFeeInformationViewLayout()
        setupNoteInformationViewLayout()
        setupSendButtonLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !isDarkModeDisplay {
            containerView.updateShadowLayoutWhenViewDidLayoutSubviews()
        }
    }
    
    @available(iOS 12.0, *)
    override func preferredUserInterfaceStyleDidChange(to userInterfaceStyle: UIUserInterfaceStyle) {
        if userInterfaceStyle == .dark {
            containerView.removeShadows()
        } else {
            containerView.applySmallShadow()
        }
    }
}

extension SendTransactionView {
    private func setupContainerViewLayout() {
        addSubview(containerView)
        
        containerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalToSuperview().inset(layout.current.topInset)
        }
    }
    
    private func setupAccountInformationViewLayout() {
        containerView.addSubview(accountInformationView)
        
        accountInformationView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview().inset(layout.current.itemVerticalInset)
        }
    }
    
    private func setupAssetInformationViewLayout() {
        containerView.addSubview(assetInformationView)
        
        assetInformationView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(accountInformationView.snp.bottom)
        }
    }
    
    private func setupAmountInformationViewLayout() {
        containerView.addSubview(amountInformationView)
        
        amountInformationView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(assetInformationView.snp.bottom)
        }
    }
    
    private func setupReceiverInformationViewLayout() {
        containerView.addSubview(receiverInformationView)
        
        receiverInformationView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(amountInformationView.snp.bottom)
        }
    }
    
    private func setupFeeInformationViewLayout() {
        containerView.addSubview(feeInformationView)
        
        feeInformationView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(receiverInformationView.snp.bottom)
            make.bottom.equalToSuperview().inset(layout.current.itemVerticalInset).priority(.low)
        }
    }
    
    private func setupNoteInformationViewLayout() {
        containerView.addSubview(noteInformationView)
        
        noteInformationView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(feeInformationView.snp.bottom)
            make.bottom.equalToSuperview().inset(layout.current.itemVerticalInset)
        }
    }
    
    private func setupSendButtonLayout() {
        addSubview(sendButton)
        
        sendButton.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.bottom).offset(layout.current.verticalInset)
            make.centerX.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview().inset(layout.current.verticalInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
}

extension SendTransactionView {
    @objc
    private func notifyDelegateToSendTransaction() {
        transactionDelegate?.sendTransactionViewDidTapSendButton(self)
    }
}

extension SendTransactionView {
    func setAccountImage(_ image: UIImage?) {
        accountInformationView.setAccountImage(image)
    }
    
    func setAccountName(_ name: String?) {
        accountInformationView.setAccountName(name)
    }
    
    func setAssetName(for assetDetail: AssetDetail) {
        assetInformationView.setAssetName(for: assetDetail)
    }
    
    func removeVerifiedAsset() {
        assetInformationView.removeVerifiedAsset()
    }
    
    func setAssetName(_ name: String?) {
        assetInformationView.setAssetName(name)
    }
    
    func setAssetId(_ id: String?) {
        assetInformationView.setAssetId(id)
    }
    
    func setAssetUnitName(_ unitName: String?) {
        assetInformationView.setAssetCode(unitName)
    }
    
    func setAmountInformationViewMode(_ mode: TransactionAmountView.Mode) {
        amountInformationView.setAmountViewMode(mode)
    }
    
    func setReceiverAsContact(_ contact: Contact) {
        receiverInformationView.setContact(contact)
    }
    
    func setReceiverName(_ name: String) {
        receiverInformationView.setName(name)
    }
    
    func removeReceiverImage() {
        receiverInformationView.removeContactImage()
    }
    
    func setFeeInformationViewMode(_ mode: TransactionAmountView.Mode) {
        feeInformationView.setAmountViewMode(mode)
    }
    
    func setTransactionNote(_ note: String) {
        noteInformationView.setDetail(note)
        noteInformationView.setSeparatorView(hidden: true)
    }
    
    func removeTransactionNote() {
        noteInformationView.removeFromSuperview()
        feeInformationView.setSeparatorHidden(true)
    }
    
    func setButtonTitle(_ title: String) {
        sendButton.setTitle(title, for: .normal)
    }
    
    func removeAssetName() {
        assetInformationView.removeAssetName()
    }
    
    func removeAssetUnitName() {
        assetInformationView.removeAssetUnitName()
    }
    
    func removeAssetId() {
        assetInformationView.removeAssetId()
    }
    
    func setAssetNameAlignment(_ alignment: NSTextAlignment) {
        assetInformationView.setAssetAlignment(alignment)
    }
}

extension SendTransactionView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let topInset: CGFloat = 12.0
        let itemVerticalInset: CGFloat = 8.0
        let verticalInset: CGFloat = 28.0
        let horizontalInset: CGFloat = 20.0
    }
}

protocol SendTransactionViewDelegate: class {
    func sendTransactionViewDidTapSendButton(_ sendTransactionView: SendTransactionView)
}
