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

//   SwapView.swift

import SwiftUI
import Combine
import pera_wallet_core

enum SwapViewAction {
    case showInfo
    case selectAccount
    case selectAssetIn(for: Account)
    case selectAssetOut(for: Account)
    case getQuote(for: Double)
    case confirmSwap
    case showBanner(success: String?, error: String?)
}

enum SwapViewSheet: Identifiable {
    case settings
    case provider(availableProviders: [SwapProviderV2])
    case confirmSwap
    
    var id: String {
        switch self {
        case .settings: return "settings"
        case .provider: return "provider"
        case .confirmSwap: return "confirmSwap"
        }
    }
}

struct SwapView: View {
    
    // MARK: - Properties
    @ObservedObject var viewModel: SwapSharedViewModel
    var onAction: ((SwapViewAction) -> Void)?
    
    @State private var activeSheet: SwapViewSheet?
    
    private var safeAreaTopInset: CGFloat {
        (UIApplication.shared.connectedScenes.first as? UIWindowScene)?
            .windows.first?.safeAreaInsets.top ?? 44
    }
    
    // MARK: - Body
    var body: some View {
        VStack (spacing: 0) {
            headerView
            assetSelectionView
            if viewModel.shouldShowSwapButton {
                swapActionView
            }
        }
        .padding(.top, safeAreaTopInset)
        .frame(maxHeight: .infinity, alignment: .top)
        .sheet(item: $activeSheet, content: sheetContent)
        .onChange(of: viewModel.selectedProvider) { newValue in
            viewModel.selectQuote(with: newValue)
        }
    }
    
    // MARK: - Subviews
    
    private var headerView: some View {
        SwapTitleView(selectedAccount: $viewModel.selectedAccount) { action in
            switch action {
            case .accountSelection:
                onAction?(.selectAccount)
            case .info:
                onAction?(.showInfo)
            }
        }
    }
    
    private var assetSelectionView: some View {
        ZStack {
            VStack (spacing: 0) {
                AssetSelectionView(
                    type: .pay,
                    assetItem: $viewModel.selectedAssetIn,
                    network: $viewModel.selectedNetwork,
                    amountText: $viewModel.payingText,
                    amountTextInUSD: $viewModel.payingTextInUSD,
                    isLoading: $viewModel.isLoadingPayAmount,
                    isBalanceNotSufficient: $viewModel.isBalanceNotSufficient
                ) {
                    onAction?(.selectAssetIn(for: $viewModel.selectedAccount.wrappedValue))
                }
                AssetSelectionView(
                    type: .receive,
                    assetItem: $viewModel.selectedAssetOut,
                    network: $viewModel.selectedNetwork,
                    amountText: $viewModel.receivingText,
                    amountTextInUSD: $viewModel.receivingTextInUSD,
                    isLoading: $viewModel.isLoadingReceiveAmount,
                    isBalanceNotSufficient: .constant(false)
                ) {
                    onAction?(.selectAssetOut(for: $viewModel.selectedAccount.wrappedValue))
                }
            }
            .padding(.horizontal, 8)
            .onChange(of: viewModel.payingText) { viewModel.updatePayingText($0) { onAction?(.getQuote(for: $0)) } }
            
            HStack {
                SwitchSwapButton {
                    viewModel.switchAssets()
                }
                Spacer()
                SettingsSwapButton { action in
                    switch action {
                    case .settings:
                        activeSheet = .settings
                    case .max:
                        print("max")
                    }
                }
                .hidden()
            }
            .padding(.horizontal, 16)
            .padding(.top, viewModel.isBalanceNotSufficient ? 50 : 0)
        }
    }
    
    private var swapActionView: some View {
        VStack(spacing: 0) {
            providerSelectionView
            SwapButton {
                guard !viewModel.payingText.isEmpty, !viewModel.receivingText.isEmpty else { return }
                activeSheet = .confirmSwap
            }
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .animation(.easeInOut, value: viewModel.shouldShowSwapButton)
        }
    }
    
    private var providerSelectionView: some View {
        let providerViewModel = ProviderSelectionViewModel(providerId: viewModel.selectedProvider.providerId, iconUrl: viewModel.activeProvider?.iconUrl ?? .empty, displayName: viewModel.activeProvider?.displayName ?? .empty, rate: viewModel.providerRate)
        
        return ProviderSelectionView(viewModel: providerViewModel) {
            guard let providers = viewModel.availableProviders else { return }
            activeSheet = .provider(availableProviders: providers)
        }
        .padding(.top, 16)
        .padding(.bottom, 12)
    }
    
    @ViewBuilder
    private func sheetContent(for sheet: SwapViewSheet) -> some View {
        switch sheet {
        case .settings:
            SwapSettingsSheet()
        case .provider(availableProviders: let providers):
            let vm = ProviderSheetViewModel(
                selectedProvider: viewModel.selectedProvider,
                availableProviders: providers,
                quoteList: viewModel.quoteList
            )
            ProviderSheet(viewModel: vm) { selectedProvider in
                viewModel.selectedProvider = selectedProvider
            }
        case .confirmSwap:
            ConfirmSwapView(viewModel: viewModel.confirmSwapModel()) {
                onAction?(.confirmSwap)
            } onSwapSuccess: { successMessage in
                onAction?(.showBanner(success: successMessage, error: nil))
            } onSwapError: { errorMessage in
                onAction?(.showBanner(success: nil, error: errorMessage))
            }
        }
    }
}
