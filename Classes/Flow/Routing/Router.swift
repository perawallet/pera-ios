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
        case .launch:
            if !(sourceViewController is RootViewController) {
                sourceViewController.closeScreen(by: .dismiss, animated: false)
            }
            
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
            
            navigationController.modalPresentationStyle = .fullScreen
            
            rootViewController?.present(navigationController, animated: false, completion: completion)
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
        case .presentWithoutNavigationController:
            if let presentingViewController = self as? StatusBarConfigurable,
                let presentedViewController = viewController as? StatusBarConfigurable,
                presentingViewController.isStatusBarHidden {
                
                presentedViewController.hidesStatusBarWhenPresented = true
                presentedViewController.isStatusBarHidden = true
            }
            
            sourceViewController.present(viewController, animated: animated, completion: completion)
            
        case let .customPresentWithoutNavigationController(presentationStyle, transitionStyle, transitioningDelegate):
            if let presentingViewController = self as? StatusBarConfigurable,
                let presentedViewController = viewController as? StatusBarConfigurable,
                presentingViewController.isStatusBarHidden {
                
                presentedViewController.hidesStatusBarWhenPresented = true
                presentedViewController.isStatusBarHidden = true
            }
            
            if let aPresentationStyle = presentationStyle {
                viewController.modalPresentationStyle = aPresentationStyle
            }
            if let aTransitionStyle = transitionStyle {
                viewController.modalTransitionStyle = aTransitionStyle
            }
            viewController.modalPresentationCapturesStatusBarAppearance = true
            viewController.transitioningDelegate = transitioningDelegate
            
            sourceViewController.present(viewController, animated: animated, completion: completion)
        case .set:
            if let currentViewController = self as? StatusBarConfigurable,
                let nextViewController = viewController as? StatusBarConfigurable {
                
                let isStatusBarHidden = currentViewController.isStatusBarHidden
                
                nextViewController.hidesStatusBarWhenAppeared = isStatusBarHidden
                nextViewController.isStatusBarHidden = isStatusBarHidden
            }
            
            guard let navigationController = sourceViewController.navigationController else {
                return nil
            }
            
            var viewControllers = navigationController.viewControllers
            
            let firstViewController = viewControllers[0]
            
            viewControllers = [firstViewController, viewController]
            
            navigationController.setViewControllers(viewControllers, animated: animated)
        }
        
        guard let navigationController = viewController as? UINavigationController,
            let firstViewController = navigationController.viewControllers.first as? T else {
                return viewController as? T
        }
        
        return firstViewController
    }
    
    // swiftlint:disable function_body_length
    private func buildViewController<T: UIViewController>(for screen: Screen) -> T? {
        guard let rootViewController = UIApplication.shared.rootViewController() else {
            return nil
        }
        
        let viewController: UIViewController
        
        let configuration = ViewControllerConfiguration(api: rootViewController.appConfiguration.api,
                                                        session: rootViewController.appConfiguration.session)
        
        switch screen {
        case let .introduction(mode):
            let introductionViewController = IntroductionViewController(configuration: configuration)
            introductionViewController.mode = mode
            
            viewController = introductionViewController
        case let .choosePassword(mode, route):
            viewController = ChoosePasswordViewController(mode: mode, route: route, configuration: configuration)
        case .localAuthenticationPreference:
            viewController = LocalAuthenticationPreferenceViewController(configuration: configuration)
        case let .passphraseView(address):
            viewController = PassPhraseBackUpViewController(address: address, configuration: configuration)
        case .passPhraseVerify:
            viewController = PassPhraseVerifyViewController(configuration: configuration)
        case .accountNameSetup:
            viewController = AccountNameSetupViewController(configuration: configuration)
        case let .accountRecover(mode):
            let accountRecoverViewController = AccountRecoverViewController(configuration: configuration)
            accountRecoverViewController.mode = mode
            
            viewController = accountRecoverViewController
        case .qrScanner:
            viewController = QRScannerViewController(configuration: configuration)
        case let .qrGenerator(title, text, mode):
            let qrCreationController = QRCreationViewController(configuration: configuration, qrText: text)
            qrCreationController.mode = mode
            qrCreationController.title = title
            
            viewController = qrCreationController
        case .home:
            viewController = TabBarController(configuration: configuration)
        case .accountList:
            viewController = AccountListViewController(configuration: configuration)
        case let .options(account):
            viewController = OptionsViewController(account: account, configuration: configuration)
        case let .editAccount(account):
            viewController = EditAccountViewController(account: account, configuration: configuration)
        case .contactSelection:
            viewController = ContactSelectionViewController(configuration: configuration)
            viewController.hidesBottomBarWhenPushed = true
        case let .addContact(mode):
            viewController = AddContactViewController(mode: mode, configuration: configuration)
        case let .contactDetail(contact):
            viewController = ContactInfoViewController(contact: contact, configuration: configuration)
        case let .contactQRDisplay(contact):
            viewController = ContactQRDisplayViewController(contact: contact, configuration: configuration)
        case let .sendAlgos(account, receiver):
            viewController = SendAlgosViewController(account: account, receiver: receiver, configuration: configuration)
        case let .sendAlgosPreview(manager, transaction, receiver):
            viewController = SendAlgosPreviewViewController(
                transactionManager: manager,
                transaction: transaction,
                receiver: receiver,
                configuration: configuration
            )
        case let .requestAlgos(account):
            viewController = RequestAlgosViewController(account: account, configuration: configuration)
        case let .requestAlgosPreview(transaction):
            viewController = RequestAlgosPreviewViewController(transaction: transaction, configuration: configuration)
        case let .historyResults(draft):
            viewController = HistoryResultsViewController(draft: draft, configuration: configuration)
        case let .nodeSettings(mode):
            viewController = NodeSettingsViewController(mode: mode, configuration: configuration)
        case .addNode:
            viewController = AddNodeViewController(mode: .new, configuration: configuration)
        case let .editNode(node):
            viewController = AddNodeViewController(mode: .edit(node: node), configuration: configuration)
        case .splash:
            viewController = SplashViewController(configuration: configuration)
        case let .transactionDetail(account, transaction, transactionType):
            viewController = TransactionDetailViewController(
                account: account,
                transaction: transaction,
                transactionType: transactionType,
                configuration: configuration
            )
        case let .auctionDetail(auction, user, auctionStatus):
            viewController = AuctionDetailViewController(
                auction: auction,
                user: user,
                auctionStatus: auctionStatus,
                configuration: configuration
            )
        case let .pastAuctionDetail(auction, user, auctionStatus):
            viewController = PastAuctionDetailViewController(
                auction: auction,
                user: user,
                auctionStatus: auctionStatus,
                configuration: configuration
            )
        case let .balance(user):
            viewController = BalanceViewController(user: user, configuration: configuration)
        case let .deposit(user):
            viewController = DepositViewController(user: user, configuration: configuration)
        case .feedback:
            viewController = FeedbackViewController(configuration: configuration)
        case let .assetDetail(account, assetDetail):
            viewController = AssetDetailViewController(account: account, configuration: configuration, assetDetail: assetDetail)
        case let .addAsset(account):
            viewController = AssetAdditionViewController(account: account, configuration: configuration)
        case let .removeAsset(account):
            viewController = AssetRemovalViewController(account: account, configuration: configuration)
        case let .assetActionConfirmation(assetAlertDraft):
            viewController = AssetActionConfirmationViewController(assetAlertDraft: assetAlertDraft, configuration: configuration)
        case let .assetSupportAlert(assetAlertDraft):
            viewController = AssetSupportAlertViewController(assetAlertDraft: assetAlertDraft, configuration: configuration)
        case let .assetCancellableSupportAlert(assetAlertDraft):
            viewController = AssetCancellableSupportAlertViewController(assetAlertDraft: assetAlertDraft, configuration: configuration)
        case let .rewardDetail(account):
            viewController = RewardDetailViewController(account: account, configuration: configuration)
        }
        
        return viewController as? T
    }
    // swiftlint:enable function_body_length
}
