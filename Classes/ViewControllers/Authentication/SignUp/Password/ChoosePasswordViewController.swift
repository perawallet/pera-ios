//
//  ChoosePasswordViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 18.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit
import AVFoundation
import SVProgressHUD

class ChoosePasswordViewController: BaseViewController {
    
    private lazy var choosePasswordView: ChoosePasswordView = {
        let view = ChoosePasswordView()
        return view
    }()
    
    private let viewModel: ChoosePasswordViewModel
    private let mode: Mode
    private let route: Screen?
    
    private let localAuthenticator = LocalAuthenticator()
    
    private lazy var accountManager: AccountManager? = {
        guard let api = self.api,
            let user = session?.authenticatedUser,
            mode == .login else {
            return nil
        }
        
        let manager = AccountManager(api: api)
        manager.user = user
        return manager
    }()
    
    // MARK: Initialization
    
    init(mode: Mode, route: Screen?, configuration: ViewControllerConfiguration) {
        self.mode = mode
        self.route = route
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
                    
                    self.launchHome()
                }
            }
            
            return
        }
    }
    
    deinit {
        
    }
    
    override func configureNavigationBarAppearance() {
        if mode == .resetPassword {
            let closeBarButtonItem = ALGBarButtonItem(kind: .close) {
                self.dismissScreen()
            }
            
            leftBarButtonItems = [closeBarButtonItem]
        }
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        
        viewModel.configure(choosePasswordView)
        
        if mode == .login {
            return
        }
        
        switch mode {
        case .login:
            return
        case .resetPassword, .resetVerify:
            title = "password-change-title".localized
            return
        default:
            break
        }
        
        title = "choose-password-title".localized
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        
        view.addSubview(choosePasswordView)
        
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
                open(.choosePassword(mode: .verify(password), route: nil), by: .push)
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
                    choosePasswordView.numpadView.isUserInteractionEnabled = false
                    
                    self.launchHome()
                } else {
                    AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                    self.viewModel.displayWrongPasswordState(choosePasswordView)
                }
            }
            
        case .resetPassword:
            viewModel.configureSelection(in: choosePasswordView, for: value) { password in
                open(.choosePassword(mode: .resetVerify(password), route: nil), by: .push)
            }
            
        case let .resetVerify(previousPassword):
            viewModel.configureSelection(in: choosePasswordView, for: value) { password in
                if password != previousPassword {
                    displaySimpleAlertWith(title: "password-verify-fail-title".localized, message: "password-verify-fail-message".localized)
                    self.viewModel.reset(choosePasswordView)
                    return
                }
                
                self.configuration.session?.saveApp(password: password)
                
                dismissScreen()
            }
        }
    }
    
    func choosePasswordViewDidTapLogoutButton(_ choosePasswordView: ChoosePasswordView) {
        let alertController = UIAlertController(title: "logout-warning-title".localized,
                                                message: "logout-warning-message".localized,
                                                preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "title-cancel-lowercased".localized, style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let deleteAction = UIAlertAction(
            title: "logout-action-delete-title".localized,
            style: .destructive) { _ in
                self.session?.reset()
                
                self.open(.introduction(mode: .initialize), by: .launch, animated: false)
        }
        alertController.addAction(deleteAction)
        
        present(alertController, animated: true)
    }
    
    fileprivate func launchHome() {
        SVProgressHUD.show(withStatus: "Loading")
        
        accountManager?.fetchAllAccounts {
            
            SVProgressHUD.showSuccess(withStatus: "Done")
            
            SVProgressHUD.dismiss(withDelay: 2.0) {
                self.open(.home(route: self.route), by: .launch)
                
                DispatchQueue.main.async {
                    UIApplication.shared.appDelegate?.validateAccountManagerFetchPolling()
                }
            }
        }
    }
}

extension ChoosePasswordViewController {
    
    enum Mode: Equatable {
        case setup
        case verify(String)
        case login
        case resetPassword
        case resetVerify(String)
    }
}
