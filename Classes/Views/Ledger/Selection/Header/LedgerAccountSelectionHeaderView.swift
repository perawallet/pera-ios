//
//  LedgerAccountSelectionHeaderView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 10.08.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class LedgerAccountSelectionHeaderView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var titleLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .medium(size: 16.0)))
            .withTextColor(SharedColors.primaryText)
            .withLine(.single)
            .withAlignment(.left)
            .withText("ledger-account-selection-title".localized)
    }()
    
    private lazy var detailLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
            .withTextColor(SharedColors.secondaryText)
            .withLine(.contained)
            .withAlignment(.left)
            .withText("ledger-account-selection-detail".localized)
    }()
    
    override func prepareLayout() {
        setupTitleLabelLayout()
        setupDetailLabelLayout()
    }
}

extension LedgerAccountSelectionHeaderView {
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.titleTopInset)
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupDetailLabelLayout() {
        addSubview(detailLabel)
        
        detailLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.detailTopInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
}

extension LedgerAccountSelectionHeaderView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 24.0
        let titleTopInset: CGFloat = 16.0
        let detailTopInset: CGFloat = 8.0
    }
}
