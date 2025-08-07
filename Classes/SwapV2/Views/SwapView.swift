// Copyright 2025 Pera Wallet, LDA

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

enum SwapViewAction {
    case showInfo
    case selectAccount
    case selectAssetIn(for: Account)
    case selectAssetOut(for: Account)
    case switchAssets
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
    let bindings: SwapViewBindings
    
    @State private var payingBalanceText = String(format: String(localized: "swap-asset-amount-title-balance"), "62,045.00")
    @State private var receivingBalanceText = String(format: String(localized: "swap-asset-amount-title-balance"), "3,495.00 USDC")
    @State private var providerIcon = Image("icon-shield-16")
    @State private var providerText = "Vestige.fi"
    @State private var exchangeRateText = "1 ALGO ≈ 0.17 USDC"
    
    private var safeAreaTopInset: CGFloat {
        (UIApplication.shared.connectedScenes.first as? UIWindowScene)?
            .windows.first?.safeAreaInsets.top ?? 44
    }
    
    @State private var isPayingView = true
    private var isReceivingView: Binding<Bool> {
        Binding(
            get: { !isPayingView },
            set: { isPayingView = !$0 }
        )
    }
    @State private var payingText: String?
    @State private var receivingText: String?
    
    @State private var applyMaxBalance = false
    @State private var shouldShowProvider = false
    @State private var shouldShowSwapButton = true
    
    @State private var activeSheet: SwapViewSheet?
    
    var onTap: ((SwapViewAction) -> Void)?
    
    // MARK: - Body
    var body: some View {
        VStack (spacing: 0) {
            SwapTitleView(selectedAccount: bindings.selectedAccount) { action in
                switch action {
                case .accountSelection:
                    onTap?(.selectAccount)
                case .info:
                    onTap?(.showInfo)
                }
            }
            ZStack {
                VStack (spacing: 0) {
                    AssetSelectionView(isPayingView: $isPayingView, assetItem: bindings.selectedAssetIn, balanceText: $payingText) {
                        onTap?(.selectAssetIn(for: bindings.selectedAccount.wrappedValue))
                    }
                    AssetSelectionView(isPayingView: isReceivingView, assetItem: bindings.selectedAssetOut, balanceText: $receivingText) {
                        onTap?(.selectAssetOut(for: bindings.selectedAccount.wrappedValue))
                    }
                }
                .padding(.horizontal, 8)
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
            if shouldShowProvider {
                ProviderSelectionView(providerIcon: $providerIcon, providerName: $providerText, exchangeRateText: $exchangeRateText) {
                    activeSheet = .provider
                }
                .padding(.top, 16)
                .padding(.bottom, 12)
            }
            if shouldShowSwapButton {
                SwapButton {
                    activeSheet = .confirmSwap
                }
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
                ConfirmSwapView(account: bindings.selectedAccount.wrappedValue)
            }
        }
    }
}
