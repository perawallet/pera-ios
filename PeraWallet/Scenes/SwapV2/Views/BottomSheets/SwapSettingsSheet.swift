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
    
    @StateObject private var viewModel: SwapSettingsViewModel
    
    let onApplyTap: (PercentageValue?, SlippageValue?) -> Void
    let onAnalyticsEvent: (SwapAnalyticsEvent) -> Void
    
    init(slippageSelected: SlippageValue?, onApplyTap: @escaping (PercentageValue?, SlippageValue?) -> Void, onAnalyticsEvent: @escaping (SwapAnalyticsEvent) -> Void) {
        _viewModel = StateObject(wrappedValue: SwapSettingsViewModel(slippageSelected: slippageSelected))
        self.onApplyTap = onApplyTap
        self.onAnalyticsEvent = onAnalyticsEvent
    }

    
    var body: some View {
        VStack(spacing: 0) {
            SheetTitleView(title: "title-swap-settings") { action in
                switch action {
                case .dismiss:
                    onAnalyticsEvent(.swapSettingsClose)
                    dismiss()
                case .apply:
                    if viewModel.localPercentageSelected == nil,
                      !viewModel.percentageText.isEmpty,
                      let percentageValue = Double(viewModel.percentageText) {
                       viewModel.localPercentageSelected = .custom(value: percentageValue / 100)
                   }
                    
                    PeraUserDefaults.shouldUseLocalCurrencyInSwap = viewModel.useLocalCurrency
                    onApplyTap(viewModel.localPercentageSelected, viewModel.localSlippageSelected)
                    dismiss()
                }
            }
            
            Spacer().frame(height: 24)
            
            SwapSettingsTextField(textFieldType: .percentage, text: $viewModel.percentageText, viewModel: viewModel)
                .onChange(of: viewModel.percentageText) { viewModel.updatePercentageSelection(from: $0)}
            
            Spacer().frame(height: 16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(PercentageValue.allCases, id: \.self) { item in
                        SwapSettingsHListItem(
                            title: item.title,
                            isSelected: viewModel.localPercentageSelected == item
                        ) {
                            onAnalyticsEvent(.swapSettingsPercentage(value: "\(item.value)"))
                            viewModel.percentageText = String(format: "%.0f", item.value * 100)
                            viewModel.localPercentageSelected = item
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            Spacer().frame(height: 40)
            
            SwapSettingsTextField(textFieldType: .slippage, text: $viewModel.slippageText, viewModel: viewModel)
                .onChange(of: viewModel.slippageText) { viewModel.updateSlippageSelection(from: $0)}
            
            Spacer().frame(height: 16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(SlippageValue.allCases, id: \.self) { item in
                        SwapSettingsHListItem(
                            title: item.title,
                            isSelected: viewModel.localSlippageSelected == item
                        ) {
                            onAnalyticsEvent(.swapSettingsSlippage(value: "\(item.value)"))
                            switch item {
                            case .custom:
                                viewModel.slippageText = .empty
                            case .c05:
                                viewModel.slippageText = String(format: "%.1f", item.value * 100)
                            default:
                                viewModel.slippageText = String(format: "%.0f", item.value * 100)
                            }
                            viewModel.localSlippageSelected = item
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            Spacer().frame(height: 40)
            
            SwapSettingsToogle(
                title: "primary-currency-title",
                text: "use-local-currency-text",
                isOn: $viewModel.useLocalCurrency
            )
            .onChange(of: viewModel.useLocalCurrency) { newValue in
                onAnalyticsEvent(.swapSettingsLocalCurrency(on: newValue))
            }
            
            Spacer()
            
        }
        .padding(.horizontal, 24)
        .background(Color.Defaults.bg)
        .presentationDetents([.height(600)])
        .presentationDragIndicator(.hidden)
    }
}
