//
//  TabBar.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 4.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class TabBar: UITabBar {
    
    private var oldSafeAreaInsets = UIEdgeInsets.zero
    
    override func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()
        
        if oldSafeAreaInsets != safeAreaInsets {
            oldSafeAreaInsets = safeAreaInsets
            
            invalidateIntrinsicContentSize()
            superview?.setNeedsLayout()
            superview?.layoutSubviews()
        }
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var size = super.sizeThatFits(size)
        let bottomInset = safeAreaInsets.bottom
        
        if bottomInset > 0 && size.height < 50 && (size.height + bottomInset < 90) {
            size.height += bottomInset
        }
        
        return size
    }
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        set {
            var temporaryFrame = newValue
            if let superview = superview, temporaryFrame.maxY != superview.frame.height {
                temporaryFrame.origin.y = superview.frame.height - temporaryFrame.height
            }
            
            super.frame = temporaryFrame
        }
    }
}
