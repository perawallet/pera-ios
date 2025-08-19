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
    case switchAssets
    case getQuote(for: Double)
    case confirmSwap
}

enum SwapViewSheet: Identifiable {
    case settings
    case provider
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
    
    
    private var safeAreaTopInset: CGFloat {
        (UIApplication.shared.connectedScenes.first as? UIWindowScene)?
            .windows.first?.safeAreaInsets.top ?? 44
    }
    @State private var debounceWorkItem: DispatchWorkItem?
    @State private var activeSheet: SwapViewSheet?
    
    var onTap: ((SwapViewAction) -> Void)?
    
    // MARK: - Body
    var body: some View {
        VStack (spacing: 0) {
            SwapTitleView(selectedAccount: $viewModel.selectedAccount) { action in
                switch action {
                case .accountSelection:
                    onTap?(.selectAccount)
                case .info:
                    onTap?(.showInfo)
                }
            }
            ZStack {
                VStack (spacing: 0) {
                    AssetSelectionView(isPayingView: $viewModel.isPayingView, assetItem: $viewModel.selectedAssetIn, payingText: $viewModel.payingText, isLoading: .constant(false)) {
                        onTap?(.selectAssetIn(for: $viewModel.selectedAccount.wrappedValue))
                    }
                    AssetSelectionView(isPayingView: $viewModel.isPayingView.inverted, assetItem: $viewModel.selectedAssetOut, payingText: $viewModel.receivingText, isLoading: $viewModel.isLoadingQuote) {
                        onTap?(.selectAssetOut(for: $viewModel.selectedAccount.wrappedValue))
                    }
                }
                .padding(.horizontal, 8)
                .onChange(of: viewModel.payingText) { newValue in
                    debounceWorkItem?.cancel()
                    let task = DispatchWorkItem {
                        if
                            let text = newValue?.replacingOccurrences(of: ",", with: "."),
                            let doubleValue = Double(text),
                            doubleValue > 0
                        {
                            viewModel.payingText = Formatter.decimalFormatter(minimumFractionDigits: 2, maximumFractionDigits: 4).string(for: doubleValue)
                            viewModel.isLoadingQuote = true
                            onTap?(.getQuote(for: doubleValue))
                        } else {
                            viewModel.receivingText = nil
                        }
                    }
                    debounceWorkItem = task
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: task)
                }
                
                HStack {
                    SwitchSwapButton {
                        onTap?(.switchAssets)
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
                }
                .padding(.horizontal, 16)
            }
            
            if viewModel.shouldShowSwapButton {
                ProviderSelectionView(selectedProvider: $viewModel.provider) {
                    activeSheet = .provider
                }
                .padding(.top, 16)
                .padding(.bottom, 12)
                
                SwapButton {
                    guard viewModel.payingText != nil, viewModel.receivingText != nil else { return }
                    activeSheet = .confirmSwap
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.easeInOut, value: viewModel.shouldShowSwapButton)
            }
        }
        .padding(.top, safeAreaTopInset)
        .frame(maxHeight: .infinity, alignment: .top)
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .settings:
                SwapSettingsSheet()
            case .provider:
                ProviderSheet()
            case .confirmSwap:
                let viewModel = SwapConfirmViewModel(selectedAccount: viewModel.selectedAccount, selectedAssetIn: viewModel.selectedAssetIn, selectedAssetOut: viewModel.selectedAssetOut, selectedAssetInAmount: viewModel.payingText!, selectedAssetOutAmount: viewModel.receivingText!, price: viewModel.price, provider: viewModel.provider, slippageTolerance: viewModel.slippageTolerance, priceImpact: viewModel.priceImpact, minimumReceived: "", exchangeFee: "", peraFee: "")
                ConfirmSwapView(viewModel: viewModel) {
                    onTap?(.confirmSwap)
                }
            }
        }
    }
}
