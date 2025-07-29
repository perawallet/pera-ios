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

struct SwapView: View {
    
    // MARK: - Properties
    @State private var assetDefaultIcon = Image("icon-algo-circle")
    @State private var assetDefaultText = String(localized: "title-algo")
    @State private var accountDefaultIcon = Image("icon-standard-account")
    @State private var accountDefaultText = String(localized: "title-main-account")
    @State private var payingBalanceText = String(format: String(localized: "swap-asset-amount-title-balance"), "62,045.00")
    @State private var receivingBalanceText = String(format: String(localized: "swap-asset-amount-title-balance"), "3,495.00 USDC")
    @State private var isPayingView = true
    private var isReceivingView: Binding<Bool> {
        Binding(
            get: { !isPayingView },
            set: { isPayingView = !$0 }
        )
    }
    
    // MARK: - Body
    var body: some View {
        VStack (spacing: 0) {
            SwapTitleView(accountSelectionIcon: $accountDefaultIcon, accountSelectionText: $accountDefaultText) { action in
                switch action {
                case .accountSelection:
                    print("onAccountSelectionTap")
                case .info:
                    print("onInfoTap")
                }
            }
            ZStack {
                VStack (spacing: 0) {
                    AssetSelectionView(isPayingView: $isPayingView, balanceText: $payingBalanceText, icon: $assetDefaultIcon, text: $assetDefaultText) {
                        print("AssetSelectionView")
                    }
                    AssetSelectionView(isPayingView: isReceivingView, balanceText: $receivingBalanceText, icon: $assetDefaultIcon, text: $assetDefaultText) {
                        print("AssetSelectionView")
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
                            print("SettingsSwapButton-settings")
                        case .max:
                            print("SettingsSwapButton-max")
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }
}
