//
//  DepositTransactionHeaderView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 20.06.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class DepositTransactionHeaderView: UICollectionReusableView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let height: CGFloat = 51.0
        let topInset: CGFloat = 25.0
        let horizontalInset: CGFloat = 20.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: layout.current.height)
    }
    
    // MARK: Components
    
    private(set) lazy var titleLabel: UILabel = {
        UILabel()
            .withAlignment(.center)
            .withLine(.single)
            .withTextColor(SharedColors.softGray)
            .withFont(UIFont.font(.avenir, withWeight: .medium(size: 13.0)))
    }()
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = SharedColors.warmWhite
        setupAmountLabelLayout()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupAmountLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(layout.current.topInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
}
