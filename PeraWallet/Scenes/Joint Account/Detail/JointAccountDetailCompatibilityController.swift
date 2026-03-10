// Copyright 2022-2026 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   JointAccountDetailCompatibilityController.swift

import SwiftUI

final class JointAccountDetailController: UIHostingController<JointAccountDetail> {
    
    // MARK: - Properties
    
    private lazy var copyToClipboardViewController: CopyToClipboardController = ALGCopyToClipboardController(toastPresentationController: ToastPresentationController(presentingView: view))
    
    // MARK: - Initializers
    
    override init(rootView: JointAccountDetail) {
        super.init(rootView: rootView)
        setupController()
        setupCallbacks()
    }
    
    @MainActor @preconcurrency required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setups
    
    private func setupController() {
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
        view.backgroundColor = .clear
    }
    
    private func setupCallbacks() {
        rootView.onCopyAddressAction = { [weak self] in
            self?.copyToClipboardViewController.copyAddress($0)
        }
    }
}
