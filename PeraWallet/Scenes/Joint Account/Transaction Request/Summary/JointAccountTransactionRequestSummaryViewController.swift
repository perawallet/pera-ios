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

final class JointAccountTransactionRequestSummaryViewController: SwiftUICompatibilityBaseViewController {
    
    // MARK: - Properties
    
    private let hostingController: JointAccountTransactionRequestSummaryHostingViewController
    private var copyToClipboardController: CopyToClipboardController?
    private let accountsService: AccountsServiceable
    private var pendingDetailTask: Task<Void, Never>?
    
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
        let participants = jointAccount.jointAccountParticipants ?? []
        return participants
            .compactMap { self.accountsService.account(address: $0)?.address }
            .first
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
        let viewController = JointAccountPendingTransactionOverlayConstructor.buildViewController(signRequestMetadata: signRequestMetadata)
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
}
