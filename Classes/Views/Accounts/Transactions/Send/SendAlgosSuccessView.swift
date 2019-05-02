//
//  SendAlgosSuccessView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 9.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit
import Lottie

protocol SendAlgosSuccessViewDelegate: class {
    
    func sendAlgosSuccessViewDidTapDoneButton(_ sendAlgosSuccessView: SendAlgosSuccessView)
    func sendAlgosSuccessViewDidTapSendMoreButton(_ sendAlgosSuccessView: SendAlgosSuccessView)
    func sendAlgosSuccessViewDidTapAddContactButton(_ sendAlgosSuccessView: SendAlgosSuccessView)
}

class SendAlgosSuccessView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let imageViewInset: CGFloat = 30.0
        let imageViewSize: CGFloat = 150.0
        let animationViewSize: CGFloat = 55.0
        let titleLabelInset: CGFloat = 15.0
        let verticalInset: CGFloat = 20.0
        let buttonCenterOffset: CGFloat = 7.5
        let buttonMinimumInset: CGFloat = 10.0
        let separatorHeight: CGFloat = 1.0
        let bottomInset: CGFloat = 10.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    private enum Colors {
        static let separatorColor = rgba(0.67, 0.67, 0.72, 0.31)
    }
    
    weak var delegate: SendAlgosSuccessViewDelegate?
    
    // MARK: Components
    
    private(set) lazy var animationBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = layout.current.imageViewSize / 2
        return view
    }()
    
    private(set) lazy var successAnimationView: AnimationView = {
        let successAnimationView = AnimationView()
        successAnimationView.contentMode = .scaleAspectFit
        let animation = Animation.named("SuccessAnimation")
        successAnimationView.animation = animation
        return successAnimationView
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
            .withFont(UIFont.font(.montserrat, withWeight: .bold(size: 12.0)))
    }()
    
    private(set) lazy var sendMoreButton: UIButton = {
        UIButton(type: .custom)
            .withTitleColor(SharedColors.black)
            .withTitle("send-algos-more".localized)
            .withBackgroundImage(img("bg-blue-small"))
            .withAlignment(.center)
            .withFont(UIFont.font(.montserrat, withWeight: .bold(size: 12.0)))
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.separatorColor
        return view
    }()
    
    private(set) lazy var amountView: DetailedInformationView = {
        let amountView = DetailedInformationView(mode: .algos)
        amountView.explanationLabel.text = "send-algos-amount".localized
        return amountView
    }()
    
    private(set) lazy var feeView: DetailedInformationView = {
        let feeView = DetailedInformationView(mode: .algos)
        feeView.explanationLabel.text = "send-algos-fee".localized
        return feeView
    }()
    
    private(set) lazy var accountView: DetailedInformationView = {
        let accountView = DetailedInformationView()
        accountView.explanationLabel.text = "send-algos-from".localized
        accountView.detailLabel.text = "send-algos-select".localized
        return accountView
    }()

    private(set) lazy var transactionReceiverView: TransactionReceiverView = {
        let view = TransactionReceiverView()
        view.receiverContactView.qrDisplayButton.isHidden = true
        view.qrButton.setImage(img("icon-contact-add"), for: .normal)
        view.qrButton.setBackgroundImage(nil, for: .normal)
        return view
    }()
    
    private(set) lazy var transactionIdView: DetailedInformationView = {
        let transactionIdView = DetailedInformationView()
        transactionIdView.explanationLabel.text = "send-algos-transaction-id".localized
        transactionIdView.detailLabel.text = "send-algos-select".localized
        return transactionIdView
    }()
    
    // MARK: Setup
    
    override func setListeners() {
        doneButton.addTarget(self, action: #selector(notifyDelegateToDoneButtonTapped), for: .touchUpInside)
        sendMoreButton.addTarget(self, action: #selector(notifyDelegateToSendMoreButtonTapped), for: .touchUpInside)
        
        transactionReceiverView.qrButton.addTarget(self, action: #selector(notifyDelegateToAddContactButtonTapped), for: .touchUpInside)
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupAnimationBackgroundViewLayout()
        setupSuccessAnimationViewLayout()
        setupTitleLabelLayout()
        setupDoneButtonLayout()
        setupSendMoreButtonLayout()
        setupSeparatorViewLayout()
        setupAmountViewLayout()
        setupFeeViewLayout()
        setupAccountViewLayout()
        setupTransactionReceiverViewLayout()
        setupTransactionIdViewLayout()
    }
    
    private func setupAnimationBackgroundViewLayout() {
        addSubview(animationBackgroundView)
        
        animationBackgroundView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(layout.current.imageViewInset)
            make.width.height.equalTo(layout.current.imageViewSize)
        }
    }
    
    private func setupSuccessAnimationViewLayout() {
        animationBackgroundView.addSubview(successAnimationView)
        
        successAnimationView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(layout.current.animationViewSize)
        }
    }
    
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(animationBackgroundView.snp.bottom).offset(layout.current.titleLabelInset)
            make.centerX.equalToSuperview()
        }
    }
    
    private func setupDoneButtonLayout() {
        addSubview(doneButton)
        
        doneButton.snp.makeConstraints { make in
            make.trailing.equalTo(snp.centerX).inset(-layout.current.buttonCenterOffset)
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.verticalInset)
            make.leading.greaterThanOrEqualToSuperview().inset(layout.current.buttonMinimumInset)
        }
    }
    
    private func setupSendMoreButtonLayout() {
        addSubview(sendMoreButton)
        
        sendMoreButton.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.verticalInset)
            make.leading.equalTo(snp.centerX).offset(layout.current.buttonCenterOffset)
            make.trailing.lessThanOrEqualToSuperview().inset(layout.current.buttonMinimumInset)
            make.width.equalTo(doneButton)
        }
    }
    
    private func setupSeparatorViewLayout() {
        addSubview(separatorView)
        
        separatorView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(doneButton.snp.bottom).offset(layout.current.verticalInset)
            make.height.equalTo(layout.current.separatorHeight)
        }
    }
    
    private func setupAmountViewLayout() {
        addSubview(amountView)
        
        amountView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalTo(separatorView.snp.bottom)
            make.height.equalTo(88.0)
            make.width.equalTo(UIScreen.main.bounds.width / 2)
        }
    }
    
    private func setupFeeViewLayout() {
        addSubview(feeView)
        
        feeView.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.top.equalTo(separatorView.snp.bottom)
            make.height.equalTo(88.0)
            make.width.equalTo(UIScreen.main.bounds.width / 2)
        }
    }
    
    private func setupAccountViewLayout() {
        addSubview(accountView)
        
        accountView.snp.makeConstraints { make in
            make.top.equalTo(amountView.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }
    }
    
    private func setupTransactionReceiverViewLayout() {
        addSubview(transactionReceiverView)
        
        transactionReceiverView.snp.makeConstraints { make in
            make.top.equalTo(accountView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.greaterThanOrEqualTo(110.0)
        }
    }
    
    private func setupTransactionIdViewLayout() {
        addSubview(transactionIdView)
        
        transactionIdView.snp.makeConstraints { make in
            make.top.equalTo(transactionReceiverView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview().inset(layout.current.bottomInset)
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
    
    @objc
    private func notifyDelegateToAddContactButtonTapped() {
        delegate?.sendAlgosSuccessViewDidTapAddContactButton(self)
    }
}
