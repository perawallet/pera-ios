//
//  TransactionDetailView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 23.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol TransactionDetailViewDelegate: class {
    
    func transactionDetailViewDidTapAddContactButton(_ transactionDetailView: TransactionDetailView)
    func transactionDetailViewDidTapShowQRButton(_ transactionDetailView: TransactionDetailView)
}

class TransactionDetailView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let amountViewTopInset: CGFloat = 20.0
        let amountViewHeight: CGFloat = 85.0
        let horizontalInset: CGFloat = 25.0
        let amountViewBottomInset: CGFloat = 20.0
        let receiverViewHeight: CGFloat = 115.0
        let imageSize: CGFloat = 29.0
        let imageInset: CGFloat = 5.0
        let feeViewHeight: CGFloat = 88.0
        let feeViewOffset: CGFloat = 13.0
        let bottomInset: CGFloat = 10.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    private enum Colors {
        static let separatorColor = rgba(0.67, 0.67, 0.72, 0.31)
    }
    
    weak var delegate: TransactionDetailViewDelegate?
    
    // MARK: Components
    
    private(set) lazy var transactionStatusView: DetailedInformationView = {
        let transactionStatusView = DetailedInformationView(mode: .loader)
        transactionStatusView.explanationLabel.text = "transaction-detail-status".localized
        transactionStatusView.detailLabel.textColor = SharedColors.darkGray
        return transactionStatusView
    }()
    
    private(set) lazy var transactionAmountView: DetailedInformationView = {
        let view = DetailedInformationView(mode: .algos)
        view.explanationLabel.text = "transaction-detail-amount".localized
        return view
    }()
    
    private(set) lazy var userAccountView: DetailedInformationView = {
        let accountView = DetailedInformationView()
        accountView.explanationLabel.text = "send-algos-from".localized
        accountView.detailLabel.text = "send-algos-select".localized
        return accountView
    }()
    
    private(set) lazy var transactionOpponentView: TransactionReceiverView = {
        let view = TransactionReceiverView()
        view.actionMode = .contactAddition
        return view
    }()
    
    private(set) lazy var transactionIdView: DetailedInformationView = {
        let transactionIdView = DetailedInformationView()
        transactionIdView.explanationLabel.text = "send-algos-transaction-id".localized
        transactionIdView.detailLabel.text = "send-algos-select".localized
        return transactionIdView
    }()
    
    private(set) lazy var feeView: DetailedInformationView = {
        let feeView = DetailedInformationView(mode: .algos)
        feeView.explanationLabel.text = "send-algos-fee".localized
        feeView.algosAmountView.amountLabel.font = UIFont.font(.overpass, withWeight: .semiBold(size: 14.0))
        return feeView
    }()
    
    private(set) lazy var lastRoundView: DetailedInformationView = {
        let lastRoundView = DetailedInformationView()
        lastRoundView.explanationLabel.text = "transaction-detail-round".localized
        return lastRoundView
    }()
    
    private(set) lazy var rewardView: DetailedInformationView = {
        let rewardView = DetailedInformationView(mode: .algos)
        rewardView.isHidden = true
        rewardView.explanationLabel.text = "transaction-detail-reward".localized
        rewardView.algosAmountView.algoIconImageView.tintColor = SharedColors.purple
        rewardView.algosAmountView.amountLabel.textColor = SharedColors.purple
        return rewardView
    }()
    
    // MARK: Components
    
    private let transactionType: TransactionType
    
    init(transactionType: TransactionType) {
        self.transactionType = transactionType
        
        super.init(frame: .zero)
    }
    
    // MARK: Setup
    
    override func linkInteractors() {
        super.linkInteractors()
        
        transactionOpponentView.delegate = self
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupTransactionStatusViewLayout()
        setupTransactionAmountViewLayout()
        
        if transactionType == .received {
            setupTransactionOpponentViewLayout()
            setupUserAccountViewLayout()
        } else {
            setupUserAccountViewLayout()
            setupTransactionOpponentViewLayout()
        }

        setupTransactionIdViewLayout()
        setupFeeViewLayout()
        setupLastRoundViewLayout()
        setupRewardViewLayout()
    }
    
    private func setupTransactionStatusViewLayout() {
        addSubview(transactionStatusView)
        
        transactionStatusView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(layout.current.amountViewHeight)
            make.top.equalToSuperview().inset(layout.current.amountViewTopInset)
        }
    }
    
    private func setupTransactionAmountViewLayout() {
        addSubview(transactionAmountView)
        
        transactionAmountView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(layout.current.amountViewHeight)
            make.top.equalTo(transactionStatusView.snp.bottom)
        }
    }
    
    private func setupUserAccountViewLayout() {
        addSubview(userAccountView)
        
        userAccountView.snp.makeConstraints { make in
            if transactionType == .received {
                make.top.equalTo(transactionOpponentView.snp.bottom)
            } else {
                make.top.equalTo(transactionAmountView.snp.bottom)
            }
            
            make.leading.trailing.equalToSuperview()
        }
    }
    
    private func setupTransactionOpponentViewLayout() {
        addSubview(transactionOpponentView)
        
        transactionOpponentView.snp.makeConstraints { make in
            if transactionType == .received {
                make.top.equalTo(transactionAmountView.snp.bottom)
            } else {
                make.top.equalTo(userAccountView.snp.bottom)
            }
            
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(layout.current.receiverViewHeight)
        }
    }
    
    private func setupTransactionIdViewLayout() {
        addSubview(transactionIdView)
        
        transactionIdView.snp.makeConstraints { make in
            if transactionType == .received {
                make.top.equalTo(userAccountView.snp.bottom)
            } else {
                make.top.equalTo(transactionOpponentView.snp.bottom)
            }
            
            make.leading.trailing.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview().inset(layout.current.bottomInset)
        }
    }
    
    private func setupFeeViewLayout() {
        addSubview(feeView)
        
        feeView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalTo(transactionIdView.snp.bottom)
            make.height.equalTo(layout.current.feeViewHeight)
            make.width.equalTo(UIScreen.main.bounds.width / 2)
        }
        
        feeView.algosAmountView.snp.updateConstraints { make in
            make.top.equalToSuperview().inset(layout.current.feeViewOffset)
        }
    }
    
    private func setupLastRoundViewLayout() {
        addSubview(lastRoundView)
        
        lastRoundView.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.top.equalTo(transactionIdView.snp.bottom)
            make.height.equalTo(layout.current.feeViewHeight)
            make.width.equalTo(UIScreen.main.bounds.width / 2)
        }
    }
    
    private func setupRewardViewLayout() {
        addSubview(rewardView)
        
        rewardView.snp.makeConstraints { make in
            make.top.equalTo(feeView.snp.bottom)
            make.height.equalTo(layout.current.feeViewHeight)
            make.leading.trailing.equalToSuperview()
        }
    }
}

extension TransactionDetailView: TransactionReceiverViewDelegate {
    
    func transactionReceiverViewDidTapActionButton(
        _ transactionReceiverView: TransactionReceiverView,
        with mode: TransactionReceiverView.ActionMode
    ) {
        switch mode {
        case .qrView:
            delegate?.transactionDetailViewDidTapShowQRButton(self)
        case .contactAddition:
            delegate?.transactionDetailViewDidTapAddContactButton(self)
        default:
            break
        }
    }
}
