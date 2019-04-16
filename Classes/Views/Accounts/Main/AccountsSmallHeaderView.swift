//
//  AccountsSmallHeaderView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 16.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol AccountsSmallHeaderViewDelegate: class {
    
    func accountsSmallHeaderViewDidTapSendButton(_ accountsHeaderView: AccountsSmallHeaderView)
    func accountsSmallHeaderViewDidTapReceiveButton(_ accountsHeaderView: AccountsSmallHeaderView)
}

class AccountsSmallHeaderView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let topInset: CGFloat = 45.0
        let horizontalInset: CGFloat = 25.0
        let amountLabelLeadingInset: CGFloat = 3.0
        let amountLabelTrailingInset: CGFloat = 115.0
        let historyLabelTopInset: CGFloat = 33.0
        let buttonSize: CGFloat = 38.0
        let buttonTopInset: CGFloat = 40.0
        let amountLabelTopInset: CGFloat = -7.0
        let verticalInset: CGFloat = 25.0
        let buttonHorizontalInset: CGFloat = 20.0
        let buttonInnerSpacing: CGFloat = -16.0
        let buttonMinimumInset: CGFloat = 5.0
        let historyLabelBottomInset: CGFloat = 7.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    // MARK: Components
    
    private(set) lazy var algosImageView = UIImageView(image: img("algo-icon-account-medium"))
    
    private(set) lazy var algosAmountLabel: UILabel = {
        UILabel()
            .withAlignment(.center)
            .withTextColor(SharedColors.black)
            .withFont(UIFont.font(.opensans, withWeight: .bold(size: 24.0)))
            .withText("0.00")
    }()
    
    private(set) lazy var sendButton: UIButton = {
        UIButton(type: .custom)
            .withBackgroundImage(img("bg-send-small"))
            .withBackgroundColor(.white)
            .withImage(img("icon-arrow-up"))
            .withAlignment(.center)
    }()
    
    private(set) lazy var receiveButton: UIButton = {
        UIButton(type: .custom)
            .withBackgroundImage(img("bg-receive-small"))
            .withBackgroundColor(.white)
            .withImage(img("icon-arrow-down"))
            .withAlignment(.center)
    }()
    
    private lazy var historyLabel: UILabel = {
        UILabel()
            .withAlignment(.left)
            .withTextColor(SharedColors.darkGray)
            .withFont(UIFont.font(.opensans, withWeight: .semiBold(size: 12.0)))
            .withText("accounts-transaction-history-title".localized)
    }()
    
    weak var delegate: AccountsSmallHeaderViewDelegate?
    
    // MARK: Setup
    
    override func setListeners() {
        sendButton.addTarget(self, action: #selector(notifyDelegateToSendButtonTapped), for: .touchUpInside)
        receiveButton.addTarget(self, action: #selector(notifyDelegateToReceiveButtonTapped), for: .touchUpInside)
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupAlgosImageViewLayout()
        setupAmountLabelLayout()
        setupReceiveButtonLayout()
        setupSendButtonLayout()
        setupHistoryLabelLayout()
    }
    
    private func setupAlgosImageViewLayout() {
        addSubview(algosImageView)
        
        algosImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(layout.current.topInset)
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupAmountLabelLayout() {
        addSubview(algosAmountLabel)
        
        algosAmountLabel.snp.makeConstraints { make in
            make.top.equalTo(algosImageView.snp.top).inset(layout.current.amountLabelTopInset)
            make.leading.equalTo(algosImageView.snp.trailing).offset(layout.current.amountLabelLeadingInset)
            make.trailing.lessThanOrEqualToSuperview().inset(layout.current.amountLabelTrailingInset)
        }
    }
    
    private func setupReceiveButtonLayout() {
        addSubview(receiveButton)
        
        receiveButton.layer.cornerRadius = layout.current.buttonSize / 2
        
        receiveButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(layout.current.buttonHorizontalInset)
            make.top.equalToSuperview().inset(layout.current.buttonTopInset)
            make.width.height.equalTo(layout.current.buttonSize)
        }
    }
    
    private func setupSendButtonLayout() {
        addSubview(sendButton)
        
        sendButton.layer.cornerRadius = layout.current.buttonSize / 2
        
        sendButton.snp.makeConstraints { make in
            make.width.height.equalTo(receiveButton)
            make.top.equalTo(receiveButton)
            make.trailing.equalTo(receiveButton.snp.leading).offset(layout.current.buttonInnerSpacing)
            make.leading.greaterThanOrEqualTo(algosAmountLabel.snp.trailing).offset(layout.current.buttonMinimumInset)
        }
    }
    
    private func setupHistoryLabelLayout() {
        addSubview(historyLabel)
        
        historyLabel.snp.makeConstraints { make in
            make.top.equalTo(sendButton.snp.bottom).offset(layout.current.historyLabelTopInset)
            make.leading.equalToSuperview().inset(layout.current.buttonHorizontalInset)
            make.bottom.equalToSuperview().inset(layout.current.historyLabelBottomInset)
        }
    }
    
    // MARK: Actions
    
    @objc
    private func notifyDelegateToSendButtonTapped() {
        delegate?.accountsSmallHeaderViewDidTapSendButton(self)
    }
    
    @objc
    private func notifyDelegateToReceiveButtonTapped() {
        delegate?.accountsSmallHeaderViewDidTapReceiveButton(self)
    }
}
