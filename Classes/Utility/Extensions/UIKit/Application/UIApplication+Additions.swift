//
//  UIApplication+Additions.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 13.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

extension UIApplication {
    
    var isActive: Bool {
        return applicationState == .active
    }
    
    var isPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var isPortrait: Bool {
        switch statusBarOrientation {
        case .portrait,
             .portraitUpsideDown:
            return true
        default:
            return false
        }
    }
    
    var isLandscape: Bool {
        switch statusBarOrientation {
        case .landscapeLeft,
             .landscapeRight:
            return true
        default:
            return false
        }
    }
    
    var statusBarView: UIView? {
        if responds(to: Selector(("statusBar"))) {
            return value(forKey: "statusBar") as? UIView
        }
        return nil
    }
    
    var appDelegate: AppDelegate? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }
        
        return appDelegate
    }
    
    var appConfiguration: AppConfiguration? {
        guard let rootViewController = rootViewController() else {
            return nil
        }
        
        return rootViewController.appConfiguration
    }
    
    var accountManager: AccountManager? {
        return appDelegate?.accountManager
    }
    
    func rootViewController() -> RootViewController? {
        guard let navigationController = keyWindow?.rootViewController as? NavigationController else {
            return nil
        }
        
        return navigationController.viewControllers.first as? RootViewController
    }
    
    var safeAreaBottom: CGFloat {
        guard let window = UIApplication.shared.keyWindow else {
            return 0.0
        }
        
        return window.safeAreaInsets.bottom
    }
    
    var safeAreaTop: CGFloat {
        guard let window = UIApplication.shared.keyWindow else {
            return 0.0
        }
        
        return window.safeAreaInsets.top
    }
    
    @discardableResult
    func route<T: UIViewController>(
        to screen: Screen,
        from viewController: UIViewController,
        by style: Screen.Transition.Open,
        animated: Bool = true,
        then completion: EmptyHandler? = nil
    ) -> T? {
        
        guard let rootViewController = rootViewController() else {
            return nil
        }
        
        return rootViewController.route(to: screen, from: viewController, by: style, animated: animated, then: completion)
    }
    
    func openAppSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        UIApplication.shared.open(settingsURL, options: [:])
    }
    
    var isDarkModeDisplay: Bool {
        if #available(iOS 12.0, *) {
            guard let rootViewController = rootViewController() else {
                return false
            }
            
            return rootViewController.traitCollection.userInterfaceStyle == .dark
        }
        
        return false
    }
}
