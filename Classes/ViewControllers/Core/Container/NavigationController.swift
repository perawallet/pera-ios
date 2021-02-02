//
//  NavigationController.swift

import UIKit

class NavigationController: UINavigationController {
    
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
