//
//  SendAlgosSuccessView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 9.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol SendAlgosSuccessViewDelegate: class {
    
    func sendAlgosSuccessViewDidTapDoneButton(_ sendAlgosSuccessView: SendAlgosSuccessView)
    func sendAlgosSuccessViewDidTapSendMoreButton(_ sendAlgosSuccessView: SendAlgosSuccessView)
}

class SendAlgosSuccessView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        
    }
    
    private let layout = Layout<LayoutConstants>()
    
    private enum Colors {
        static let separatorColor = rgba(0.67, 0.67, 0.72, 0.31)
    }
    
    weak var delegate: SendAlgosSuccessViewDelegate?
    
    // MARK: Components
    
    private lazy var successImageView: UIImageView = {
        let imageView = UIImageView(image: img("icon-transaction-success"))
        imageView.backgroundColor = .white
        imageView.layer.cornerRadius = 75.0
        imageView.contentMode = .center
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        UILabel()
            .withAlignment(.center)
            .withTextColor(SharedColors.black)
            .withFont(UIFont.font(.montserrat, withWeight: .bold(size: 30.0)))
            .withText("send-algos-sent-title".localized)
    }()
    
    private(set) lazy var doneButton: UIButton = {
        UIButton(type: .custom)
            .withTitleColor(SharedColors.black)
            .withTitle("title-done".localized)
            .withBackgroundImage(img("bg-dark-gray-small"))
            .withAlignment(.center)
            .withFont(UIFont.font(.montserrat, withWeight: .bold(size: 14.0)))
    }()
    
    private(set) lazy var sendMoreButton: UIButton = {
        UIButton(type: .custom)
            .withTitleColor(SharedColors.black)
            .withTitle("send-algos-more".localized)
            .withBackgroundImage(img("bg-blue-small"))
            .withAlignment(.center)
            .withFont(UIFont.font(.montserrat, withWeight: .bold(size: 14.0)))
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.separatorColor
        return view
    }()
    
    private(set) lazy var amountView: SingleLineInputField = {
        let amountView = SingleLineInputField()
        amountView.explanationLabel.text = "send-algos-amount".localized
        amountView.inputTextField.text = "send-algos-select".localized
        amountView.inputTextField.isEnabled = false
        amountView.inputTextField.textColor = SharedColors.black
        amountView.inputTextField.tintColor = SharedColors.black
        return amountView
    }()
    
    private(set) lazy var feeView: SingleLineInputField = {
        let feeView = SingleLineInputField()
        feeView.explanationLabel.text = "send-algos-fee".localized
        feeView.inputTextField.text = "send-algos-select".localized
        feeView.inputTextField.isEnabled = false
        feeView.inputTextField.textColor = SharedColors.black
        feeView.inputTextField.tintColor = SharedColors.black
        return feeView
    }()
    
    private(set) lazy var accountView: SingleLineInputField = {
        let accountView = SingleLineInputField()
        accountView.explanationLabel.text = "send-algos-from".localized
        accountView.inputTextField.text = "send-algos-select".localized
        accountView.inputTextField.isEnabled = false
        accountView.inputTextField.textColor = SharedColors.black
        accountView.inputTextField.tintColor = SharedColors.black
        return accountView
    }()
    
    private(set) lazy var receiverAccountView: SingleLineInputField = {
        let receiverAccountView = SingleLineInputField(displaysRightInputAccessoryButton: true)
        receiverAccountView.explanationLabel.text = "send-algos-to".localized
        receiverAccountView.inputTextField.text = "send-algos-select".localized
        receiverAccountView.rightInputAccessoryButton.setImage(img("icon-contacts"), for: .normal)
        receiverAccountView.inputTextField.isEnabled = false
        receiverAccountView.inputTextField.textColor = SharedColors.black
        receiverAccountView.inputTextField.tintColor = SharedColors.black
        return receiverAccountView
    }()
    
    private(set) lazy var transactionIdView: SingleLineInputField = {
        let transactionIdView = SingleLineInputField()
        transactionIdView.explanationLabel.text = "send-algos-transaction-id".localized
        transactionIdView.inputTextField.text = "send-algos-select".localized
        transactionIdView.inputTextField.isEnabled = false
        transactionIdView.inputTextField.textColor = SharedColors.black
        transactionIdView.inputTextField.tintColor = SharedColors.black
        return transactionIdView
    }()
    
    // MARK: Setup
    
    override func setListeners() {
        doneButton.addTarget(self, action: #selector(notifyDelegateToDoneButtonTapped), for: .touchUpInside)
        sendMoreButton.addTarget(self, action: #selector(notifyDelegateToSendMoreButtonTapped), for: .touchUpInside)
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupSuccessImageViewLayout()
        setupTitleLabelLayout()
        setupDoneButtonLayout()
        setupSendMoreButtonLayout()
        setupSeparatorViewLayout()
        setupAmountViewLayout()
        setupFeeViewLayout()
        setupAccountViewLayout()
        setupReceiverAccountViewLayout()
        setupTransactionIdViewLayout()
    }
    
    private func setupSuccessImageViewLayout() {
        addSubview(successImageView)
        
        successImageView.snp.makeConstraints { make in
            
        }
    }
    
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            
        }
    }
    
    private func setupDoneButtonLayout() {
        addSubview(doneButton)
        
        doneButton.snp.makeConstraints { make in
            
        }
    }
    
    private func setupSendMoreButtonLayout() {
        addSubview(sendMoreButton)
        
        sendMoreButton.snp.makeConstraints { make in
            
        }
    }
    
    private func setupSeparatorViewLayout() {
        addSubview(separatorView)
        
        separatorView.snp.makeConstraints { make in
            
        }
    }
    
    private func setupAmountViewLayout() {
        addSubview(amountView)
        
        amountView.snp.makeConstraints { make in
            
        }
    }
    
    private func setupFeeViewLayout() {
        addSubview(feeView)
        
        feeView.snp.makeConstraints { make in
            
        }
    }
    
    private func setupAccountViewLayout() {
        addSubview(accountView)
        
        accountView.snp.makeConstraints { make in
            
        }
    }
    
    private func setupReceiverAccountViewLayout() {
        addSubview(receiverAccountView)
        
        receiverAccountView.snp.makeConstraints { make in
            
        }
    }
    
    private func setupTransactionIdViewLayout() {
        addSubview(transactionIdView)
        
        transactionIdView.snp.makeConstraints { make in
            
        }
    }
    
    // MARK: Actions
    
    @objc
    private func notifyDelegateToDoneButtonTapped() {
        delegate?.sendAlgosSuccessViewDidTapDoneButton(self)
    }
    
    @objc
    private func notifyDelegateToSendMoreButtonTapped() {
        delegate?.sendAlgosSuccessViewDidTapSendMoreButton(self)
    }
}
