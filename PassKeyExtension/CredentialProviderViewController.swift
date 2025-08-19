// Copyright 2022-2025 Pera Wallet, LDA

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
final class CredentialProviderViewController: ASCredentialProviderViewController {
    
    // MARK: - Properties
    private let contentView = UIHostingController(rootView: PassKeyCredentialView())
    private let credentialService: CredentialProviderService
    private var startTime = Date()
    
    // MARK: - Initialisers
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
    
    // MARK: - Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        modalPresentationStyle = .popover
    }
    
    override func prepareInterface(forPasskeyRegistration request: ASCredentialRequest) {
        guard let credentialRequest = request as? ASPasskeyCredentialRequest else {
            showError("The passkey appears to be invalid.")
            return
        }
        
        setupUI()
        Task {
            do {
                let credential = try await credentialService.handleRegistrationRequest(credentialRequest)
                await self.extensionContext.completeRegistrationRequest(using: credential)
            } catch {
                showError(error.localizedDescription)
            }
        }
    }
    
    override func prepareCredentialList(
        for id: [ASCredentialServiceIdentifier],
        requestParameters: ASPasskeyCredentialRequestParameters
    ) {
        setupUI()
        Task {
            do {
                let credential = try await credentialService.handleAuthenticationRequest(requestParameters)
                await extensionContext.completeAssertionRequest(using: credential)
            } catch {
                showError(error.localizedDescription)
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
        view.backgroundColor = .white
        contentView.rootView.viewModel.dismissHandler = {
            self.extensionContext.cancelRequest(withError: NSError(domain: ASExtensionErrorDomain,
                                                                    code: ASExtensionError.userCanceled.rawValue))
        }
        contentView.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentView.view.topAnchor.constraint(equalTo: view.topAnchor),
            contentView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentView.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            contentView.view.rightAnchor.constraint(equalTo: view.rightAnchor),
        ])
    }
    
    private func showError(_ error: String) {
        contentView.rootView.viewModel.error = error
    }
}
