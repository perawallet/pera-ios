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
    func setTitle(_ title: String?) {
        titleLabel.text = title
    }
    
    static func calculatePreferredSize(with layout: Layout<LayoutConstants>) -> CGSize {
        let width = UIScreen.main.bounds.width
        let constantHeight = layout.current.titleTopInset + layout.current.detailTopInset
        let detailLabelHeight = "ledger-account-selection-detail".localized.height(
            withConstrained: width - layout.current.horizontalInset * 2,
            font: UIFont.font(withWeight: .regular(size: 14.0))
        )
        let titleLabelHeight: CGFloat = 24.0
        let height: CGFloat = constantHeight + detailLabelHeight + titleLabelHeight
        return CGSize(width: width, height: height)
    }
}

extension LedgerAccountSelectionHeaderView {
    struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 24.0
        let titleTopInset: CGFloat = 16.0
        let detailTopInset: CGFloat = 8.0
    }
}
