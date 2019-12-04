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
        let topInset: CGFloat = 18.0
        let amountTopInset: CGFloat = 16.0
        let bottomInset: CGFloat = 18.0
        let labelVerticalInset: CGFloat = 3.0
        let separatorInset: CGFloat = 30.0
        let separatorHeight: CGFloat = 1.0
        let minimumHorizontalSpacing: CGFloat = 3.0
        let titleLabelRightInset: CGFloat = 125.0
        let amountViewHeight: CGFloat = 22.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    private enum Colors {
        static let separatorColor = rgb(0.95, 0.96, 0.96)
    }
    
    // MARK: Components
    
    private(set) lazy var titleLabel: UILabel = {
        UILabel()
            .withLine(.single)
            .withAlignment(.left)
            .withFont(UIFont.font(.avenir, withWeight: .demiBold(size: 13.0)))
            .withTextColor(SharedColors.black)
    }()
    
    private(set) lazy var transactionAmountView: AlgosAmountView = {
        let view = AlgosAmountView()
        return view
    }()
    
    private(set) lazy var subtitleLabel: UILabel = {
        UILabel()
            .withLine(.single)
            .withAlignment(.left)
            .withFont(UIFont.font(.overpass, withWeight: .semiBold(size: 12.0)))
            .withTextColor(SharedColors.softGray)
    }()
    
    private(set) lazy var dateLabel: UILabel = {
        UILabel()
            .withLine(.single)
            .withAlignment(.right)
            .withFont(UIFont.font(.overpass, withWeight: .semiBold(size: 12.0)))
            .withTextColor(SharedColors.darkGray)
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
        setupTitleLabelLayout()
        setupTransactionAmountViewLayout()
        setupSubtitleLabelLayout()
        setupDateLabelLayout()
        setupSeparatorViewLayout()
    }
    
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalToSuperview().inset(layout.current.topInset)
            make.trailing.lessThanOrEqualToSuperview().inset(layout.current.titleLabelRightInset).priority(.low)
        }
    }
    
    private func setupTransactionAmountViewLayout() {
        addSubview(transactionAmountView)
        
        transactionAmountView.setContentCompressionResistancePriority(.required, for: .horizontal)
        transactionAmountView.setContentHuggingPriority(.required, for: .horizontal)
        
        transactionAmountView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset).priority(.required)
            make.top.equalToSuperview().inset(layout.current.amountTopInset)
            make.centerY.equalTo(titleLabel)
            make.height.equalTo(layout.current.amountViewHeight)
            make.leading.greaterThanOrEqualTo(titleLabel.snp.trailing).offset(layout.current.minimumHorizontalSpacing).priority(.required)
        }
    }
    
    private func setupSubtitleLabelLayout() {
        addSubview(subtitleLabel)
        
        subtitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.labelVerticalInset)
            make.bottom.equalToSuperview().inset(layout.current.bottomInset)
        }
    }
    
    private func setupDateLabelLayout() {
        addSubview(dateLabel)
        
        dateLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        dateLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset).priority(.required)
            make.centerY.equalTo(subtitleLabel)
            make.leading.greaterThanOrEqualTo(subtitleLabel.snp.trailing)
                .offset(layout.current.minimumHorizontalSpacing)
                .priority(.required)
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
