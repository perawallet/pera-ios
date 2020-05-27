//
//  TransactionDetailTitleLabel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 8.05.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class TransactionDetailTitleLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        configureAppearance()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureAppearance() {
        textAlignment = .left
        numberOfLines = 1
        font = UIFont.font(withWeight: .regular(size: 14.0))
        textColor = SharedColors.inputTitle
    }
}
