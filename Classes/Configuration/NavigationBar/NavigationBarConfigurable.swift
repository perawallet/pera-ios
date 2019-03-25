//
//  NavigationBarConfigurable.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 25.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol NavigationBarConfigurable: class {
    associatedtype BarButtonItemRef: BarButtonItem
    
    /// Back/Dismiss bar button items should not be added into leftBarButtonItems&rightBarButtonItems.
    /// They will be inserted automatically when setNeedsNavigationBarAppearanceUpdate() is called.
    var leftBarButtonItems: [BarButtonItemRef] { get set }
    var rightBarButtonItems: [BarButtonItemRef] { get set }
    /// Return true if pop/dismiss should be hidden.
    var hidesCloseBarButtonItem: Bool { get }
    
    func setNeedsNavigationBarAppearanceUpdate()
    
    /// Return true if pop/dismiss should be performed.
    func didTapBackBarButton() -> Bool
    func didTapDismissBarButton() -> Bool
}

extension NavigationBarConfigurable where Self: UIViewController {
    
    var hidesCloseBarButtonItem: Bool {
        return false
    }
    
    func setNeedsNavigationBarAppearanceUpdate() {
        guard let navigationController = navigationController,
            let topViewController = navigationController.viewControllers.first else {
                return
        }
        
        navigationItem.hidesBackButton = hidesCloseBarButtonItem
        
        if !hidesCloseBarButtonItem {
            if topViewController == self {
                if presentingViewController != nil {
                    if var dismissBarButtonItem = BarButtonItemRef.dismiss() {
                        dismissBarButtonItem.handler = { [unowned self] in
                            if !self.didTapDismissBarButton() {
                                return
                            }
                            self.navigationController?.presentingViewController?.dismiss(animated: true, completion: nil)
                        }
                        leftBarButtonItems.insert(dismissBarButtonItem, at: 0)
                    }
                }
            } else {
                if var backBarButtonItem = BarButtonItemRef.back() {
                    backBarButtonItem.handler = { [unowned self] in
                        if !self.didTapBackBarButton() {
                            return
                        }
                        self.navigationController?.popViewController(animated: true)
                    }
                    leftBarButtonItems.insert(backBarButtonItem, at: 0)
                }
            }
        }
        navigationItem.leftBarButtonItems = leftBarButtonItems.map {
            UIBarButtonItem(customView: BarButton(barButtonItem: $0))
        }
        navigationItem.rightBarButtonItems = rightBarButtonItems.map {
            UIBarButtonItem(customView: BarButton(barButtonItem: $0))
        }
    }
    
    func didTapBackBarButton() -> Bool {
        return true
    }
    
    func didTapDismissBarButton() -> Bool {
        return true
    }
}
