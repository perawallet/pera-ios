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
    
    override var shouldShowNavigationBar: Bool {
        return false
    }
    
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
        
        startFlow()
    }
    
    private func startFlow() {
        guard let session = self.session else {
            return
        }
        
        guard let rootViewController = UIApplication.shared.rootViewController() else {
            return
        }
        
        if !session.isValid {
            if session.hasPassword() && session.authenticatedUser != nil {
                self.dismiss(animated: false) {
                    rootViewController.open(
                        .choosePassword(mode: .login, route: nil),
                        by: .customPresent(presentationStyle: .fullScreen, transitionStyle: nil, transitioningDelegate: nil)
                    )
                }
            } else {
                session.reset()
                self.dismiss(animated: false) {
                    rootViewController.open(.introduction(mode: .initialize), by: .launch, animated: false)
                }
            }
        } else {
            self.dismiss(animated: false) {
                rootViewController.setupTabBarController()
            }
        }
    }
}
