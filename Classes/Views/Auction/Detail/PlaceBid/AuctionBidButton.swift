//
//  AuctionBidButton.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 18.05.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AuctionBidButton: UIButton {
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureButton()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureButton() {
        setTitleColor(SharedColors.blue, for: .normal)
        setTitleColor(SharedColors.darkGray, for: .disabled)
        
        setBackgroundImage(img("bg-place-bid-button"), for: .normal)
        setBackgroundImage(img("bg-place-bid-button-disabled"), for: .disabled)
        
        titleLabel?.font = UIFont.font(.montserrat, withWeight: .bold(size: 12.0))
    }
}
