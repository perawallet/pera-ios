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

//   SwapSettingsViewModel.swift

import SwiftUI
import pera_wallet_core

// FIXME: This class mixes ViewModel and Model logic.
// It should be refactored to follow a proper MVVM structure by
// moving business and formatting logic into dedicated services.
final class SwapSettingsViewModel: ObservableObject {
    @Published var percentageText: String = .empty
    @Published var slippageText: String = .empty
    @Published var useLocalCurrency: Bool = PeraUserDefaults.shouldUseLocalCurrencyInSwap ?? false
    @Published var localPercentageSelected: PercentageValue?
    @Published var localSlippageSelected: SlippageValue?
    
    var slippageSelected: SlippageValue?
    
    init(slippageSelected: SlippageValue?) {
        self.slippageSelected = slippageSelected
        setupInitialValues()
    }
    
    private func setupInitialValues() {
        guard let slippageSelected else { return }
        
        switch slippageSelected {
        case .custom:
            slippageText = .empty
            localSlippageSelected = .custom
        case .c05:
            slippageText = String(format: "%.1f", slippageSelected.value * 100)
            localSlippageSelected = slippageSelected
        default:
            slippageText = String(format: "%.0f", slippageSelected.value * 100)
            localSlippageSelected = slippageSelected
        }
    }
    
    func updateText(_ newValue: String, for type: TextFieldType) {
        let formatted = DecimalInputFormatter.format(newValue)
        switch type {
        case .percentage:
            percentageText = formatted
        case .slippage:
            slippageText = formatted
        }
    }
    
    func updatePercentageSelection(from text: String) {
        if let doubleValue = Double(text),
           let match = PercentageValue.allCases.first(where: { $0.value == doubleValue / 100 }) {
            localPercentageSelected = match
        } else {
            localPercentageSelected = nil
        }
    }
    
    func updateSlippageSelection(from text: String) {
        if let doubleValue = Double(text),
           let match = SlippageValue.allCases.first(where: { $0.value == doubleValue / 100 }) {
            localSlippageSelected = match
        } else {
            localSlippageSelected = .custom
        }
    }
    
    func applyChanges() {
        if
            localPercentageSelected == nil,
            !percentageText.isEmpty,
            let percentageValue = Double(percentageText)
        {
            localPercentageSelected = .custom(value: percentageValue / 100)
        }
        PeraUserDefaults.shouldUseLocalCurrencyInSwap = useLocalCurrency
    }
}

enum TextFieldType {
    case percentage, slippage
    
    var title: LocalizedStringKey {
        switch self {
        case .percentage: "swap-amount-percentage-title"
        case .slippage: "swap-slippage-title"
        }
    }
    
    var placeholder: LocalizedStringKey {
        switch self {
        case .percentage: "swap-amount-percentage-placeholder"
        case .slippage: "swap-slippage-placeholder"
        }
    }
}
