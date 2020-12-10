//
//  UIVIewController+Presentation.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 26.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

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
