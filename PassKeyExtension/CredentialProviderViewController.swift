// Copyright 2025 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import AuthenticationServices
import Firebase
import SwiftUI
import UIKit

@available(iOS 17, *)
class CredentialProviderViewController: ASCredentialProviderViewController {
    
    let contentView = UIHostingController(rootView: PassKeyCredentialView())
    let credentialService: CredentialProviderService
    var startTime = Date()
    
    init() {
        FirebaseApp.configure()
        credentialService = CredentialProviderService()
        super.init()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        FirebaseApp.configure()
        credentialService = CredentialProviderService()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        self.modalPresentationStyle = .popover
        super.viewDidLoad()
    }
    
    override func prepareInterface(forPasskeyRegistration request: ASCredentialRequest) {
        guard let credentialRequest = request as? ASPasskeyCredentialRequest else {
            self.setError("The passkey appears to be invalid.")
            return
        }
        
        setupUI()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            Task {
                let outcome = await self?.credentialService.handleRegistrationRequest(credentialRequest)
                if let error = outcome?.error {
                    self?.setError(error)
                    return
                }
                if let credential = outcome?.credential {
                    await self?.extensionContext.completeRegistrationRequest(using: credential)
                }
            }
        }
    }
    
    override func prepareCredentialList(
        for id: [ASCredentialServiceIdentifier],
        requestParameters: ASPasskeyCredentialRequestParameters
    ) {
        setupUI()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            Task {
                let outcome = await self?.credentialService.handleAuthenticationRequest(requestParameters)
                if let error = outcome?.error {
                    self?.setError(error)
                    return
                }
                if let credential = outcome?.credential {
                    await self?.extensionContext.completeAssertionRequest(using: credential)
                }
            }
        }
    }
    
    override func prepareInterfaceForExtensionConfiguration() {
        // This method is called when the user enables the extension in Settings.
        // You can present a configuration UI here if needed.
        // For now, we will just dismiss the view controller.
        extensionContext.completeExtensionConfigurationRequest()
    }
    
    private func setupUI() {
        addChild(contentView)
        view.addSubview(contentView.view)
        self.view.backgroundColor = .white
        self.contentView.rootView.viewModel.dismissHandler = {
            self.extensionContext.cancelRequest(withError: NSError(domain: ASExtensionErrorDomain,
                                                                    code: ASExtensionError.userCanceled.rawValue))
        }
        self.contentView.view.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        self.contentView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        self.contentView.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        self.contentView.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }
    
    private func setError(_ error: String) {
        contentView.rootView.viewModel.error = error
    }
}
