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

//   SharedAccountSignWithLedgerHandler.swift

import UIKit
import pera_wallet_core

enum TestError: Error {
    case test
}

final class SharedAccountSignWithLedgerHandler: TransactionControllerDelegate {
    
    // MARK: - Properties
    
    var onFinished: (() -> Void)?
    
    private let bottomSheetTransition: BottomSheetTransition
    private let bannerController: BannerController?
    private let accountsService: AccountsServiceable
    private let currencyFormatter = CurrencyFormatter()
    
    private var ledgerConnectionScreen: LedgerConnectionScreen?
    private var signWithLedgerProcessScreen: SignWithLedgerProcessScreen?
    
    // MARK: - Initialisers
    
    init(presenter: UIViewController, bannerController: BannerController?, accountsService: AccountsServiceable) {
        bottomSheetTransition = BottomSheetTransition(presentingViewController: presenter, interactable: false)
        self.bannerController = bannerController
        self.accountsService = accountsService
    }
    
    // MARK: - Actions
    
    func handle(signerAccount: Account, transactionData: Data, signRequestId: String, transactionController: TransactionController) {
        
        transactionController.enforceLedgerConnection = true
        transactionController.delegate = self
        
        let eventHandler: LedgerConnectionScreen.EventHandler = { [weak self] in
            switch $0 {
            case .performCancel:
                transactionController.stopBLEScan()
                transactionController.stopTimer()
                Task { @MainActor in
                    await self?.dismissLedgerConnectionScreen()
                    self?.onFinished?()
                }
            }
        }
        
        ledgerConnectionScreen = bottomSheetTransition.perform(.ledgerConnection(eventHandler: eventHandler), by: .presentWithoutNavigationController)
        
        Task { @MainActor in
            
            let signature = await transactionController.singature(signerAccount: signerAccount, transactionData: transactionData)?.base64EncodedString() ?? ""
            let responses: [AccountsService.JointAccountSignResponse] = [.signed(address: signerAccount.address, signatures: [[signature]])]
            
            do {
                try await accountsService.signJointAccountTransaction(signRequestId: signRequestId, responses: responses)
            } catch {
                display(error: error)
            }
        }
    }
    
    private func openSignWithLedgerProcess(transactionController: TransactionController, ledgerDeviceName: String) {
        
        let draft = SignWithLedgerProcessDraft(ledgerDeviceName: ledgerDeviceName, totalTransactionCount: 1)
        
        let eventHandler: SignWithLedgerProcessScreen.EventHandler = { [weak self] in
            switch $0 {
            case .performCancelApproval:
                transactionController.stopBLEScan()
                transactionController.stopTimer()
                self?.signWithLedgerProcessScreen?.dismissScreen()
                self?.signWithLedgerProcessScreen = nil
            }
        }
        
        signWithLedgerProcessScreen = bottomSheetTransition.perform(.signWithLedgerProcess(draft: draft, eventHandler: eventHandler), by: .present)
    }
    
    private func openLedgerConnectionIssues() {
        
        let configurator = BottomWarningViewConfigurator(
            image: .iconInfoGreen,
            title: String(localized: "ledger-pairing-issue-error-title"),
            description: .plain(String(localized: "ble-error-fail-ble-connection-repairing")),
            secondaryActionButtonTitle: String(localized: "title-ok")
        )

        bottomSheetTransition.perform(.bottomWarning(configurator: configurator), by: .presentWithoutNavigationController)
    }
    
    @MainActor
    private func dismissLedgerConnectionScreen(completion: (() -> Void)? = nil) async {
        
        await withCheckedContinuation { [weak self] continuation in
            
            guard let self, let ledgerConnectionScreen else {
                continuation.resume()
                return
            }
            
            ledgerConnectionScreen.dismiss(animated: true) { [weak self] in
                self?.ledgerConnectionScreen = nil
                continuation.resume()
            }
        }
    }
    
    @MainActor
    private func dismissSignWithLedgerProcessScreen() async {
        
        await withCheckedContinuation { [weak self] continuation in
            
            guard let self, let signWithLedgerProcessScreen else {
                continuation.resume()
                return
            }
            
            signWithLedgerProcessScreen.dismiss(animated: true) { [weak self] in
                self?.signWithLedgerProcessScreen = nil
                continuation.resume()
            }
        }
    }
    
    private func displayTransactionError(_ transactionError: TransactionError) {
        
        switch transactionError {
        case let .minimumAmount(amount):
            currencyFormatter.formattingContext = .standalone()
            currencyFormatter.currency = AlgoLocalCurrency()

            let amountText = currencyFormatter.format(amount.toAlgos)

            bannerController?.presentErrorBanner(
                title: String(localized: "asset-min-transaction-error-title"),
                message: String(format: String(localized: "asset-min-transaction-error-message"), amountText.someString)
            )
        case let .sdkError(error):
            bannerController?.presentErrorBanner(
                title: String(localized: "title-error"),
                message: error.debugDescription
            )
        case .ledgerConnection:
            ledgerConnectionScreen?.dismiss(animated: true) {
                self.ledgerConnectionScreen = nil

                self.openLedgerConnectionIssues()
            }
        case .optOutFromCreator:
            bannerController?.presentErrorBanner(
                title: String(localized: "title-error"),
                message: String(localized: "asset-creator-opt-out-error-message")
            )
        default:
            break
        }
    }
    
    @MainActor
    private func display(error: Error) {
        bannerController?.presentErrorBanner(title: String(localized: "title-error"), message: error.localizedDescription)
    }
    
    // MARK: - TransactionControllerDelegate
    
    func transactionController(_ transactionController: TransactionController, didComposedTransactionDataFor draft: (TransactionSendDraft)?) {}
    
    func transactionController(_ transactionController: TransactionController, didFailedComposing error: HIPTransactionError) {
        
        switch error {
        case let .inapp(transactionError):
            displayTransactionError(transactionError)
        default:
            break
        }
        
        Task { @MainActor in
            await dismissLedgerConnectionScreen()
            await dismissSignWithLedgerProcessScreen()
        }
    }
    
    func transactionController(_ transactionController: TransactionController, didCompletedTransaction id: TransactionID) {}
    
    func transactionController(_ transactionController: TransactionController, didFailedTransaction error: HIPTransactionError) {
        
        switch error {
        case let .network(apiError):
            bannerController?.presentErrorBanner(title: String(localized: "title-error"), message: apiError.debugDescription)
        default:
            bannerController?.presentErrorBanner(title: String(localized: "title-error"), message: error.localizedDescription)
        }
    }
    
    func transactionControllerDidFailToSignWithLedger(_ transactionController: TransactionController) {}
    
    func transactionController(_ transactionController: TransactionController, didRequestUserApprovalFrom ledger: String) {
        
        Task { @MainActor [weak self] in
            await self?.dismissLedgerConnectionScreen()
            self?.openSignWithLedgerProcess(transactionController: transactionController, ledgerDeviceName: ledger)
        }
    }
    
    func transactionControllerDidResetLedgerOperation(_ transactionController: TransactionController) {
        
        Task { @MainActor in
            await dismissLedgerConnectionScreen()
            await dismissSignWithLedgerProcessScreen()
        }
    }
    
    func transactionControllerDidRejectedLedgerOperation(_ transactionController: TransactionController) {}
    
    func transactionControllerDidResetLedgerOperationOnSuccess(_ transactionController: TransactionController) {
        
        Task { @MainActor in
            await dismissSignWithLedgerProcessScreen()
        }
    }
}
