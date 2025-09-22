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
import SwiftUI
import UIKit

@available(iOS 17, *)
final class CredentialProviderViewController: ASCredentialProviderViewController {
    
    // MARK: - Properties
    private let viewModel = CredentialProviderViewModel()
    private let contentView: UIHostingController<PassKeyCredentialView>
    
    
    // MARK: - Initialisers
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        contentView = UIHostingController(rootView: PassKeyCredentialView(viewModel: viewModel))
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
            viewModel.error = "liquid-auth-invalid-passkey-found"
            return
        }
        
        //for some reason the UI doesn't show if this is done in viewDidLoad as would be customary
        setupUI()
        
        //We need a delay here because FaceID only works when app is foregrounded, but sometimes
        //the extension UI takes a second to fully foreground and FaceID fails
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            Task {
                if let credential = await self?.viewModel.handleRegistrationRequest(credentialRequest) {
                    await self?.extensionContext.completeRegistrationRequest(using: credential)
                }
            }
        }
        
    }
    
    override func prepareCredentialList(
        for id: [ASCredentialServiceIdentifier],
        requestParameters: ASPasskeyCredentialRequestParameters
    ) {
        //for some reason the UI doesn't show if this is done in viewDidLoad as would be customary
        setupUI()
        
        //We need a delay here because FaceID only works when app is foregrounded, but sometimes
        //the extension UI takes a second to fully foreground and FaceID fails
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            Task {
                if let credential = await self?.viewModel.handleAuthenticationRequest(requestParameters) {
                    await self?.extensionContext.completeAssertionRequest(using: credential)
                }
            }
        }
    }
    
    override func prepareInterfaceForExtensionConfiguration() {
        // For now, we will just dismiss the view controller - in future we can show a UI in the settings/configuration screen if needed
        extensionContext.completeExtensionConfigurationRequest()
    }
    
    private func setupUI() {
        //we need to make this method reentrant because of the weird race condition mentioned above
        guard contentView.parent == nil else {
            return
        }
        
        addChild(contentView)
        view.addSubview(contentView.view)
        view.backgroundColor = .white
        contentView.view.translatesAutoresizingMaskIntoConstraints = false
        
        viewModel.onDismissed = { [weak self] in
            self?.extensionContext.cancelRequest(withError: NSError(domain: ASExtensionErrorDomain,
                                                                    code: ASExtensionError.userCanceled.rawValue))
        }
        
        NSLayoutConstraint.activate([
            contentView.view.topAnchor.constraint(equalTo: view.topAnchor),
            contentView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentView.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            contentView.view.rightAnchor.constraint(equalTo: view.rightAnchor),
        ])
    }
}
