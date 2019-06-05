//
//  NumberLabel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 8.05.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class NumberLabel: UILabel {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let labelSize: CGSize = CGSize(width: 22.0 * verticalScale, height: 22.0 * verticalScale)
        let cornerRadius: CGFloat = 11.0 * verticalScale
    }
    
    private let layout = Layout<LayoutConstants>()
    
    override var intrinsicContentSize: CGSize {
        return layout.current.labelSize
    }
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        textColor = SharedColors.red
        textAlignment = .center
        font = UIFont.font(.overpass, withWeight: .semiBold(size: 12.0 * verticalScale))
        
        layer.cornerRadius = layout.current.cornerRadius
        layer.borderWidth = 1.0
        layer.borderColor = SharedColors.red.cgColor
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
