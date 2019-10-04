//
//  SplashViewController.swift
//  algorand
//
//  Created by Omer Emre Aslan on 22.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class SplashViewController: BaseViewController {
    
    private lazy var imageView: UIImageView = {
        UIImageView(image: img("icon-logo-small"))
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        UIActivityIndicatorView(style: .gray)
    }()
    
    override var shouldShowNavigationBar: Bool {
        return false
    }
    
    private lazy var nodeManager: NodeManager? = {
        guard let api = self.api else {
            return nil
        }
        let manager = NodeManager(api: api)
        return manager
    }()
    
    override func configureAppearance() {
        let safeAreaView = UIView()
        safeAreaView.backgroundColor = .white
        view.backgroundColor = .white
        
        view.addSubview(safeAreaView)
        safeAreaView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        safeAreaView.addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        safeAreaView.addSubview(loadingIndicator)
        
        loadingIndicator.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        
        fetchNodes()
    }
    
    private func fetchNodes() {
        loadingIndicator.startAnimating()
        
        guard let session = self.session else {
            return
        }
        
        guard let rootController = UIApplication.shared.rootViewController() else {
            return
        }
        
        nodeManager?.checkNodes { isFinished in
            DispatchQueue.main.async {
                self.loadingIndicator.stopAnimating()
            }
            
            if isFinished {
                if !session.isValid {
                    if session.hasPassword() &&
                        session.authenticatedUser != nil {
                        
                        self.dismiss(animated: false) {
                            rootController.open(
                                .choosePassword(mode: .login, route: nil),
                                by: .customPresent(presentationStyle: .fullScreen, transitionStyle: nil, transitioningDelegate: nil)
                            )
                        }
                    } else {
                        session.reset()
                        
                        self.dismiss(animated: false) {
                            rootController.open(.introduction(mode: .initialize), by: .launch, animated: false)
                        }
                    }
                } else {
                    self.dismiss(animated: false) {
                        UIApplication.shared.rootViewController()?.setupTabBarController()
                    }
                }
            } else {
                let viewController = self.open(.nodeSettings(mode: .checkHealth), by: .present) as? NodeSettingsViewController
                
                viewController?.delegate = self
            }
        }
    }
}

// MARK: - NodeSettingsViewControllerDelegate
extension SplashViewController: NodeSettingsViewControllerDelegate {
    func nodeSettingsViewControllerDidUpdateNode(_ nodeSettingsViewController: NodeSettingsViewController) {
        self.fetchNodes()
    }
}
