//
//  UIViewController+Additions.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 20.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

extension UIViewController {
    var topMostController: UIViewController? {
        if let controller = self as? UINavigationController {
            return controller.topViewController?.topMostController
        }
        if let controller = self as? UISplitViewController {
            return controller.viewControllers.last?.topMostController
        }
        if let controller = self as? UITabBarController {
            return controller.selectedViewController?.topMostController
        }
        if let controller = presentedViewController {
            return controller.topMostController
        }
        return self
    }
    
    func displaySimpleAlertWith(title: String, message: String, handler: ((UIAlertAction) -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "title-ok".localized, style: .default, handler: handler)
        alertController.addAction(okAction)
        
        present(alertController, animated: true)
    }
    
    func add(_ child: UIViewController) {
        if child.parent != nil {
            return
        }
        
        addChild(child)
        view.addSubview(child.view)

        child.view.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }

        child.didMove(toParent: self)
    }

    func removeFromParentController() {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}
