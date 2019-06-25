//
//  CoinlistTransactionCell.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 17.06.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class PendingCoinlistTransactionCell: BaseCollectionViewCell<CoinlistTransactionCellContextView> {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0
        let minimumInset: CGFloat = 5.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    override func configureAppearance() {
        contextView.balanceLabel.isHidden = true
        contextView.transactionAmountLabel.font = UIFont.font(.overpass, withWeight: .bold(size: 15.0))
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        
        contextView.transactionAmountLabel.snp.remakeConstraints { make in
            make.leading.greaterThanOrEqualTo(contextView.titleLabel.snp.trailing).offset(layout.current.minimumInset)
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.centerY.equalToSuperview()
        }
    }
}
