//
//  UIViewController+Additions.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 20.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit
import SVProgressHUD
import SafariServices

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
    
    func displaySimpleAlertWith(title: String) {
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "title-ok".localized, style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
    
    func displaySimpleAlertWith(title: String, message: String, handler: ((UIAlertAction) -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "title-ok".localized, style: .default, handler: handler)
        alertController.addAction(okAction)
        
        present(alertController, animated: true)
    }
    
    func displayProceedAlertWith(title: String, message: String, handler: ((UIAlertAction) -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let proceedAction = UIAlertAction(title: "title-proceed".localized, style: .default, handler: handler)
        alertController.addAction(proceedAction)
        
        let cancelAction = UIAlertAction(title: "title-cancel".localized, style: .cancel, handler: handler)
        alertController.addAction(cancelAction)
        
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

extension UIViewController {
    @discardableResult
    func addContent(_ content: UIViewController, prepareLayout: (UIView) -> Void) -> UIViewController {
        addChild(content)
        prepareLayout(content.view)
        content.didMove(toParent: self)
        return content
    }

    func removeFromContainer(animated: Bool = false, completion: (() -> Void)? = nil) {
        func remove() {
            willMove(toParent: nil)
            removeFromParent()
            view.removeFromSuperview()
        }
        if !animated {
            remove()
            completion?()
            return
        }
        UIView.animate(
            withDuration: 0.2,
            animations: {
                self.view.alpha = 0.0
            },
            completion: { _ in
                remove()
                completion?()
            }
        )
    }
}

extension UIViewController {
    func dismissProgressIfNeeded() {
        if SVProgressHUD.isVisible() {
            SVProgressHUD.dismiss()
        }
    }
}

extension UIViewController {
    var tabBarContainer: TabBarController? {
        var parentContainer = parent

        while parentContainer != nil {
            if let tabBarContainer = parentContainer as? TabBarController {
                return tabBarContainer
            }
            parentContainer = parentContainer?.parent
        }
        return nil
    }
}

extension UIViewController {
    func open(_ url: URL) {
        let safariViewController = SFSafariViewController(url: url)
        present(safariViewController, animated: true, completion: nil)
    }
}
