//
//  AuctionDetailHeaderButton.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 18.05.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AuctionDetailHeaderButton: UIButton {
    
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
        setTitleColor(SharedColors.black, for: .normal)
        setTitleColor(.white, for: .selected)
        
        setBackgroundImage(img("bg-bid-button"), for: .normal)
        setBackgroundImage(img("bg-bid-button-selected"), for: .selected)
        
        titleLabel?.font = UIFont.font(.montserrat, withWeight: .semiBold(size: 11.0))
    }
}
