//
//  AuctionSlider.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 18.05.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AuctionSlider: UISlider {
    
    override func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
        var customThumbRect = super.thumbRect(forBounds: bounds, trackRect: rect, value: value)
        
        if value == 0 {
            customThumbRect.origin.x -= 10.0
        } else if value == 25 {
            customThumbRect.origin.x -= 6.0
        } else if value == 50 {
            customThumbRect.origin.x -= 1.5
        } else if value == 75 {
            customThumbRect.origin.x += 1.0
        } else if value == 100 {
            customThumbRect.origin.x += 8.0
        }
        
        return customThumbRect
    }
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        var customTrackRect = super.trackRect(forBounds: bounds)
        customTrackRect.size.height = 4.0
        return customTrackRect
    }
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        minimumValue = 0
        maximumValue = 100
        
        minimumTrackTintColor = SharedColors.turquois
        maximumTrackTintColor = SharedColors.softGray
        
        setMaximumTrackImage(img("slider-line-icon"), for: .normal)
        
        setThumbImage(img("icon-slider-zero"), for: .normal)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
