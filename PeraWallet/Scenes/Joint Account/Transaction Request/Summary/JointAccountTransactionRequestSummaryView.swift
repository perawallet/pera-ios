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

//   JointAccountTransactionRequestSummaryView.swift

import SwiftUI
import pera_wallet_core

struct JointAccountTransactionRequestSummaryView: View {
    
    // MARK: - Properties
    
    @State private var confirmSlideButtonState: ConfirmSlideButtonState = .idle
    
    private let model: JointAccountTransactionRequestSummaryModelable
    @ObservedObject private var viewModel: JointAccountTransactionRequestSummaryViewModel
    
    // MARK: - Properties - UIKit Compatibility
    
    var onDismiss: (() -> Void)?
    var onCopy: ((_ address: String) -> Void)?
    var onShowDetails: ((_ account: Account, _ transaction: TransactionItem) -> Void)?
    var onShowError: ((any Error) -> Void)?
    
    // MARK: - Initialisers
    
    init(model: JointAccountTransactionRequestSummaryModelable) {
        self.model = model
        viewModel = model.viewModel
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack {
                HStack(alignment: .top) {
                    Spacer()
                    VStack {
                        Text("joint-account-transaction-requset-summary-title")
                            .font(.DMSans.medium.size(15.0))
                            .foregroundStyle(Color.Text.main)
                            .padding(.vertical, 10.0)
                        HStack {
                            RoundedIconView(
                                image: .icon(
                                    data: ImageType.IconData(
                                        image: .Icons.group,
                                        tintColor: .Wallet.wallet1,
                                        backgroundColor: .Wallet.wallet1Icon
                                    )
                                ),
                                size: 20.0,
                                padding: 4.0
                            )
                            Text("joint-account-transaction-requset-summary-subtitle")
                                .font(Font.DMSans.regular.size(13.0))
                                .foregroundStyle(Color.Text.gray)
                        }
                    }
                    Spacer()
                }
                Spacer()
                VStack {
                    RoundedIconView(
                        image: .icon(
                            data: ImageType.IconData(
                                image: .Icons.group,
                                tintColor: .Text.gray,
                                backgroundColor: .Layer.grayLighter
                            )
                        ),
                        size: 80.0,
                        padding: 16.0
                    )
                    .padding(.bottom, 24.0)
                    HStack(spacing: 8.0) {
                        Text("joint-account-transaction-requset-summary-receiver-address-text-prefix")
                            .font(Font.DMSans.regular.size(15.0))
                            .foregroundColor(Color.Text.gray)
                        + Text(verbatim: " ")
                            .font(Font.DMSans.regular.size(15.0))
                        + Text(viewModel.receiverAddress)
                            .font(Font.DMSans.medium.size(15.0))
                            .foregroundColor(Color.Text.main)
                        SwiftUI.Button(action: onCopyAction) {
                            Image(.Icons.copy)
                                .resizable()
                                .frame(width: 16.0, height: 16.0)
                                .foregroundStyle(Color.Text.main)
                        }
                    }
                    .padding(.bottom, 12.0)
                    Text("joint-account-transaction-requset-summary-algo-amount-\(viewModel.algoAmount)")
                        .font(.DMSans.medium.size(32.0))
                        .foregroundStyle(Color.Text.main)
                        .padding(.bottom, 4.0)
                    Text(viewModel.fiatAmount)
                        .font(.DMSans.regular.size(15.0))
                        .foregroundStyle(Color.Text.main)
                }
                Spacer()
                VStack {
                    VStack {
                        HStack {
                            Text("joint-account-transaction-requset-summary-transaction-fee")
                                .font(.DMSans.regular.size(13.0))
                                .foregroundStyle(Color.Text.gray)
                            Spacer()
                            Text(viewModel.transactionFee)
                                .font(.DMSans.medium.size(15.0))
                                .foregroundStyle(Color.Helpers.negative)
                        }
                        .padding(.bottom, 10.0)
                        HStack {
                            SwiftUI.Button(action: onShowTransactionDetailsAction) {
                                Text("joint-account-transaction-requset-summary-button-details")
                                    .font(.DMSans.medium.size(13.0))
                                    .padding(.trailing, 2.0)
                                Image(.Icons.arrow)
                                    .resizable()
                                    .frame(width: 20.0, height: 20.0)
                            }
                            .foregroundStyle(Color.Link.primary)
                            Spacer()
                        }
                    }
                    .padding(.vertical, 16.0)
                    .padding(.horizontal, 24.0)
                    Rectangle()
                        .frame(height: 1.0)
                        .foregroundStyle(Color.Layer.grayLighter)
                    VStack {
                        ConfirmSlideButton(state: $confirmSlideButtonState, isSwapDisabled: false, onConfirm: onConfirmAction)
                            .padding(.bottom, 22.0)
                        SwiftUI.Button(action: onDeclineAction) {
                            Text("joint-account-transaction-requset-summary-button-decline")
                                .font(.DMSans.medium.size(15.0))
                                .foregroundStyle(Color.Helpers.negative)
                        }
                    }
                    .padding(.top, 16.0)
                    .padding(.bottom, 20.0)
                    .padding(.horizontal, 24.0)
                }
                .background {
                    Rectangle()
                        .fill(Color.Defaults.bg)
                        .shadow(color: .black.opacity(0.16), radius: 30, x: 0, y: 14)
                        .ignoresSafeArea(.all)
                }
            }
            SwiftUI.Button(action: onCloseActions) {
                Image(.Icons.close)
                    .resizable()
                    .frame(width: 24.0, height: 24.0)
                    .foregroundStyle(Color.Text.main)
            }
            .padding(.top, 10.0)
            .padding(.trailing, 20.0)
            .zIndex(1.0)
        }
        .onReceive(viewModel.$action) { handle(action: $0) }
        .onReceive(viewModel.$error, perform: { handle(error: $0) })
    }
    
    // MARK: - Actions
    
    private func onCopyAction() {
        model.requestRawAddress()
    }
    
    private func onShowTransactionDetailsAction() {
        model.requestTransactionDetails()
    }
    
    private func onConfirmAction() {
        model.confirmTransaction()
    }
    
    private func onDeclineAction() {
        model.declineTransaction()
    }
    
    private func onCloseActions() {
        onDismiss?()
    }
    
    // MARK: - Handlers
    
    private func handle(action: JointAccountTransactionRequestSummaryViewModel.Action?) {
        
        guard let action else { return }
        
        switch action {
        case let .presentTransactionDetails(account, transaction):
            onShowDetails?(account, transaction)
        case let .copyAddress(address):
            onCopy?(address)
        case .success:
            onDismiss?()
        }
    }
    
    private func handle(error: JointAccountTransactionRequestSummaryViewModel.InternalError?) {
        guard let error else { return }
        onShowError?(error)
    }
}
