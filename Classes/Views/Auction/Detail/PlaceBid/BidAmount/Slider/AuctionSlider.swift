//
//  AuctionSlider.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 18.05.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AuctionSlider: UISlider {
    
    var sliderState: SliderState = .initial {
        didSet {
            if sliderState == oldValue {
                return
            }
            
            configureSlider()
        }
    }
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        minimumValue = 0
        maximumValue = 100
        
        minimumTrackTintColor = SharedColors.softGray
        maximumTrackTintColor = SharedColors.blue
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Configuration
    
    private func configureSlider() {
        switch sliderState {
        case .initial:
            break
        case .selected:
            break
        }
    }
    
}

extension AuctionSlider {
    
    enum SliderState {
        case initial
        case selected
    }
}
