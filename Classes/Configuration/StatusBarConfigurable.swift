//
//  StatusBarConfigurable.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 14.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit
import SnapKit

protocol StatusBarConfigurable: class {
    
    var isStatusBarHidden: Bool { get set }
    
    var hidesStatusBarWhenAppeared: Bool { get set }
    
    var hidesStatusBarWhenPresented: Bool { get set }
}

extension StatusBarConfigurable where Self: UIViewController {
    
    // Should be called in viewWillAppear(:)
    func setNeedsStatusBarLayoutUpdateWhenAppearing() {
        var statusBarHidden = false
        
        if hidesStatusBarWhenPresented,
            presentingViewController != nil {
            statusBarHidden = true
        } else {
            statusBarHidden = hidesStatusBarWhenAppeared
        }
        
        if isStatusBarHidden == statusBarHidden {
            return
        }
        
        isStatusBarHidden = statusBarHidden
        
        setNeedsStatusBarAppearanceUpdate()
    }
    
    // Should be called in viewWillDisappear(:)
    func setNeedsStatusBarLayoutUpdateWhenDisappearing() {
        var thePresentedViewController = presentedViewController
        
        if let presentedNavigationController = thePresentedViewController as? UINavigationController {
            thePresentedViewController = presentedNavigationController.topViewController
        }
        
        if let viewController = thePresentedViewController as? StatusBarConfigurable,
            (viewController.hidesStatusBarWhenPresented || viewController.hidesStatusBarWhenAppeared) {
            
            isStatusBarHidden = true
        }
    }
}
