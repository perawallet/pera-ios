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

//   JointAccountPendingTransactionOverlayHostingController.swift

import SwiftUI

final class JointAccountPendingTransactionOverlayHostingController: UIHostingController<JointAccountPendingTransactionOverlay> {
    
    var onDismiss: (() -> Void)?
    var onCancelTransaction: (() -> Void)?
    var onJointAccountAnalyticsCall: ((JointAccountAnalyticEvent) -> Void)?
    var onSignWithLedger: ((_ signerAddress: String) -> Void)?
    
    // MARK: - Initialisers
    
    override init(rootView: JointAccountPendingTransactionOverlay) {
        super.init(rootView: rootView)
        setupController()
        setupCallbacks()
    }
    
    @available(*, unavailable) @preconcurrency @MainActor
    required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setups
    
    private func setupController() {
        view.backgroundColor = .clear
    }
    
    private func setupCallbacks() {
        
        rootView.onDismiss = { [weak self] in
            self?.onDismiss?()
        }
        
        rootView.onCancelTransactionAction = { [weak self] in
            self?.onCancelTransaction?()
        }
        
        rootView.onJointAccountAnalyticsCall = { [weak self] in
            self?.onJointAccountAnalyticsCall?($0)
        }
        
        rootView.onSignWithLedgerAction = { [weak self] in
            self?.onSignWithLedger?($0)
        }
    }
    
    // MARK: - Actions
    
    func cancelTransaction() {
        rootView.cancelTransaction()
    }
}
