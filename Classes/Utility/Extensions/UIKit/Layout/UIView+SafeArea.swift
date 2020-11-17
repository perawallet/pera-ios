//
//  UIView+SafeArea.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 14.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

extension UIView {
    var safeAreaBottom: CGFloat {
        return UIApplication.shared.safeAreaBottom
    }
    
    var safeAreaTop: CGFloat {
        return UIApplication.shared.safeAreaTop
    }
    
    var compactSafeAreaInsets: UIEdgeInsets {
        if let window = window {
            return window.safeAreaInsets
        }
        return UIApplication.shared.keyWindow?.safeAreaInsets ?? .zero
    }
}

extension UIView {
    var isDarkModeDisplay: Bool {
        if #available(iOS 12.0, *) {
            return traitCollection.userInterfaceStyle == .dark
        }
        
        return false
    }
}
