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

//   SwapSettingsSheet.swift

import SwiftUI
import pera_wallet_core

enum PercentageValue: CaseIterable {
    case p25, p50, p75, max
    
    var title: String {
        switch self {
        case .p25: return "25%"
        case .p50: return "50%"
        case .p75: return "75%"
        case .max: return "MAX"
        }
    }
    
    var value: Double {
        switch self {
        case .p25: return 0.25
        case .p50: return 0.5
        case .p75: return 0.75
        case .max: return 1
        }
    }
}

enum SlippageValue: CaseIterable {
    case custom, c05, c1, c2, c5
    
    var title: String {
        switch self {
        case .custom: return "Custom"
        case .c05: return "0.5%"
        case .c1: return "1%"
        case .c2: return "2%"
        case .c5: return "5%"
        }
    }
    
    var value: Double {
        switch self {
        case .custom: return 0
        case .c05: return 0.5
        case .c1: return 1
        case .c2: return 2
        case .c5: return 5
        }
    }
}

struct SwapSettingsSheet: View {
    @SwiftUI.Environment(\.dismiss) private var dismiss
    
    var onApplyTap: (PercentageValue?, SlippageValue?) -> Void
    
    @State private var percentageText: String = .empty
    @State private var slippageText: String = .empty
    @State private var useLocalCurrency = PeraUserDefaults.shouldUseLocalCurrencyInSwap ?? false
    
    @State private var percentageSelected: PercentageValue? = nil
    @State private var slippageSelected: SlippageValue? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            SheetTitleView(title: "title-swap-settings") { action in
                switch action {
                case .dismiss:
                    dismiss()
                case .apply:
                    PeraUserDefaults.shouldUseLocalCurrencyInSwap = useLocalCurrency
                    onApplyTap(percentageSelected, slippageSelected)
                    dismiss()
                }
            }
            
            Spacer().frame(height: 24)
            
            SwapSettingsTextField(title: "swap-amount-percentage-title", placeholder: "swap-amount-percentage-placeholder", text: $percentageText)
                .onChange(of: percentageText) { newValue in
                    if !newValue.isEmpty {
                        percentageSelected = nil
                    }
                }
            
            Spacer().frame(height: 16)
            
            SwiftUI.ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(PercentageValue.allCases, id: \.self) { item in
                        SwapSettingsHListItem(
                            title: item.title,
                            isSelected: percentageSelected == item
                        ) {
                            percentageText = .empty
                            percentageSelected = item
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            Spacer().frame(height: 40)
            
            SwapSettingsTextField(title: "swap-slippage-title", placeholder: "swap-slippage-placeholder", text: $slippageText)
                .onChange(of: slippageText) { newValue in
                    if !newValue.isEmpty {
                        slippageSelected = nil
                    }
                }
            
            Spacer().frame(height: 16)
            
            SwiftUI.ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(SlippageValue.allCases, id: \.self) { item in
                        SwapSettingsHListItem(
                            title: item.title,
                            isSelected: slippageSelected == item
                        ) {
                            slippageText = .empty
                            slippageSelected = item
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            Spacer().frame(height: 40)
            
            SwapSettingsToogle(
                title: "primary-currency-title",
                text: "use-local-currency-text",
                isOn: $useLocalCurrency
            )
            
            Spacer()
            
        }
        .padding(.horizontal, 24)
        .background(Color.Defaults.bg)
        .presentationDetents([.height(600)])
        .presentationDragIndicator(.hidden)
    }
}
