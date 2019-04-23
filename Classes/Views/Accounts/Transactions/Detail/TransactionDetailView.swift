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
}

class TransactionDetailView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {

        let amountViewTopInset: CGFloat = 30.0
        let horizontalInset: CGFloat = 25.0
        let amountViewBottomInset: CGFloat = 20.0
        let receiverViewHeight: CGFloat = 90.0
        let separatorHeight: CGFloat = 1.0
        let bottomInset: CGFloat = 10.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    private enum Colors {
        static let separatorColor = rgba(0.67, 0.67, 0.72, 0.31)
    }
    
    weak var delegate: TransactionDetailViewDelegate?
    
    // MARK: Components
    
    private(set) lazy var transactionAmountView: AlgosAmountView = {
        let view = AlgosAmountView()
        view.signLabel.font = UIFont.font(.opensans, withWeight: .bold(size: 40.0))
        view.amountLabel.font = UIFont.font(.opensans, withWeight: .bold(size: 40.0))
        return view
    }()
    
    private(set) lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.separatorColor
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
        transactionOpponentView.qrButton.addTarget(self, action: #selector(notifyDelegateToAddContactButtonTapped), for: .touchUpInside)
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupTransactionAmountViewLayout()
        setupSeparatorViewLayout()
        setupUserAccountViewLayout()
        setupTransactionOpponentViewLayout()
        setupTransactionIdViewLayout()
    }
    
    private func setupTransactionAmountViewLayout() {
        addSubview(transactionAmountView)
        
        transactionAmountView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalToSuperview().inset(layout.current.amountViewTopInset)
        }
    }
    
    private func setupSeparatorViewLayout() {
        addSubview(separatorView)
        
        separatorView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(transactionAmountView.snp.bottom).offset(layout.current.amountViewBottomInset)
            make.height.equalTo(layout.current.separatorHeight)
        }
    }
    
    private func setupUserAccountViewLayout() {
        addSubview(userAccountView)
        
        userAccountView.snp.makeConstraints { make in
            make.top.equalTo(separatorView.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }
    }
    
    private func setupTransactionOpponentViewLayout() {
        addSubview(transactionOpponentView)
        
        transactionOpponentView.snp.makeConstraints { make in
            make.top.equalTo(userAccountView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.greaterThanOrEqualTo(layout.current.receiverViewHeight)
        }
    }
    
    private func setupTransactionIdViewLayout() {
        addSubview(transactionIdView)
        
        transactionIdView.snp.makeConstraints { make in
            make.top.equalTo(transactionOpponentView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview().inset(layout.current.bottomInset)
        }
    }
    
    // MARK: Actions
    
    @objc
    private func notifyDelegateToAddContactButtonTapped() {
        delegate?.transactionDetailViewDidTapAddContactButton(self)
    }
}
