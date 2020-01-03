//
//  RewardView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 12.09.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class RewardView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 25.0
        let verticalInset: CGFloat = 16.0
        let separatorInset: CGFloat = 30.0
        let separatorHeight: CGFloat = 1.0
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
            .withText("reward-list-title".localized)
    }()
    
    private(set) lazy var transactionAmountView: AlgosAmountView = {
        let view = AlgosAmountView()
        view.signLabel.isHidden = true
        view.algoIconImageView.tintColor = SharedColors.purple
        view.amountLabel.textColor = SharedColors.purple
        return view
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
        setupSeparatorViewLayout()
    }
    
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
            make.leading.trailing.equalToSuperview().inset(layout.current.separatorInset)
        }
    }
}
