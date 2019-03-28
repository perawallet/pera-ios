//
//  Router.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 14.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

typealias ScreenTransitionCompletion = () -> Void

class Router {

    private weak var rootViewController: RootViewController?
    
    init(rootViewController: RootViewController) {
        self.rootViewController = rootViewController
    }
    
    func route<T: UIViewController>(
        to screen: Screen,
        from sourceViewController: UIViewController,
        by style: Screen.Transition.Open,
        animated: Bool = true,
        then completion: ScreenTransitionCompletion? = nil
    ) -> T? {
        
        guard let viewController = buildViewController(for: screen) else {
            return nil
        }
        
        switch style {
        case .push:
            if let currentViewController = self as? StatusBarConfigurable,
                let nextViewController = viewController as? StatusBarConfigurable {
                
                let isStatusBarHidden = currentViewController.isStatusBarHidden
                
                nextViewController.hidesStatusBarWhenAppeared = isStatusBarHidden
                nextViewController.isStatusBarHidden = isStatusBarHidden
            }
            
            sourceViewController.navigationController?.pushViewController(viewController, animated: animated)
        case .present,
             .customPresent:
            let navigationController: NavigationController
            
            if let navController = viewController as? NavigationController {
                navigationController = navController
            } else {
                if let presentingViewController = self as? StatusBarConfigurable,
                    let presentedViewController = viewController as? StatusBarConfigurable,
                    presentingViewController.isStatusBarHidden {
                    
                    presentedViewController.hidesStatusBarWhenPresented = true
                    presentedViewController.isStatusBarHidden = true
                }
                
                navigationController = NavigationController(rootViewController: viewController)
            }
            
            if case .customPresent(
                let presentationStyle,
                let transitionStyle,
                let transitioningDelegate) = style {
                
                if let aPresentationStyle = presentationStyle {
                    navigationController.modalPresentationStyle = aPresentationStyle
                }
                if let aTransitionStyle = transitionStyle {
                    navigationController.modalTransitionStyle = aTransitionStyle
                }
                navigationController.modalPresentationCapturesStatusBarAppearance = true
                navigationController.transitioningDelegate = transitioningDelegate
            }
            
            sourceViewController.present(navigationController, animated: animated, completion: completion)
        }
        
        guard let navigationController = viewController as? UINavigationController,
            let firstViewController = navigationController.viewControllers.first as? T else {
                return viewController as? T
        }
        
        return firstViewController
    }
    
    private func buildViewController<T: UIViewController>(for screen: Screen) -> T? {
        guard let rootViewController = UIApplication.shared.rootViewController() else {
            return nil
        }
        
        let viewController: UIViewController
        
        let configuration = ViewControllerConfiguration(api: rootViewController.appConfiguration.api,
                                                        session: rootViewController.appConfiguration.session)
        
        switch screen {
        case .introduction:
            viewController = IntroductionViewController(configuration: configuration)
        case .welcome:
            viewController = WelcomeViewController(configuration: configuration)
        case let .choosePassword(mode):
            viewController = ChoosePasswordViewController(mode: mode, configuration: configuration)
        case .localAuthenticationPreference:
            viewController = LocalAuthenticationPreferenceViewController(configuration: configuration)
        case .passPhraseBackUp:
            viewController = PassPhraseBackUpViewController(configuration: configuration)
        case .passPhraseVerify:
            viewController = PassPhraseVerifyViewController(configuration: configuration)
        case .accountNameSetup:
            viewController = AccountNameSetupViewController(configuration: configuration)
        case .accountRecover:
            viewController = AccountRecoverViewController(configuration: configuration)
        case .qrScanner:
            viewController = QRScannerViewController(configuration: configuration)
        case .qrGenerator(let text, let mode):
            let qrCreationController = QRCreationViewController(configuration: configuration, qrText: text)
            qrCreationController.mode = mode
            
            viewController = qrCreationController
        case .home:
            viewController = TabBarController(configuration: configuration)
        case .accountList:
            viewController = AccountListViewController(configuration: configuration)
        case .options:
            viewController = OptionsViewController(configuration: configuration)
        case .editAccount:
            viewController = EditAccountViewController(configuration: configuration)
        }
        
        return viewController as? T
    }
}
