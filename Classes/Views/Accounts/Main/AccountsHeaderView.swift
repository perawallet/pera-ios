//
//  AccountsHeaderView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 29.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol AccountsHeaderViewDelegate: class {
    
    func accountsHeaderViewDidTapSendButton(_ accountsHeaderView: AccountsHeaderView)
    func accountsHeaderViewDidTapReceiveButton(_ accountsHeaderView: AccountsHeaderView)
}

class AccountsHeaderView: BaseView {

    private struct LayoutConstants: AdaptiveLayoutConstants {
        let algosAvailableLabelTopInset: CGFloat = 54.0 * verticalScale
        let algosAvailableLabelLeadingInset: CGFloat = 53.0
        let horizontalInset: CGFloat = 25.0
        let amountLabelTopInset: CGFloat = -12.0 * verticalScale
        let amountLabelLeadingInset: CGFloat = 8.0
        let verticalInset: CGFloat = 25.0 * verticalScale
        let buttonHorizontalInset: CGFloat = 20.0
        let buttonInnerSpacing: CGFloat = 15.0
        let historyLabelTopInset: CGFloat = 36.0 * verticalScale
        let historyLabelBottomInset: CGFloat = 7.0 * verticalScale
        let buttonHeight: CGFloat = 56.0 * verticalScale
    }
    
    private let layout = Layout<LayoutConstants>()
    
    // MARK: Components
    
    private(set) lazy var algosAvailableLabel: UILabel = {
        UILabel()
            .withAlignment(.left)
            .withTextColor(SharedColors.black)
            .withFont(UIFont.font(.montserrat, withWeight: .bold(size: 12.0)))
            .withText("accounts-algos-available-title".localized)
    }()
    
    private(set) lazy var algosImageView = UIImageView(image: img("algo-icon-accounts"))
    
    private(set) lazy var algosAmountLabel: UILabel = {
        UILabel()
            .withAlignment(.center)
            .withTextColor(SharedColors.black)
            .withFont(UIFont.font(.opensans, withWeight: .bold(size: 40.0)))
            .withText("0.000000")
    }()
    
    private(set) lazy var sendButton: UIButton = {
        UIButton(type: .custom)
            .withTitleColor(SharedColors.black)
            .withTitle("title-send".localized)
            .withBackgroundImage(img("bg-blue-small"))
            .withAlignment(.center)
            .withFont(UIFont.font(.montserrat, withWeight: .bold(size: 12.0)))
    }()
    
    private(set) lazy var receiveButton: UIButton = {
        UIButton(type: .custom)
            .withTitleColor(SharedColors.black)
            .withTitle("title-receive".localized)
            .withBackgroundImage(img("bg-green-small"))
            .withAlignment(.center)
            .withFont(UIFont.font(.montserrat, withWeight: .bold(size: 12.0)))
    }()
    
    private lazy var historyLabel: UILabel = {
        UILabel()
            .withAlignment(.left)
            .withTextColor(SharedColors.darkGray)
            .withFont(UIFont.font(.opensans, withWeight: .semiBold(size: 12.0)))
            .withText("accounts-transaction-history-title".localized)
    }()
    
    weak var delegate: AccountsHeaderViewDelegate?
    
    // MARK: Setup
    
    override func setListeners() {
        sendButton.addTarget(self, action: #selector(notifyDelegateToSendButtonTapped), for: .touchUpInside)
        receiveButton.addTarget(self, action: #selector(notifyDelegateToReceiveButtonTapped), for: .touchUpInside)
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupAlgosAvailableLabelLayout()
        setupAlgosImageViewLayout()
        setupAmountLabelLayout()
        setupSendButtonLayout()
        setupReceiveButtonLayout()
        setupHistoryLabelLayout()
    }
    
    private func setupAlgosAvailableLabelLayout() {
        addSubview(algosAvailableLabel)
        
        algosAvailableLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.algosAvailableLabelLeadingInset)
            make.top.lessThanOrEqualToSuperview().inset(layout.current.algosAvailableLabelTopInset)
        }
    }
    
    private func setupAlgosImageViewLayout() {
        addSubview(algosImageView)
        
        algosImageView.snp.makeConstraints { make in
            make.top.equalTo(algosAvailableLabel.snp.bottom).offset(layout.current.verticalInset)
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupAmountLabelLayout() {
        addSubview(algosAmountLabel)
        
        algosAmountLabel.snp.makeConstraints { make in
            make.top.equalTo(algosImageView.snp.top).inset(layout.current.amountLabelTopInset)
            make.leading.equalTo(algosImageView.snp.trailing).offset(layout.current.amountLabelLeadingInset)
            make.trailing.lessThanOrEqualToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupSendButtonLayout() {
        addSubview(sendButton)
        
        sendButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.buttonHorizontalInset)
            make.top.equalTo(algosAmountLabel.snp.bottom).offset(layout.current.verticalInset)
            make.height.equalTo(layout.current.buttonHeight)
        }
    }
    
    private func setupReceiveButtonLayout() {
        addSubview(receiveButton)
        
        receiveButton.snp.makeConstraints { make in
            make.leading.equalTo(sendButton.snp.trailing).offset(layout.current.buttonInnerSpacing)
            make.width.height.equalTo(sendButton)
            make.trailing.equalToSuperview().inset(layout.current.buttonHorizontalInset)
            make.top.equalTo(sendButton)
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
        delegate?.accountsHeaderViewDidTapSendButton(self)
    }
    
    @objc
    private func notifyDelegateToReceiveButtonTapped() {
        delegate?.accountsHeaderViewDidTapReceiveButton(self)
    }
}
