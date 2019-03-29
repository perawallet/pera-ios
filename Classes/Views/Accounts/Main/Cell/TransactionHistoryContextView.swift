//
//  TransactionHistoryContextView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 29.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class TransactionHistoryContextView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 25.0
        let topInset: CGFloat = 20.0
        let bottomInset: CGFloat = 18.0
        let labelVerticalInset: CGFloat = 5.0
        let separatorInset: CGFloat = 20.0
        let separatorHeight: CGFloat = 1.0
        let minimumHorizontalSpacing: CGFloat = 3.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    private enum Colors {
        static let separatorColor = rgb(0.95, 0.96, 0.96)
    }
    
    // MARK: Components
    
    private(set) lazy var transactionDetailLabel: UILabel = {
        UILabel()
            .withLine(.single)
            .withAlignment(.left)
            .withFont(UIFont.font(.opensans, withWeight: .semiBold(size: 14.0)))
            .withTextColor(SharedColors.black)
    }()
    
    private(set) lazy var transactionAmountView: AlgosAmountView = {
        let view = AlgosAmountView()
        return view
    }()
    
    private(set) lazy var dateLabel: UILabel = {
        UILabel()
            .withLine(.single)
            .withAlignment(.left)
            .withFont(UIFont.font(.opensans, withWeight: .semiBold(size: 12.0)))
            .withTextColor(SharedColors.softGray)
    }()
    
    private(set) lazy var accountNamelabel: UILabel = {
        UILabel()
            .withLine(.single)
            .withAlignment(.right)
            .withFont(UIFont.font(.opensans, withWeight: .semiBold(size: 12.0)))
            .withTextColor(SharedColors.softGray)
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.separatorColor
        return view
    }()
    
    // MARK: Setup
    
    override func configureAppearance() {
        backgroundColor = .white
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupTransactionDetailLabelLayout()
        setupTransactionAmountViewLayout()
        setupDateLabelLayout()
        setupAccountNameLabelLayout()
        setupSeparatorViewLayout()
    }
    
    private func setupTransactionDetailLabelLayout() {
        addSubview(transactionDetailLabel)
        
        transactionDetailLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalToSuperview().inset(layout.current.topInset)
        }
    }
    
    private func setupTransactionAmountViewLayout() {
        addSubview(transactionAmountView)
        
        transactionAmountView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalToSuperview().inset(layout.current.topInset)
            make.centerY.equalTo(transactionDetailLabel)
            make.leading.greaterThanOrEqualTo(transactionDetailLabel.snp.trailing).offset(layout.current.minimumHorizontalSpacing)
        }
    }
    
    private func setupDateLabelLayout() {
        addSubview(dateLabel)
        
        dateLabel.snp.makeConstraints { make in
            make.leading.equalTo(transactionDetailLabel)
            make.top.equalTo(transactionDetailLabel.snp.bottom).offset(layout.current.labelVerticalInset)
            make.bottom.equalToSuperview().inset(layout.current.bottomInset)
        }
    }
    
    private func setupAccountNameLabelLayout() {
        addSubview(accountNamelabel)
        
        accountNamelabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.centerY.equalTo(dateLabel)
            make.leading.greaterThanOrEqualTo(dateLabel.snp.trailing).offset(layout.current.minimumHorizontalSpacing)
        }
    }
    
    private func setupSeparatorViewLayout() {
        addSubview(separatorView)
        
        separatorView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.height.equalTo(layout.current.separatorHeight)
            make.leading.trailing.equalToSuperview().inset(layout.current.separatorInset)
        }
    }
}
