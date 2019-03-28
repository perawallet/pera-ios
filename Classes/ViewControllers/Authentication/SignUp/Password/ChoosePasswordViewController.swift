//
//  ChoosePasswordViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 18.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class ChoosePasswordViewController: BaseScrollViewController {
    
    private lazy var choosePasswordView: ChoosePasswordView = {
        let view = ChoosePasswordView()
        return view
    }()
    
    private let viewModel: ChoosePasswordViewModel
    private let mode: Mode
    
    private let localAuthenticator = LocalAuthenticator()
    
    // MARK: Initialization
    
    init(mode: Mode, configuration: ViewControllerConfiguration) {
        self.mode = mode
        self.viewModel = ChoosePasswordViewModel(mode: mode)
        
        super.init(configuration: configuration)
    }
    
    // MARK: Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if mode == .login {
            if localAuthenticator.localAuthenticationStatus == .allowed {
                localAuthenticator.authenticate { error in
                    guard error == nil else {
                        return
                    }
                    self.open(.home, by: .present, animated: false)
                }
            }
            
            return
        }
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        
        viewModel.configure(choosePasswordView)
        
        if mode == .login {
            return
        }
        
        title = "choose-password-title".localized
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        
        contentView.addSubview(choosePasswordView)
        
        choosePasswordView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override func linkInteractors() {
        super.linkInteractors()
        
        choosePasswordView.delegate = self
    }
}

extension ChoosePasswordViewController: ChoosePasswordViewDelegate {
    
    func choosePasswordView(_ choosePasswordView: ChoosePasswordView, didSelect value: NumpadValue) {
        switch mode {
        case .setup:
            viewModel.configureSelection(in: choosePasswordView, for: value) { password in
                open(.choosePassword(.verify(password)), by: .push)
            }
        case let .verify(previousPassword):
            viewModel.configureSelection(in: choosePasswordView, for: value) { password in
                if password != previousPassword {
                    displaySimpleAlertWith(title: "password-verify-fail-title".localized, message: "password-verify-fail-message".localized)
                    self.viewModel.reset(choosePasswordView)
                    return
                }
                
                self.configuration.session?.saveApp(password: password)
                
                open(.localAuthenticationPreference, by: .push)
            }
        case .login:
            viewModel.configureSelection(in: choosePasswordView, for: value) { password in
                
                if session?.isPasswordMatching(with: password) ?? false {
                    self.open(.home, by: .present, animated: false)
                }
            }
        }
    }
    
    func choosePasswordViewDidTapLogoutButton(_ choosePasswordView: ChoosePasswordView) {
        session?.reset()
        
        open(.introduction, by: .present, animated: false)
    }
}

extension ChoosePasswordViewController {
    
    enum Mode: Equatable {
        case setup
        case verify(String)
        case login
    }
}
