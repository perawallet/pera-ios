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

//   OptOutAssetCoordinator.swift

import Foundation

final class OptOutAssetCoordinator {
    
    // MARK: - Properties
    
    weak var presenter: BaseViewController?
    
    private var ledgerConnectionScreen: LedgerConnectionScreen?
    private var signWithLedgerProcessScreen: SignWithLedgerProcessScreen?
    private var blockchainUpdatesMonitor: BlockchainUpdatesMonitor? { presenter?.sharedDataController.blockchainUpdatesMonitor }
    private var selectedAccount: Account?
    
    // MARK: - Actions
    
    func isAssetOptOutable(asset: Asset, account: Account) -> Bool {
        guard let transactionController = makeTransactionController() else { return false }
        return isAssetOptOutable(asset: asset, account: account, transactionController: transactionController)
    }
    
    func optOut(asset: Asset, account: Account) {
        
        guard let presenter else { return }
        
        selectedAccount = account
        
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
        transactionController.delegate = self
        
        guard account.requiresLedgerConnection() else { return }
        
        openLedgerConnection(transactionController: transactionController, account: account)
        transactionController.initializeLedgerTransactionAccount()
        transactionController.startTimer()
    }
    
    // MARK: - Transfer Asset Balance
    
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
    
    private func openSignWithLedgerProcess(transactionController: TransactionController, ledgerDeviceName: String, account: Account) {
        
        guard let presenter else { return }
        
        let transition = BottomSheetTransition(presentingViewController: presenter, interactable: false)
        
        let draft = SignWithLedgerProcessDraft(ledgerDeviceName: ledgerDeviceName, totalTransactionCount: 1)
        let eventHandler: SignWithLedgerProcessScreen.EventHandler = { [weak self] in
            
            guard let self else { return }
            
            switch $0 {
            case .performCancelApproval:
                transactionController.stopBLEScan()
                transactionController.stopTimer()
                
                cancelMonitoringOptOutUpdates(transactionController: transactionController, account: account)

                self.signWithLedgerProcessScreen?.dismissScreen()
                self.signWithLedgerProcessScreen = nil
            }
            
        }
        
        signWithLedgerProcessScreen = transition.perform(.signWithLedgerProcess(draft: draft, eventHandler: eventHandler), by: .present)
    }
    
    // MARK: - View Presenters
    
    private func show(transactionError: TransactionError) {
        
        switch transactionError {
            
        case let .minimumAmount(amount):
            let currencyFormatter = CurrencyFormatter()
            currencyFormatter.formattingContext = .standalone()
            currencyFormatter.currency = AlgoLocalCurrency()
            let amountText = currencyFormatter.format(amount.toAlgos)
            presenter?.configuration.bannerController?.presentErrorBanner(
                title: String(localized: "asset-min-transaction-error-title"),
                message: String(format: String(localized: "asset-min-transaction-error-message"), amountText.someString)
            )
        case .invalidAddress:
            presenter?.configuration.bannerController?.presentErrorBanner(
                title: String(localized: "title-error"),
                message: String(localized: "send-algos-receiver-address-validation")
            )
        case let .sdkError(error):
            presenter?.configuration.bannerController?.presentErrorBanner(
                title: String(localized: "title-error"),
                message: error.debugDescription
            )
        case .ledgerConnection:
            ledgerConnectionScreen?.dismiss(animated: true) { [weak self] in
                self?.ledgerConnectionScreen = nil
                self?.showLedgerConnectionIssues()
            }
        case .optOutFromCreator:
            presenter?.configuration.bannerController?.presentErrorBanner(
                title: String(localized: "title-error"),
                message: String(localized: "asset-creator-opt-out-error-message")
            )
        case .draft, .other:
            break
        }
    }
    
    private func show(hipTransactionError: HIPTransactionError) {
        
        switch hipTransactionError {
            
        case let .network(apiError):
            presenter?.configuration.bannerController?.presentErrorBanner(
                title: String(localized: "title-error"),
                message: apiError.debugDescription
            )
        case .inapp:
            presenter?.configuration.bannerController?.presentErrorBanner(
                title: String(localized: "title-error"),
                message: hipTransactionError.localizedDescription
            )
        }
    }
    
    private func showLedgerConnectionIssues() {
        
        guard let presenter else { return }
        
        let configurator = BottomWarningViewConfigurator(
            image: "icon-info-green".uiImage,
            title: String(localized: "ledger-pairing-issue-error-title"),
            description: .plain(String(localized: "ble-error-fail-ble-connection-repairing")),
            secondaryActionButtonTitle: String(localized: "title-ok")
        )

        let transition = BottomSheetTransition(presentingViewController: presenter)
        transition.perform(.bottomWarning(configurator: configurator), by: .presentWithoutNavigationController)
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
    
    private func cancelMonitoringOptOutUpdates(transactionController: TransactionController) {
        guard let selectedAccount else { return }
        cancelMonitoringOptOutUpdates(transactionController: transactionController, account: selectedAccount)
    }
    
    private func clearData() {
        selectedAccount = nil
    }
}

extension OptOutAssetCoordinator: TransactionControllerDelegate {
    
    func transactionController(_ transactionController: TransactionController, didComposedTransactionDataFor draft: (any TransactionSendDraft)?) {
        NotificationCenter.default.post(name: CollectibleListLocalDataController.didRemoveCollectible, object: self)
        clearData()
    }
    
    func transactionController(_ transactionController: TransactionController, didFailedComposing error: HIPTransactionError) {
        cancelMonitoringOptOutUpdates(transactionController: transactionController)
        clearData()
        guard case let .inapp(transactionError) = error else { return }
        show(transactionError: transactionError)
    }
    
    func transactionController(_ transactionController: TransactionController, didCompletedTransaction id: TransactionID) {}
    
    func transactionController(_ transactionController: TransactionController, didFailedTransaction error: HIPTransactionError) {
        show(hipTransactionError: error)
        cancelMonitoringOptOutUpdates(transactionController: transactionController)
        clearData()
    }
    
    func transactionControllerDidFailToSignWithLedger(_ transactionController: TransactionController) {}
    
    func transactionController(_ transactionController: TransactionController, didRequestUserApprovalFrom ledger: String) {
        
        guard let selectedAccount else { return }
        
        ledgerConnectionScreen?.dismiss(animated: true) {
            self.ledgerConnectionScreen = nil
            self.openSignWithLedgerProcess(transactionController: transactionController, ledgerDeviceName: ledger, account: selectedAccount)
        }
    }
    
    func transactionControllerDidResetLedgerOperation(_ transactionController: TransactionController) {
        
        ledgerConnectionScreen?.dismissScreen()
        ledgerConnectionScreen = nil
        
        signWithLedgerProcessScreen?.dismissScreen()
        signWithLedgerProcessScreen = nil
        
        cancelMonitoringOptOutUpdates(transactionController: transactionController)
    }
    
    func transactionControllerDidRejectedLedgerOperation(_ transactionController: TransactionController) {}
    
    func transactionControllerDidResetLedgerOperationOnSuccess(_ transactionController: TransactionController) {
        signWithLedgerProcessScreen?.dismissScreen()
        signWithLedgerProcessScreen = nil
    }
}
