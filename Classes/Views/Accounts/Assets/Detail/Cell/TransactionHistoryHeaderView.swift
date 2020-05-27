//
//  TransactionHistoryHeaderView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 13.05.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class TransactionHistoryHeaderView: BaseView {

    private let layout = Layout<LayoutConstants>()
    
    private lazy var titleLabel: UILabel = {
        UILabel()
            .withAlignment(.left)
            .withFont(UIFont.font(withWeight: .semiBold(size: 16.0)))
            .withTextColor(SharedColors.primaryText)
            .withText("contacts-transactions-title".localized)
    }()
    
    private lazy var separatorView = LineSeparatorView()
    
    override func configureAppearance() {
        backgroundColor = SharedColors.secondaryBackground
    }
    
    override func prepareLayout() {
        setupTitleLabelLayout()
        setupSeparatorViewLayout()
    }
}

extension TransactionHistoryHeaderView {
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.centerY.equalToSuperview()
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

extension TransactionHistoryHeaderView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0
        let separatorHeight: CGFloat = 1.0
    }
}
