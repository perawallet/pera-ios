//
//  BalanceHeaderView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 20.06.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class BalanceHeaderView: BaseView {

    private struct LayoutConstants: AdaptiveLayoutConstants {
        let labelInset: CGFloat = 15.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    // MARK: Components
    
    private(set) lazy var amountLabel: UILabel = {
        UILabel()
            .withAlignment(.center)
            .withLine(.single)
            .withTextColor(.black)
            .withFont(UIFont.font(.overpass, withWeight: .extraBold(size: 33.0)))
    }()
    
    private lazy var availableTitleLabel: UILabel = {
        UILabel()
            .withAlignment(.center)
            .withLine(.single)
            .withTextColor(SharedColors.softGray)
            .withFont(UIFont.font(.overpass, withWeight: .semiBold(size: 13.0)))
            .withText("balance-available-title".localized)
    }()
    
    // MARK: Setup
    
    override func configureAppearance() {
        backgroundColor = .white
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupAmountLabelLayout()
        setupAvailableTitleLabelLayout()
    }
    
    private func setupAmountLabelLayout() {
        addSubview(amountLabel)
        
        amountLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(layout.current.labelInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.labelInset)
        }
    }
    
    private func setupAvailableTitleLabelLayout() {
        addSubview(availableTitleLabel)
        
        availableTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(amountLabel.snp.bottom)
            make.centerX.equalToSuperview()
        }
    }
}
