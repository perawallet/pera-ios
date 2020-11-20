//
//  NavigationController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 14.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .default
        }
    }
    
    override var childForStatusBarHidden: UIViewController? {
        return topViewController
    }
    
    override var childForStatusBarStyle: UIViewController? {
        return topViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureAppearance()
        linkInteractors()
    }
}

extension NavigationController {
    private func configureAppearance() {
        configureNavigationBarAppearance()
        configureViewAppearance()
    }
    
    private func configureNavigationBarAppearance() {
        navigationBar.isTranslucent = false
        navigationBar.barTintColor = Colors.Background.primary
        navigationBar.tintColor = Colors.Background.primary
        navigationBar.shadowImage = UIImage()
        navigationBar.layoutMargins = .zero
        navigationBar.setBackgroundImage(UIImage(), for: .default)
    }
    
    private func configureViewAppearance() {
        view.backgroundColor = Colors.Background.primary
    }
}

extension NavigationController {
    private func linkInteractors() {
        delegate = self
        interactivePopGestureRecognizer?.delegate = self
    }
}

extension NavigationController: UINavigationControllerDelegate {
}

extension NavigationController: UIGestureRecognizerDelegate {
}
