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
    
    // MARK: - Initialisers
    
    init(legacyConfiguration: ViewControllerConfiguration, model: JointAccountTransactionRequestSummaryModelable) {
        hostingController = JointAccountTransactionRequestSummaryHostingViewController(model: model)
        super.init(configuration: legacyConfiguration, hostingController: hostingController)
        setupCallbacks()
        setupLegacyControllers()
    }
    
    // MARK: - Setups
    
    private func setupCallbacks() {
        hostingController.onDismiss = { [weak self] in self?.dismiss(animated: true) }
        hostingController.onShowDetails = { [weak self] in self?.presentTransactionDetails(account: $0, transaction: $1) }
        hostingController.onCopy = { [weak self] in self?.copyAddressToPastebin(address: $0) }
        hostingController.onShowError = { [weak self] in self?.show(error: $0) }
    }
    
    private func setupLegacyControllers() {
        guard let toastPresentationController else { return }
        copyToClipboardController = ALGCopyToClipboardController(toastPresentationController: toastPresentationController)
    }
    
    // MARK: - Actions
    
    private func presentTransactionDetails(account: Account, transaction: TransactionItem) {
        let asset: Asset? = nil
        open(.transactionDetail(account: account, transaction: transaction, assetDetail: asset), by: .present)
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
