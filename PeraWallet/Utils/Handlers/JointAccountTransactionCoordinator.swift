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

//   JointAccountTransactionCoordinator.swift

import pera_wallet_core
import UIKit

final class JointAccountTransactionCoordinator {
    
    enum Action {
        case connectionWithLedgerNeeded(transactionController: TransactionController)
        case overlayDismissed
        case failure(error: Error, transactionController: TransactionController)
    }
    
    // MARK: - Properties
    
    @Published private(set) var action: Action?
    private let jointAccountTransactionHandler: JointAccountTransactionHandler
    
    // MARK: - Initialisers
    
    init(accountsService: AccountsServiceable) {
        jointAccountTransactionHandler = JointAccountTransactionHandler(accountsService: accountsService)
    }
    
    // MARK: - Actions
    
    @MainActor
    func handleTransaction(jointAccount: Account, transactionType: JointAccountTransactionHandler.TransactionType, sharedDataController: SharedDataController, transactionController: TransactionController, presenter: UIViewController) {
        
        if jointAccountTransactionHandler.isConnectionWithLedgerRequired(jointAccount: jointAccount) {
            action = .connectionWithLedgerNeeded(transactionController: transactionController)
        }
        
        Task {
            do {
                let result = try await jointAccountTransactionHandler.handleTransaction(jointAccount: jointAccount, type: transactionType, sharedDataController: sharedDataController, transactionController: transactionController)
                openPendingTransactionOverlay(signRequestMetadata: result.signRequestMetadata, presenter: presenter)
            } catch {
                action = .failure(error: error, transactionController: transactionController)
            }
        }
    }
    
    private func openPendingTransactionOverlay(signRequestMetadata: SignRequestMetadata?, presenter: UIViewController) {
        
        guard let signRequestMetadata else {
            action = .overlayDismissed
            return
        }
        
        let viewController = JointAccountPendingTransactionOverlayConstructor.buildViewController(signRequestMetadata: signRequestMetadata) { [weak self] in
            self?.action = .overlayDismissed
        }
        
        Task { @MainActor in
            presenter.present(viewController, animated: true)
        }
    }
}
