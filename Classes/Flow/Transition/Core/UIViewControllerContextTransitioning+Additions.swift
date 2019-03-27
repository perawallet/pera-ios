//
//  UIViewControllerContextTransitioning+Additions.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 26.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

extension UIViewControllerContextTransitioning {
    
    var fromViewController: UIViewController? {
        return viewController(forKey: .from)
    }
    
    var fromPresentableViewController: ModalPresentableViewController? {
        return fromViewController as? ModalPresentableViewController
    }
    
    var toViewController: UIViewController? {
        return viewController(forKey: .to)
    }
    
    var toPresentableViewController: ModalPresentableViewController? {
        return toViewController as? ModalPresentableViewController
    }
    
    var animatedViewController: UIViewController? {
        return isPresenting ? toViewController : fromViewController
    }
    
    var animatedPresentableViewController: ModalPresentableViewController? {
        return animatedViewController as? ModalPresentableViewController
    }
    
    var fromView: UIView? {
        return view(forKey: .from)
    }
    
    var toView: UIView? {
        return view(forKey: .to)
    }
    
    var animatedView: UIView? {
        return isPresenting ? toView : fromView
    }
    
    var isPresenting: Bool {
        return toViewController?.presentingViewController == fromViewController
    }
    
    var initialFrame: CGRect {
        return animatedViewController.map { initialFrame(for: $0) } ?? .zero
    }
    
    var finalFrame: CGRect {
        return animatedViewController.map { finalFrame(for: $0) } ?? .zero
    }
}
