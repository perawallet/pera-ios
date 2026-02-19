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

//   JointAccountPendingTransactionOverlay.swift

import SwiftUI

struct JointAccountPendingTransactionOverlay: View {
    
    // MARK: - Properties
    
    private let model: JointAccountPendingTransactionOverlayModelable
    @ObservedObject private var viewModel: JointAccountPendingTransactionOverlayModel.ViewModel
    
    @State private var isVisible: Bool = false
    
    // MARK: - Properties - UIKit Compatibility
    
    var onDismiss: (() -> Void)?
    
    // MARK: - Initialisers
    
    init(model: JointAccountPendingTransactionOverlayModelable) {
        self.model = model
        viewModel = model.viewModel
    }
    
    // MARK: - Body
    
    var body: some View {
        OverlayView(
            contentView: { contentView() },
            isVisible: $isVisible,
            onDismissAction: { onDismiss?() }
        )
    }
    
    @ViewBuilder
    private func contentView() -> some View {
        VStack {
            Text("joint-account-pending-transaction-overlay-title")
                .font(.DMSans.medium.size(15.0))
                .foregroundStyle(Color.Text.main)
                .padding(.top, 22.0)
            capsules()
                .padding(.top, 10.0)
            VStack(alignment: .leading) {
                Text("joint-account-pending-transaction-overlay-section-accounts-title")
                    .font(.DMSans.medium.size(15.0))
                    .foregroundStyle(Color.Text.main)
                    .padding(.top, 22.0)
                    .padding(.horizontal, 24.0)
                Text("joint-account-pending-transaction-overlay-section-accounts-description-\(viewModel.threshold)")
                    .font(.DMSans.regular.size(13.0))
                    .foregroundStyle(Color.Text.gray)
                    .padding(.horizontal, 24.0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            SelfSizingScrollView(models: viewModel.accounts) {
                JointAccountPendingTransactionOverlayRow(avatar: $0.avatar, title: $0.title, subtitle: $0.subtitle, state: $0.signatureStatus.uiStatus)
                    .padding(.horizontal, 24.0)
            }
            .padding(.vertical, 16.0)
            buttonsRow()
                .padding(.horizontal, 24.0)
        }
    }
    
    @ViewBuilder
    private func capsules() -> some View {
        switch viewModel.transactionState {
        case .inProgress:
            HStack(spacing: 8.0) {
                JointAccountSendRequestInboxCapsule(icon: .Icons.user, text: .raw(text: viewModel.numberOfSignaturesText), foregroundColor: .Text.main, backgroundColor: .Layer.grayLighter)
                JointAccountSendRequestInboxCapsule(icon: .Icons.clock, text: .time(date: viewModel.deadline), foregroundColor: .Text.main, backgroundColor: .Layer.grayLighter)
            }
        case .success:
            JointAccountSendRequestInboxCapsule(icon: .Icons.check, text: .localized(text: "joint-account-pending-transaction-overlay-capsule-success"), foregroundColor: .Helpers.positive, backgroundColor: .Helpers.positiveLighter)
        case .cancelled:
            JointAccountSendRequestInboxCapsule(icon: .Icons.error, text: .localized(text: "joint-account-pending-transaction-overlay-capsule-cancelled"), foregroundColor: .Helpers.negative, backgroundColor: .Helpers.negativeLighter)
        }
    }
    
    @ViewBuilder
    private func buttonsRow() -> some View {
        switch viewModel.transactionState {
        case .inProgress:
            HStack(spacing: 20.0) {
                RoundedButton(
                    contentType: viewModel.isCancelProcessStarted ? .spinner : .text("title-cancel"),
                    style: .secondary,
                    isEnabled: true,
                    onTap: onCancelAction
                )
                RoundedButton(contentType: .text("joint-account-pending-transaction-overlay-button-close"), style: .primary, isEnabled: true, onTap: onCloseAction)
            }
        case .success, .cancelled:
            RoundedButton(contentType: .text("title-close"), style: .secondary, isEnabled: true, onTap: onCloseAction)
        }
    }
    
    // MARK: - Actions
    
    private func onCancelAction() {
        model.cancelTransaction()
    }
    
    private func onCloseAction() {
        isVisible = false
        model.stopPolling()
        onDismiss?()
    }
}

private extension JointAccountPendingTransactionOverlayModel.SignatureStatus {
    
    var uiStatus: JointAccountPendingTransactionOverlayRow.State {
        switch self {
        case .signed:
            return .approved
        case .declined:
            return .rejected
        case .pending:
            return .unknown
        }
    }
}
