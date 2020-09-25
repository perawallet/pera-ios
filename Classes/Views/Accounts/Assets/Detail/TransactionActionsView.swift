//
//  TransactionActionsView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 24.09.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class TransactionActionsView: BaseView {
    
    weak var delegate: TransactionActionsViewDelegate?
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var sendButton: UIButton = {
        UIButton(type: .custom).withImage(img("img-send")).withAlignment(.center)
    }()
    
    private lazy var sendTitle: UILabel = {
        UILabel()
            .withLine(.single)
            .withAlignment(.center)
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
            .withTextColor(SharedColors.gray500)
            .withText("title-send".localized)
    }()
    
    private lazy var receiveButton: UIButton = {
        UIButton(type: .custom).withImage(img("img-receive")).withAlignment(.center)
    }()
    
    private lazy var receiveTitle: UILabel = {
        UILabel()
            .withLine(.single)
            .withAlignment(.center)
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
            .withTextColor(SharedColors.gray500)
            .withText("title-receive".localized)
    }()
    
    override func configureAppearance() {
        backgroundColor = SharedColors.secondaryBackground
    }
    
    override func setListeners() {
        sendButton.addTarget(self, action: #selector(notifyDelegateToSendTransaction), for: .touchUpInside)
        receiveButton.addTarget(self, action: #selector(notifyDelegateToRequestTransaction), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        setupSendButtonLayout()
        setupReceiveButtonLayout()
        setupSendTitleLayout()
        setupReceiveTitleLayout()
    }
}

extension TransactionActionsView {
    @objc
    private func notifyDelegateToSendTransaction() {
        delegate?.transactionActionsViewDidSendTransaction(self)
    }
    
    @objc
    private func notifyDelegateToRequestTransaction() {
        delegate?.transactionActionsViewDidRequestTransaction(self)
    }
}

extension TransactionActionsView {
    private func setupSendButtonLayout() {
        addSubview(sendButton)
        
        sendButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.buttonTopInset)
            make.centerX.equalToSuperview().offset(-layout.current.buttonCenterOffset)
            make.size.equalTo(layout.current.buttonSize)
        }
    }
    
    private func setupReceiveButtonLayout() {
        addSubview(receiveButton)
        
        receiveButton.snp.makeConstraints { make in
            make.top.equalTo(sendButton)
            make.centerX.equalToSuperview().offset(layout.current.buttonCenterOffset)
            make.size.equalTo(sendButton)
        }
    }
    
    private func setupSendTitleLayout() {
        addSubview(sendTitle)
        
        sendTitle.snp.makeConstraints { make in
            make.top.equalTo(sendButton.snp.bottom).offset(layout.current.titleTopInset)
            make.centerX.equalTo(sendButton)
        }
    }
    
    private func setupReceiveTitleLayout() {
        addSubview(receiveTitle)
        
        receiveTitle.snp.makeConstraints { make in
            make.top.equalTo(receiveButton.snp.bottom).offset(layout.current.titleTopInset)
            make.centerX.equalTo(receiveButton)
        }
    }
}

extension TransactionActionsView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let buttonTopInset: CGFloat = 16.0
        let buttonCenterOffset: CGFloat = 46.0
        let buttonSize = CGSize(width: 48.0, height: 48.0)
        let titleTopInset: CGFloat = 4.0
    }
}

protocol TransactionActionsViewDelegate: class {
    func transactionActionsViewDidRequestTransaction(_ transactionActionsView: TransactionActionsView)
    func transactionActionsViewDidSendTransaction(_ transactionActionsView: TransactionActionsView)
}
