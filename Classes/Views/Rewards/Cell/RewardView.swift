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
    
    private lazy var titleLabel: UILabel = {
        UILabel()
            .withLine(.single)
            .withAlignment(.left)
            .withFont(UIFont.font(withWeight: .semiBold(size: 13.0)))
            .withTextColor(SharedColors.primaryText)
            .withText("reward-list-title".localized)
    }()
    
    private(set) lazy var transactionAmountView = TransactionAmountView()
    
    private lazy var dateLabel: UILabel = {
        UILabel()
            .withLine(.single)
            .withAlignment(.right)
            .withFont(UIFont.font(withWeight: .regular(size: 12.0)))
            .withTextColor(SharedColors.gray600)
    }()
    
    private lazy var separatorView = LineSeparatorView()
    
    override func configureAppearance() {
        backgroundColor = SharedColors.secondaryBackground
    }
    
    override func prepareLayout() {
        setupTitleLabelLayout()
        setupTransactionAmountViewLayout()
        setupDateLabelLayout()
        setupSeparatorViewLayout()
    }
}

extension RewardView {
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalToSuperview().inset(layout.current.verticalInset)
        }
    }
    
    private func setupTransactionAmountViewLayout() {
        addSubview(transactionAmountView)
        
        transactionAmountView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset).priority(.required)
            make.top.equalToSuperview().inset(layout.current.verticalInset)
            make.centerY.equalTo(titleLabel)
            make.leading.greaterThanOrEqualTo(titleLabel.snp.trailing).offset(layout.current.minimumHorizontalSpacing).priority(.required)
        }
    }
    
    private func setupDateLabelLayout() {
        addSubview(dateLabel)
        
        dateLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        dateLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        dateLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset).priority(.required)
            make.top.equalTo(transactionAmountView.snp.bottom).offset(layout.current.minimumHorizontalSpacing)
            make.leading.lessThanOrEqualToSuperview().inset(layout.current.horizontalInset)
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
    func setDate(_ date: String?) {
        dateLabel.text = date
    }
}

extension RewardView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0
        let verticalInset: CGFloat = 16.0
        let minimumHorizontalSpacing: CGFloat = 4.0
        let separatorHeight: CGFloat = 1.0
    }
}
