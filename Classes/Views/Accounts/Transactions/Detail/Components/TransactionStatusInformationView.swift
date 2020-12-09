//
//  TransactionStatusInformationView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 8.05.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class TransactionStatusInformationView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var titleLabel = TransactionDetailTitleLabel()
    
    private lazy var transactionStatusView = TransactionStatusView()
    
    private lazy var separatorView = LineSeparatorView()
    
    override func configureAppearance() {
        backgroundColor = Colors.Background.tertiary
    }
    
    override func prepareLayout() {
        setupTitleLabelLayout()
        setupTransactionStatusViewLayout()
        setupSeparatorViewLayout()
    }
}

extension TransactionStatusInformationView {
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.labelTopInset)
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupTransactionStatusViewLayout() {
        addSubview(transactionStatusView)
        
        transactionStatusView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.bottom.equalToSuperview().inset(layout.current.statusVerticalInset)
        }
    }
    
    private func setupSeparatorViewLayout() {
        addSubview(separatorView)
        
        separatorView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.height.equalTo(layout.current.separatorHeight)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
}

extension TransactionStatusInformationView {
    func setTitle(_ title: String) {
        titleLabel.text = title
    }
    
    func setTransactionStatus(_ status: Transaction.Status) {
        transactionStatusView.setStatus(status)
    }
}

extension TransactionStatusInformationView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0
        let statusVerticalInset: CGFloat = 16.0
        let labelTopInset: CGFloat = 20.0
        let separatorHeight: CGFloat = 1.0
    }
}
