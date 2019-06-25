//
//  CoinlistTransactionCellContextView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 17.06.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class CoinlistTransactionCellContextView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let topInset: CGFloat = 8.0
        let minimumInset: CGFloat = 5.0
        let horizontalInset: CGFloat = 20.0
        let separatorHeight: CGFloat = 1.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    private enum Colors {
        static let separatorColor = rgb(0.95, 0.96, 0.96)
    }
    
    // MARK: Components

    private(set) lazy var titleLabel: UILabel = {
        UILabel()
            .withAlignment(.left)
            .withLine(.single)
            .withTextColor(SharedColors.black)
            .withFont(UIFont.font(.avenir, withWeight: .medium(size: 14.0)))
    }()
    
    private(set) lazy var dateLabel: UILabel = {
        UILabel()
            .withAlignment(.left)
            .withLine(.single)
            .withTextColor(SharedColors.softGray)
            .withFont(UIFont.font(.overpass, withWeight: .semiBold(size: 13.0)))
    }()
    
    private(set) lazy var balanceLabel: UILabel = {
        UILabel()
            .withAlignment(.right)
            .withLine(.single)
            .withTextColor(SharedColors.black)
            .withFont(UIFont.font(.overpass, withWeight: .bold(size: 14.0)))
    }()
    
    private(set) lazy var transactionAmountLabel: UILabel = {
        UILabel()
            .withAlignment(.right)
            .withLine(.single)
            .withTextColor(SharedColors.darkGray)
            .withFont(UIFont.font(.overpass, withWeight: .bold(size: 12.0)))
    }()
    
    private(set) lazy var separatorView: UIView = {
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
        super.prepareLayout()
        
        setupTitleLabelLayout()
        setupDateLabelLayout()
        setupBalanceLabelLayout()
        setupTransactionAmountLabelLayout()
        setupSeparatorViewLayout()
    }
    
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupDateLabelLayout() {
        addSubview(dateLabel)
        
        dateLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.topInset)
        }
    }
    
    private func setupBalanceLabelLayout() {
        addSubview(balanceLabel)
        
        balanceLabel.setContentHuggingPriority(.required, for: .horizontal)
        balanceLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        balanceLabel.snp.makeConstraints { make in
            make.leading.greaterThanOrEqualTo(titleLabel.snp.trailing).offset(layout.current.minimumInset)
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.centerY.equalTo(titleLabel)
        }
    }
    
    private func setupTransactionAmountLabelLayout() {
        addSubview(transactionAmountLabel)
        
        transactionAmountLabel.setContentHuggingPriority(.required, for: .horizontal)
        transactionAmountLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        transactionAmountLabel.snp.makeConstraints { make in
            make.leading.greaterThanOrEqualTo(dateLabel.snp.trailing).offset(layout.current.minimumInset)
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.centerY.equalTo(dateLabel)
        }
    }
    
    private func setupSeparatorViewLayout() {
        addSubview(separatorView)
        
        separatorView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.height.equalTo(layout.current.separatorHeight)
            make.bottom.equalToSuperview()
        }
    }
}
