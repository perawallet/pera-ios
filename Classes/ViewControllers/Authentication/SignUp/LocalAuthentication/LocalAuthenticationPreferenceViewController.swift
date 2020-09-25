//
//  LocalAuthenticationAuthorizationViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 18.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class LocalAuthenticationPreferenceViewController: BaseViewController {
    override var hidesCloseBarButtonItem: Bool {
        return true
    }
    
    private lazy var localAuthenticationPreferenceView = LocalAuthenticationPreferenceView()
    
    private let localAuthenticator = LocalAuthenticator()
    private let accountSetupFlow: AccountSetupFlow
    
    init(accountSetupFlow: AccountSetupFlow, configuration: ViewControllerConfiguration) {
        self.accountSetupFlow = accountSetupFlow
        super.init(configuration: configuration)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    override func prepareLayout() {
        setupLocalAuthenticationPreferenceViewLayout()
    }
    
    override func linkInteractors() {
        localAuthenticationPreferenceView.delegate = self
    }
}

extension LocalAuthenticationPreferenceViewController {
    private func setupLocalAuthenticationPreferenceViewLayout() {
        view.addSubview(localAuthenticationPreferenceView)
        
        localAuthenticationPreferenceView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.bottom.safeEqualToBottom(of: self)
        }
    }
}

extension LocalAuthenticationPreferenceViewController: LocalAuthenticationPreferenceViewDelegate {
    func localAuthenticationPreferenceViewDidTapYesButton(_ localAuthenticationPreferenceView: LocalAuthenticationPreferenceView) {
        if localAuthenticator.isLocalAuthenticationAvailable {
            localAuthenticator.authenticate { error in
                guard error == nil else {
                    return
                }
                self.localAuthenticator.localAuthenticationStatus = .allowed
                self.openNextFlow()
            }
            return
        }
        
        presentDisabledLocalAuthenticationAlert()
    }
    
    private func presentDisabledLocalAuthenticationAlert() {
        let alertController = UIAlertController(
            title: "local-authentication-go-settings-title".localized,
            message: "local-authentication-go-settings-text".localized,
            preferredStyle: .alert
        )
        
        let settingsAction = UIAlertAction(title: "title-go-to-settings".localized, style: .default) { _ in
            UIApplication.shared.openAppSettings()
        }
        
        let cancelAction = UIAlertAction(title: "title-cancel".localized, style: .cancel, handler: nil)
        
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func localAuthenticationPreferenceViewDidTapNoButton(_ localAuthenticationPreferenceView: LocalAuthenticationPreferenceView) {
        openNextFlow()
    }
    
    private func openNextFlow() {
        switch accountSetupFlow {
        case let .initializeAccount(mode):
            guard let mode = mode else {
                break
            }
            switch mode {
            case .create:
                open(.passphraseView(address: "temp"), by: .push)
            case .pair:
                open(.ledgerTutorial(flow: accountSetupFlow), by: .push)
            case .recover:
                 open(.accountRecover(flow: accountSetupFlow), by: .push)
            case .watch:
                open(.watchAccountAddition(flow: accountSetupFlow), by: .push)
            case .rekey:
                break
            }
        case .addNewAccount:
            break
        }
    }
}
