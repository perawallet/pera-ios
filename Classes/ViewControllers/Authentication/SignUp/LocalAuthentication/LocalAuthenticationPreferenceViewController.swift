// Copyright 2019 Algorand, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//  LocalAuthenticationAuthorizationViewController.swift

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
                open(.animatedTutorial(flow: accountSetupFlow, tutorial: .recover, isActionable: false), by: .push)
            case .watch:
                open(.watchAccountAddition(flow: accountSetupFlow), by: .push)
            case .rekey:
                break
            case .add:
                break
            case .transfer:
                break
            }
        case .addNewAccount:
            break
        }
    }
}
