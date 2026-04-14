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
    private var bottomSheetTransition: BottomSheetTransition?
    
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
                openPendingTransactionOverlay(signRequestMetadata: result.signRequestMetadata, presenter: presenter, jointAccount: jointAccount, transactionType: transactionType, sharedDataController: sharedDataController)
            } catch {
                action = .failure(error: error, transactionController: transactionController)
            }
        }
    }
    
    private func openPendingTransactionOverlay(signRequestMetadata: SignRequestMetadata?, presenter: UIViewController,
                                               jointAccount: Account, transactionType: JointAccountTransactionHandler.TransactionType, sharedDataController: SharedDataController) {
        
        guard let signRequestMetadata else {
            action = .overlayDismissed
            return
        }
        
        var confirmationDialogPresenter: JointAccountPendingTransactionOverlayViewController?
        
        let onDismiss: (() -> Void)? = { [weak self] in
            self?.action = .overlayDismissed
        }
        
        let onCancelTransaction: (() -> Void)? = { [weak self] in
            guard let confirmationDialogPresenter else { return }
            self?.openTransactionCancellationDialog(jointAccount: jointAccount, transactionType: transactionType, presenter: confirmationDialogPresenter, sharedDataController: sharedDataController)
        }
        
        Task { @MainActor in
            let viewController = JointAccountPendingTransactionOverlayConstructor.buildViewController(
                signRequestMetadata: signRequestMetadata,
                isCancelTransactionAvailable: true,
                onDismiss: onDismiss,
                onCancelTransaction: onCancelTransaction,
                onJointAccountAnalyticsCall: nil
            )
            confirmationDialogPresenter = viewController
            presenter.present(viewController, animated: true)
        }
    }
    
    private func openTransactionCancellationDialog(jointAccount: Account, transactionType: JointAccountTransactionHandler.TransactionType,
                                                   presenter: JointAccountPendingTransactionOverlayViewController, sharedDataController: SharedDataController) {
        
        let configurator = BottomWarningViewConfigurator(
            image: .iconIncomingAsaError,
            title: String(localized: "shared-account-cancel-transaction-confirmation-title"),
            description: .plain(String(localized: "shared-account-cancel-transaction-confirmation-description")),
            primaryActionButtonTitle: String(localized: "shared-account-cancel-transaction-confirmation-primary-button-title"),
            secondaryActionButtonTitle: String(localized: "shared-account-cancel-transaction-confirmation-secondary-button-title"),
            primaryAction: { [weak self] in self?.cancelTransaction(transactionType: transactionType, jointAccount: jointAccount, overlay: presenter, sharedDataController: sharedDataController) }
        )
        
        bottomSheetTransition = BottomSheetTransition(presentingViewController: presenter)
        bottomSheetTransition?.perform(.bottomWarning(configurator: configurator), by: .presentWithoutNavigationController)
    }
    
    private func cancelTransaction(transactionType: JointAccountTransactionHandler.TransactionType, jointAccount: Account, overlay: JointAccountPendingTransactionOverlayViewController, sharedDataController: SharedDataController) {
        overlay.cancelTransaction()
        cancelAssetMonitoring(transactionType: transactionType, jointAccount: jointAccount, sharedDataController: sharedDataController)
    }
    
    private func cancelAssetMonitoring(transactionType: JointAccountTransactionHandler.TransactionType, jointAccount: Account, sharedDataController: SharedDataController) {
        
        let monitor = sharedDataController.blockchainUpdatesMonitor
        
        switch transactionType {
        case let .optIn(draft):
            guard let assetIndex = draft.assetIndex else { return }
            monitor.cancelMonitoringOptInUpdates(forAssetID: assetIndex, for: jointAccount)
        case let .optOut(draft):
            guard let assetIndex = draft.assetIndex else { return }
            monitor.markOptOutUpdatesForNotification(forAssetID: assetIndex, for: jointAccount)
        case .rekey, .sendAlgos, .sendAsset:
            break
        }
    }
}
