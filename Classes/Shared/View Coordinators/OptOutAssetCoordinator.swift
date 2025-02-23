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

//   OptOutAssetCoordinator.swift

final class OptOutAssetCoordinator {
    
    // MARK: - Properties
    
    weak var presenter: BaseViewController?
    
    private var ledgerConnectionScreen: LedgerConnectionScreen?
    private var blockchainUpdatesMonitor: BlockchainUpdatesMonitor? { presenter?.sharedDataController.blockchainUpdatesMonitor }
    
    // MARK: - Actions
    
    func isAssetOptOutable(asset: Asset, account: Account) -> Bool {
        guard let transactionController = makeTransactionController() else { return false }
        return isAssetOptOutable(asset: asset, account: account, transactionController: transactionController)
    }
    
    func optOut(asset: Asset, account: Account) {
        
        guard let presenter else { return }
        
        guard asset.isEmpty else {
            openTransferAssetBalance(account: account, asset: asset)
            return
        }

        let optOutAssetDraft = OptOutAssetDraft(account: account, asset: asset)
        
        let screen = Screen.optOutAsset(draft: optOutAssetDraft) { [weak self] in
            
            guard let self else { return }

            switch $0 {
            case .performApprove:
                presenter.dismiss(animated: true) {
                    self.continueToOptOut(asset: asset, account: account)
                }
            case .performClose:
                presenter.dismiss(animated: true)
            }
        }
        
        let transition = BottomSheetTransition(presentingViewController: presenter)
        transition.perform(screen, by: .present)
    }
    
    private func isAssetOptOutable(asset: Asset, account: Account, transactionController: TransactionController) -> Bool {
        transactionController.canSignTransaction(for: account) && asset.creator != nil
    }
    
    // MARK: - Opt-Out
    
    private func continueToOptOut(asset: Asset, account: Account) {
        
        guard let transactionController = makeTransactionController(), let creator = asset.creator, isAssetOptOutable(asset: asset, account: account, transactionController: transactionController) else { return }
        
        let optOutRequest = OptOutBlockchainRequest(account: account, asset: asset)
        blockchainUpdatesMonitor?.startMonitoringOptOutUpdates(optOutRequest)
        
        let assetAccount = Account(address: creator.address)
        let assetTransactionSendDraft = AssetTransactionSendDraft(from: account, toAccount: assetAccount, amount: 0.0, assetIndex: asset.id, assetCreator: creator.address)
        
        transactionController.setTransactionDraft(assetTransactionSendDraft)
        transactionController.getTransactionParamsAndComposeTransactionData(for: .optOut)
        
        guard account.requiresLedgerConnection() else { return }
        
        openLedgerConnection(transactionController: transactionController, account: account)
        transactionController.initializeLedgerTransactionAccount()
        transactionController.startTimer()
    }
    
    // TODO: - Transfer Asset Balance
    
    private func openTransferAssetBalance(account: Account, asset: Asset) {
        
        guard let presenter else { return }
        
        let transferAssetBalanceDraft = TransferAssetBalanceDraft(account: account, asset: asset)
        let screen = Screen.transferAssetBalance(draft: transferAssetBalanceDraft) { [weak self] in
            
            guard let self else { return }
            
            switch $0 {
            case .performApprove:
                presenter.dismiss(animated: true) { [weak self] in
                    self?.continueToTransferAssetBalance(account: account, asset: asset)
                }
            case .performClose:
                presenter.dismiss(animated: true)
            }
        }
        
        let transition = BottomSheetTransition(presentingViewController: presenter)
        transition.perform(screen, by: .present)
    }
    
    private func continueToTransferAssetBalance(account: Account, asset: Asset) {
        let sendTransactionDraft = SendTransactionDraft(from: account, amount: asset.amountWithFraction, transactionMode: .asset(asset), isOptingOut: true)
        presenter?.open(.sendTransaction(draft: sendTransactionDraft), by: .present)
    }
    
    // MARK: - Ledger
    
    private func openLedgerConnection(transactionController: TransactionController, account: Account) {
        
        guard let presenter else { return }
        
        let eventHandler: LedgerConnectionScreen.EventHandler = { [weak self] in
            
            guard let self else { return }

            switch $0 {
            case .performCancel:
                transactionController.stopBLEScan()
                transactionController.stopTimer()
                cancelMonitoringOptOutUpdates(transactionController: transactionController, account: account)
                self.ledgerConnectionScreen?.dismissScreen()
                self.ledgerConnectionScreen = nil
            }
        }
        
        let transition = BottomSheetTransition(presentingViewController: presenter, interactable: false)
        ledgerConnectionScreen = transition.perform(.ledgerConnection(eventHandler: eventHandler), by: .presentWithoutNavigationController)
    }
    
    // MARK: - Helpers
    
    private func makeTransactionController() -> TransactionController? {
        guard let presenter, let api = presenter.api else { return nil }
        return TransactionController(api: api, sharedDataController: presenter.sharedDataController, bannerController: presenter.bannerController, analytics: presenter.analytics)
    }
    
    private func cancelMonitoringOptOutUpdates(transactionController: TransactionController, account: Account) {
        guard let assetID = transactionController.assetTransactionDraft?.assetIndex else { return }
        blockchainUpdatesMonitor?.cancelMonitoringOptOutUpdates(forAssetID: assetID, for: account)
    }
}
