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
    case info
    case accountSelection
    case payAssetSelection
    case receiveAssetSelection
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
    @Binding var selectedAccount: Account?
    
    @State private var assetDefaultIcon = Image("icon-algo-circle")
    @State private var assetDefaultText = String(localized: "title-algo")
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
    @State private var shouldShowProvider = false
    @State private var shouldShowSwapButton = true
    
    @State private var activeSheet: SwapViewSheet?
    
    var onTap: ((SwapViewAction) -> Void)?
    
    // MARK: - Body
    var body: some View {
        VStack (spacing: 0) {
            SwapTitleView(account: $selectedAccount) { action in
                switch action {
                case .accountSelection:
                    onTap?(.accountSelection)
                case .info:
                    onTap?(.info)
                }
            }
            ZStack {
                VStack (spacing: 0) {
                    AssetSelectionView(isPayingView: $isPayingView, balanceText: $payingBalanceText, icon: $assetDefaultIcon, text: $assetDefaultText) {
                        onTap?(.payAssetSelection)
                    }
                    AssetSelectionView(isPayingView: isReceivingView, balanceText: $receivingBalanceText, icon: $assetDefaultIcon, text: $assetDefaultText) {
                        onTap?(.receiveAssetSelection)
                    }
                }
                .padding(.horizontal, 8)
                HStack {
                    SwitchSwapButton {
                        print("SwitchSwapButton")
                    }
                    Spacer()
                    SettingsSwapButton { action in
                        switch action {
                        case .settings:
                            activeSheet = .settings
                        case .max:
                            print("SettingsSwapButton-max")
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
                ConfirmSwapView(account: selectedAccount!)
            }
        }
    }
}
