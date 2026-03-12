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

//   JointAccountTransactionRequestSummaryHostingViewController.swift

import SwiftUI
import pera_wallet_core

final class JointAccountTransactionRequestSummaryHostingViewController: UIHostingController<JointAccountTransactionRequestSummaryView> {
    
    // MARK: - Properties
    
    var onDismiss: (() -> Void)?
    var onShowDetails: ((_ account: Account, _ transaction: TransactionItem) -> Void)?
    var onShowSigningStatus: (( _ transaction: TransactionItem) -> Void)?
    var onCopy: ((_ address: String) -> Void)?
    var onShowError: ((Error) -> Void)?

    // MARK: - Initialisers
    
    init(model: JointAccountTransactionRequestSummaryModelable) {
        super.init(rootView: JointAccountTransactionRequestSummaryView(model: model))
        rootView.onDismiss = { [weak self] in self?.onDismiss?() }
        rootView.onShowDetails = { [weak self] in self?.onShowDetails?($0, $1) }
        rootView.onShowSigningStatus = { [weak self] in self?.onShowSigningStatus?($0) }
        rootView.onCopy = { [weak self] in self?.onCopy?($0) }
        rootView.onShowError = { [weak self] in self?.onShowError?($0) }
    }
    
    @available(*, unavailable)
    @MainActor @preconcurrency required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
