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
        let containerViewInset: CGFloat = 10.0
        let availableTitleInset: CGFloat = 15.0
        let topInset: CGFloat = 24.0
        let horizontalInset: CGFloat = 15.0
        let amountLabelLeadingInset: CGFloat = 6.0
        let amountLabelTrailingInset: CGFloat = 110.0
        let historyLabelTopInset: CGFloat = 20.0
        let buttonSize: CGFloat = 38.0
        let buttonTopInset: CGFloat = 13.0
        let amountLabelTopInset: CGFloat = -6.0
        let verticalInset: CGFloat = 25.0
        let buttonMinimumInset: CGFloat = 3.0
        let historyLabelBottomInset: CGFloat = 10.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    private enum Colors {
        static let borderColor = rgb(0.94, 0.94, 0.94)
    }
    
    // MARK: Components
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 1.0
        view.layer.borderColor = Colors.borderColor.cgColor
        view.layer.cornerRadius = 4.0
        view.backgroundColor = .white
        return view
    }()
    
    private(set) lazy var algosImageView = UIImageView(image: img("icon-algo-black"))
    
    private(set) lazy var algosAmountLabel: UILabel = {
        UILabel()
            .withAlignment(.center)
            .withTextColor(SharedColors.black)
            .withFont(UIFont.font(.overpass, withWeight: .semiBold(size: 22.0)))
            .withText("0.000000")
    }()
    
    private(set) lazy var sendButton: UIButton = {
        UIButton(type: .custom)
            .withBackgroundImage(img("bg-send-small"))
            .withImage(img("icon-arrow-up"))
            .withAlignment(.center)
    }()
    
    private(set) lazy var receiveButton: UIButton = {
        UIButton(type: .custom)
            .withBackgroundImage(img("bg-receive-small"))
            .withImage(img("icon-arrow-down"))
            .withAlignment(.center)
    }()
    
    private lazy var historyLabel: UILabel = {
        UILabel()
            .withAlignment(.center)
            .withTextColor(SharedColors.softGray)
            .withFont(UIFont.font(.avenir, withWeight: .medium(size: 12.0)))
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
        setupContainerViewLayout()
        setupAlgosImageViewLayout()
        setupAmountLabelLayout()
        setupReceiveButtonLayout()
        setupSendButtonLayout()
        setupHistoryLabelLayout()
    }
    
    private func setupContainerViewLayout() {
        addSubview(containerView)
        
        containerView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(layout.current.containerViewInset)
        }
    }
    
    private func setupAlgosImageViewLayout() {
        containerView.addSubview(algosImageView)
        
        algosImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(layout.current.topInset)
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupAmountLabelLayout() {
        containerView.addSubview(algosAmountLabel)
        
        algosAmountLabel.snp.makeConstraints { make in
            make.top.equalTo(algosImageView.snp.top).inset(layout.current.amountLabelTopInset)
            make.leading.equalTo(algosImageView.snp.trailing).offset(layout.current.amountLabelLeadingInset)
            make.trailing.lessThanOrEqualToSuperview().inset(layout.current.amountLabelTrailingInset)
        }
    }
    
    private func setupReceiveButtonLayout() {
        containerView.addSubview(receiveButton)
        
        receiveButton.layer.cornerRadius = layout.current.buttonSize / 2
        
        receiveButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.bottom.equalToSuperview().inset(layout.current.buttonTopInset)
            make.width.height.equalTo(layout.current.buttonSize)
        }
    }
    
    private func setupSendButtonLayout() {
        containerView.addSubview(sendButton)
        
        sendButton.layer.cornerRadius = layout.current.buttonSize / 2
        
        sendButton.snp.makeConstraints { make in
            make.width.height.equalTo(receiveButton)
            make.top.bottom.equalTo(receiveButton)
            make.trailing.equalTo(receiveButton.snp.leading).offset(-layout.current.horizontalInset)
            make.leading.greaterThanOrEqualTo(algosAmountLabel.snp.trailing).offset(layout.current.buttonMinimumInset)
        }
    }
    
    private func setupHistoryLabelLayout() {
        addSubview(historyLabel)

        historyLabel.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.bottom).offset(layout.current.historyLabelTopInset)
            make.bottom.equalToSuperview().inset(layout.current.historyLabelBottomInset)
            make.centerX.equalToSuperview()
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
