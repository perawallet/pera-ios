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

//   JointAccountTransactionRequestSummaryViewController.swift

import pera_wallet_core
import UIKit

final class JointAccountTransactionRequestSummaryViewController: SwiftUICompatibilityBaseViewController {
    
    // MARK: - Properties
    
    private let hostingController: JointAccountTransactionRequestSummaryHostingViewController
    private let accountsService: AccountsServiceable
    private let currencyFormatter = CurrencyFormatter()
    
    private var copyToClipboardController: CopyToClipboardController?
    private var ledgerConnectionScreen: LedgerConnectionScreen?
    private var signWithLedgerProcessScreen: SignWithLedgerProcessScreen?
    private var pendingDetailTask: Task<Void, Never>?
    private lazy var bottomSheetTransition = BottomSheetTransition(presentingViewController: self, interactable: false)
    
    // MARK: - Initialisers
    
    init(
        legacyConfiguration: ViewControllerConfiguration,
        accountsService: AccountsServiceable,
        model: JointAccountTransactionRequestSummaryModelable
    ) {
        hostingController = JointAccountTransactionRequestSummaryHostingViewController(model: model)
        self.accountsService = accountsService
        super.init(configuration: legacyConfiguration, hostingController: hostingController)
        setupCallbacks()
        setupLegacyControllers()
    }
    
    deinit {
        pendingDetailTask?.cancel()
    }
    
    // MARK: - Setups
    
    private func setupCallbacks() {
        hostingController.onDismiss = { [weak self] in self?.dismiss(animated: true) }
        hostingController.onShowDetails = { [weak self] in self?.presentTransactionDetails(account: $0, transaction: $1) }
        hostingController.onShowSigningStatus = { [weak self] in self?.openSigningStatus(for: $0) }
        hostingController.onCopy = { [weak self] in self?.copyAddressToPastebin(address: $0) }
        hostingController.onShowError = { [weak self] in self?.show(error: $0) }
        hostingController.onRequestConnectionWithLedger = { [weak self] in self?.showLedgerOverlay(transactionController: $0) }
    }
    
    private func setupLegacyControllers() {
        guard let toastPresentationController else { return }
        copyToClipboardController = ALGCopyToClipboardController(toastPresentationController: toastPresentationController)
    }
    
    // MARK: - Actions
    
    private func presentTransactionDetails(account: Account, transaction: TransactionItem) {
        open(.transactionDetail(account: account, transaction: transaction, assetDetail: nil), by: .present)
    }
    
    private func openSigningStatus(for transaction: TransactionItem) {
        guard
            let sender = transaction.sender,
            let senderAccount = sharedDataController.accountCollection[sender]?.value,
            senderAccount.isJointAccount,
            let proposerAddress = resolveProposerAddress(from: senderAccount),
            let transactionId = transaction.id
        else {
            show(error: SendTransactionPreviewScreen.InternalError.noSigner)
            return
        }
        
        pendingDetailTask = Task { [weak self] in
            guard let self else { return }
            do {
                let metadata = try await fetchSignRequestMetadata(
                    transactionId: transactionId,
                    proposerAddress: proposerAddress
                )
                showJointAccountPendingTransactionOverlay(signRequestMetadata: metadata)
            } catch {
                show(error: error)
            }
        }
    }
    
    private func resolveProposerAddress(from jointAccount: Account) -> String? {
        jointAccount.jointAccountParticipants?.first
    }
    
    private func fetchSignRequestMetadata(
        transactionId: String,
        proposerAddress: String
    ) async throws -> SignRequestMetadata {
        guard
            let signTransaction = try await accountsService
                .searchJointAccountSignTransaction(signRequestID: transactionId)
                .results.first,
            let responses = signTransaction.transactionLists?.first?.responses,
            let threshold = signTransaction.jointAccount?.threshold,
            let deadline = signTransaction.expectedExpireDatetime
        else {
            throw SendTransactionPreviewScreen.InternalError.noSigner
        }
        
        let signaturesInfo = try buildSignaturesInfo(
            from: signTransaction.jointAccount?.participantAddresses,
            responses: responses
        )
        
        return SignRequestMetadata(
            signRequestID: transactionId,
            transactions: signTransaction.transactionLists ?? [],
            proposerAddress: proposerAddress,
            signaturesInfo: signaturesInfo,
            threshold: threshold,
            deadline: deadline
        )
    }
    
    private func buildSignaturesInfo(
        from participantAddresses: [String]?,
        responses: [SignRequestTransactionResponseObject]
    ) throws -> [SignRequestInfo] {
        guard let addresses = participantAddresses else {
            throw SendTransactionPreviewScreen.InternalError.noSigner
        }
        
        return addresses.map { address in
            let status = responses.first { $0.address == address }?.response
            return SignRequestInfo(address: address, status: status)
        }
    }
    
    private func showJointAccountPendingTransactionOverlay(signRequestMetadata: SignRequestMetadata) {
        
        let viewController = JointAccountPendingTransactionOverlayConstructor.buildViewController(
            signRequestMetadata: signRequestMetadata,
            isCancelTransactionAvailable: false,
            isSignWithLedgerActionAvailable: false,
            legacyConfiguration: configuration
        )
        
        present(viewController, animated: true)
    }
    
    private func copyAddressToPastebin(address: String) {
        let account = Account(address: address)
        copyToClipboardController?.copyAddress(account)
    }
    
    private func show(error: Error) {
        let title = String(localized: "title-error")
        let message = error.localizedDescription
        bannerController?.presentErrorBanner(title: title, message: message)
    }
    
    private func showLedgerOverlay(transactionController: TransactionController) {
        
        transactionController.delegate = self
        
        let eventHandler: LedgerConnectionScreen.EventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .performCancel:
                transactionController.stopBLEScan()
                transactionController.stopTimer()
                loadingController?.stopLoading()
                ledgerConnectionScreen?.dismissScreen()
                ledgerConnectionScreen = nil
                dismiss(animated: true)
            }
        }
        
        ledgerConnectionScreen = bottomSheetTransition.perform(.ledgerConnection(eventHandler: eventHandler), by: .presentWithoutNavigationController)
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
                self?.loadingController?.stopLoading()
                self?.dismiss(animated: true)
            }
        }
        
        signWithLedgerProcessScreen = bottomSheetTransition.perform(.signWithLedgerProcess(draft: draft, eventHandler: eventHandler), by: .present)
    }
    
    private func openLedgerConnectionIssues() {
        
        let configurator = BottomWarningViewConfigurator(
            image: .iconInfoGreen,
            title: String(localized: "ledger-pairing-issue-error-title"),
            description: .plain(String(localized: "ble-error-fail-ble-connection-repairing")),
            secondaryActionButtonTitle: String(localized: "title-ok"),
            secondaryAction: { [weak self] in self?.dismiss(animated: true) }
        )

        bottomSheetTransition.perform(.bottomWarning(configurator: configurator), by: .presentWithoutNavigationController)
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
}

extension JointAccountTransactionRequestSummaryViewController: TransactionControllerDelegate {
    
    func transactionController(_ transactionController: TransactionController, didFailedComposing error: HIPTransactionError) {

        loadingController?.stopLoading()
        
        switch error {
        case let .inapp(transactionError):
            displayTransactionError(transactionError)
        default:
            break
        }
    }
    
    func transactionController(_ transactionController: TransactionController, didFailedTransaction error: HIPTransactionError) {

        loadingController?.stopLoading()

        switch error {
        case let .network(apiError):
            bannerController?.presentErrorBanner(title: String(localized: "title-error"), message: apiError.debugDescription)
        default:
            bannerController?.presentErrorBanner(title: String(localized: "title-error"), message: error.localizedDescription)
        }
    }
    
    func transactionController(_ transactionController: TransactionController, didRequestUserApprovalFrom ledger: String) {
        
        ledgerConnectionScreen?.dismiss(animated: true) { [weak self] in
            self?.ledgerConnectionScreen = nil
            self?.openSignWithLedgerProcess(transactionController: transactionController, ledgerDeviceName: ledger)
        }
        
    }
    
    func transactionControllerDidResetLedgerOperation(_ transactionController: TransactionController) {
        
        let dispatchGroup = DispatchGroup()
        
        if let ledgerConnectionScreen {
            dispatchGroup.enter()
            ledgerConnectionScreen.dismissScreen() {
                self.ledgerConnectionScreen = nil
                dispatchGroup.leave()
            }
        }
        
        if let signWithLedgerProcessScreen {
            dispatchGroup.enter()
            signWithLedgerProcessScreen.dismissScreen() {
                dispatchGroup.leave()
                self.signWithLedgerProcessScreen = nil
            }
        }

        loadingController?.stopLoading()
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            self?.dismiss(animated: true)
        }
    }
    
    func transactionControllerDidResetLedgerOperationOnSuccess(_ transactionController: TransactionController) {
        signWithLedgerProcessScreen?.dismissScreen()
        signWithLedgerProcessScreen = nil
        loadingController?.stopLoading()
    }
}
