//
//  RewardView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 12.09.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class RewardView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private(set) lazy var titleLabel: UILabel = {
        UILabel()
            .withLine(.single)
            .withAlignment(.left)
            .withFont(UIFont.font(withWeight: .demiBold(size: 13.0)))
            .withTextColor(SharedColors.primaryText)
            .withText("reward-list-title".localized)
    }()
    
    private(set) lazy var transactionAmountView = TransactionAmountView()
    
    private lazy var separatorView = LineSeparatorView()
    
    override func configureAppearance() {
        backgroundColor = SharedColors.secondaryBackground
    }
    
    override func prepareLayout() {
        setupTitleLabelLayout()
        setupTransactionAmountViewLayout()
        setupSeparatorViewLayout()
    }
}

extension RewardView {
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.bottom.equalToSuperview().inset(layout.current.verticalInset)
        }
    }
    
    private func setupTransactionAmountViewLayout() {
        addSubview(transactionAmountView)
        
        transactionAmountView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.centerY.equalTo(titleLabel)
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

extension RewardView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0
        let verticalInset: CGFloat = 26.0
        let separatorHeight: CGFloat = 1.0
    }
}
