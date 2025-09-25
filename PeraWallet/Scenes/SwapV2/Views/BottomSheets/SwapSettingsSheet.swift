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

struct SwapSettingsSheet: View {
    @SwiftUI.Environment(\.dismiss) private var dismiss
    
    @State private var percentageText: String = .empty
    @State private var slippageText: String = .empty
    @State private var useLocalCurrency = PeraUserDefaults.shouldUseLocalCurrencyInSwap ?? false
    @State private var localPercentageSelected: PercentageValue?
    @State private var localSlippageSelected: SlippageValue?
    
    @Binding var slippageSelected: SlippageValue?
    
    var onApplyTap: (PercentageValue?, SlippageValue?) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            SheetTitleView(title: "title-swap-settings") { action in
                switch action {
                case .dismiss:
                    dismiss()
                case .apply:
                    if
                        localPercentageSelected == nil,
                        !percentageText.isEmpty,
                        let percentageValue = Double(percentageText)
                    {
                        localPercentageSelected = .custom(value: percentageValue / 100)
                    }
                    
                    PeraUserDefaults.shouldUseLocalCurrencyInSwap = useLocalCurrency
                    onApplyTap(localPercentageSelected, localSlippageSelected)
                    dismiss()
                }
            }
            
            Spacer().frame(height: 24)
            
            SwapSettingsTextField(title: "swap-amount-percentage-title", placeholder: "swap-amount-percentage-placeholder", text: $percentageText)
                .onChange(of: percentageText) { newValue in
                    if let doubleNewValue = Double(newValue) {
                        if let match = PercentageValue.allCases.first(where: { $0.value == doubleNewValue / 100 }) {
                            localPercentageSelected = match
                        } else {
                            localPercentageSelected = nil
                        }
                    } else {
                        localPercentageSelected = nil
                    }
                }
            
            Spacer().frame(height: 16)
            
            SwiftUI.ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(PercentageValue.allCases, id: \.self) { item in
                        SwapSettingsHListItem(
                            title: item.title,
                            isSelected: localPercentageSelected == item
                        ) {
                            percentageText = String(format: "%.0f", item.value * 100)
                            localPercentageSelected = item
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            Spacer().frame(height: 40)
            
            SwapSettingsTextField(title: "swap-slippage-title", placeholder: "swap-slippage-placeholder", text: $slippageText)
                .onChange(of: slippageText) { newValue in
                    if let doubleNewValue = Double(newValue) {
                        if let match = SlippageValue.allCases.first(where: { $0.value == doubleNewValue / 100 }) {
                            localSlippageSelected = match
                        } else {
                            localSlippageSelected = .custom
                        }
                    } else {
                        localSlippageSelected = .custom
                    }
                }
            
            Spacer().frame(height: 16)
            
            SwiftUI.ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(SlippageValue.allCases, id: \.self) { item in
                        SwapSettingsHListItem(
                            title: item.title,
                            isSelected: localSlippageSelected == item
                        ) {
                            switch item {
                            case .custom:
                                slippageText = .empty
                            case .c05:
                                slippageText = String(format: "%.1f", item.value * 100)
                            default:
                                slippageText = String(format: "%.0f", item.value * 100)
                            }
                            localSlippageSelected = item
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
        .onAppear {
            if let slippageSelected {
                switch slippageSelected {
                case .custom:
                    slippageText = .empty
                case .c05:
                    slippageText = String(format: "%.1f", slippageSelected.value * 100)
                    localSlippageSelected = slippageSelected
                default:
                    slippageText = String(format: "%.0f", slippageSelected.value * 100)
                    localSlippageSelected = slippageSelected
                }
            }
        }
    }
}
