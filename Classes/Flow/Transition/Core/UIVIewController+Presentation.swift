//
//  UIVIewController+Presentation.swift

import UIKit

extension UIViewController {
    var modalPresenter: ModalPresenterInteractable? {
        return (navigationController ?? self).presentationController as? ModalPresenterInteractable
    }
    
    var isModal: Bool {
        return presentingViewController != nil ||
            navigationController?.presentingViewController?.presentedViewController == navigationController ||
            tabBarController?.presentingViewController is UITabBarController
     }
}
