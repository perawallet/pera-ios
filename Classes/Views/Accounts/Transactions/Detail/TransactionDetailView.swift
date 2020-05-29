//
//  TransactionDetailView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 23.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class TransactionDetailView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: TransactionDetailViewDelegate?
    
    private let transactionType: TransactionType
    
    private(set) lazy var statusView: TransactionStatusInformationView = {
        let statusView = TransactionStatusInformationView()
        statusView.setTitle("transaction-detail-status".localized)
        return statusView
    }()
    
    private(set) lazy var amountView: TransactionAmountInformationView = {
        let amountView = TransactionAmountInformationView()
        amountView.setTitle("transaction-detail-amount".localized)
        return amountView
    }()
    
    private(set) lazy var closeAmountView: TransactionAmountInformationView = {
        let rewardView = TransactionAmountInformationView()
        rewardView.setTitle("transaction-detail-close-amount".localized)
        return rewardView
    }()
    
    private(set) lazy var rewardView: TransactionAmountInformationView = {
        let rewardView = TransactionAmountInformationView()
        rewardView.setTitle("transaction-detail-reward".localized)
        return rewardView
    }()
    
    private(set) lazy var userView = TransactionTextInformationView()
    
    private(set) lazy var opponentView = TransactionContactInformationView()
    
    private(set) lazy var closeToView: TransactionTextInformationView = {
        let closeToView = TransactionTextInformationView()
        closeToView.setTitle("transaction-detail-close-to".localized)
        return closeToView
    }()
    
    private(set) lazy var feeView: TransactionAmountInformationView = {
        let feeView = TransactionAmountInformationView()
        feeView.setTitle("transaction-detail-fee".localized)
        return feeView
    }()
    
    private(set) lazy var roundView: TransactionTextInformationView = {
        let roundView = TransactionTextInformationView()
        roundView.setTitle("transaction-detail-round".localized)
        return roundView
    }()
    
    private(set) lazy var idView: TransactionTitleInformationView = {
        let idView = TransactionTitleInformationView()
        idView.setTitle("transaction-detail-id".localized)
        return idView
    }()
    
    private(set) lazy var noteView: TransactionTitleInformationView = {
        let noteView = TransactionTitleInformationView()
        noteView.setTitle("transaction-detail-note".localized)
        return noteView
    }()
    
    init(transactionType: TransactionType) {
        self.transactionType = transactionType
        super.init(frame: .zero)
    }
    
    override func configureAppearance() {
        backgroundColor = SharedColors.secondaryBackground
    }
    
    override func linkInteractors() {
        super.linkInteractors()
        opponentView.delegate = self
    }
    
    override func prepareLayout() {
        setupStatusViewLayout()
        setupAmountViewLayout()
        setupCloseAmountViewLayout()
        setupRewardViewLayout()
        
        if transactionType == .received {
            setupOpponentViewLayout()
            setupUserViewLayout()
            setupCloseToViewLayout()
        } else {
            setupUserViewLayout()
            setupOpponentViewLayout()
            setupCloseToViewLayout()
        }

        setupFeeViewLayout()
        setupRoundViewLayout()
        setupIdViewLayout()
        setupNoteViewLayout()
    }
}

extension TransactionDetailView {
    private func setupStatusViewLayout() {
        addSubview(statusView)
        
        statusView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview().inset(layout.current.statusViewTopInset)
        }
    }
    
    private func setupAmountViewLayout() {
        addSubview(amountView)
        
        amountView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(statusView.snp.bottom)
        }
    }
    
    private func setupCloseAmountViewLayout() {
        addSubview(closeAmountView)
        
        closeAmountView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(amountView.snp.bottom)
        }
    }
    
    private func setupRewardViewLayout() {
        addSubview(rewardView)
        
        rewardView.snp.makeConstraints { make in
            make.top.equalTo(closeAmountView.snp.bottom)
            make.top.equalTo(amountView.snp.bottom).priority(.low)
            make.leading.trailing.equalToSuperview()
        }
    }
    
    private func setupUserViewLayout() {
        addSubview(userView)
        
        userView.snp.makeConstraints { make in
            if transactionType == .received {
                make.top.equalTo(opponentView.snp.bottom)
            } else {
                make.top.equalTo(rewardView.snp.bottom)
                make.top.equalTo(closeAmountView.snp.bottom).priority(.medium)
                make.top.equalTo(amountView.snp.bottom).priority(.low)
            }
            
            make.leading.trailing.equalToSuperview()
        }
    }
    
    private func setupOpponentViewLayout() {
        addSubview(opponentView)
        
        opponentView.snp.makeConstraints { make in
            if transactionType == .received {
                make.top.equalTo(amountView.snp.bottom).priority(.low)
                make.top.equalTo(closeAmountView.snp.bottom).priority(.medium)
                make.top.equalTo(rewardView.snp.bottom)
            } else {
                make.top.equalTo(userView.snp.bottom)
            }
            
            make.leading.trailing.equalToSuperview()
        }
    }
    
    private func setupCloseToViewLayout() {
        addSubview(closeToView)
        
        closeToView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            if transactionType == .received {
                make.top.equalTo(userView.snp.bottom)
            } else {
                make.top.equalTo(opponentView.snp.bottom)
            }
        }
    }
    
    private func setupFeeViewLayout() {
        addSubview(feeView)
        
        feeView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            if transactionType == .received {
                make.top.equalTo(closeToView.snp.bottom)
                make.top.equalTo(userView.snp.bottom).priority(.low)
            } else {
                make.top.equalTo(closeToView.snp.bottom)
                make.top.equalTo(opponentView.snp.bottom).priority(.low)
            }
        }
    }
    
    private func setupRoundViewLayout() {
        addSubview(roundView)
        
        roundView.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.top.equalTo(feeView.snp.bottom)
        }
    }
    
    private func setupIdViewLayout() {
        addSubview(idView)
        
        idView.snp.makeConstraints { make in
            make.top.equalTo(feeView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview().inset(layout.current.bottomInset).priority(.low)
        }
    }
    
    private func setupNoteViewLayout() {
        addSubview(noteView)
        
        noteView.snp.makeConstraints { make in
            make.top.equalTo(idView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview().inset(layout.current.bottomInset)
        }
    }
}

extension TransactionDetailView: TransactionContactInformationViewDelegate {
    func transactionContactInformationViewDidTapActionButton(_ transactionContactInformationView: TransactionContactInformationView) {
        delegate?.transactionDetailViewDidTapOpponentActionButton(self)
    }
}

extension TransactionDetailView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let statusViewTopInset: CGFloat = 12.0
        let bottomInset: CGFloat = 20.0
    }
}

protocol TransactionDetailViewDelegate: class {
    func transactionDetailViewDidTapOpponentActionButton(_ transactionDetailView: TransactionDetailView)
}
