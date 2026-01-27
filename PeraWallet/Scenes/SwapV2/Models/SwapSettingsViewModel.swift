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

final class SwapSettingsViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var percentageText: String = .empty
    @Published var slippageText: String = .empty
    @Published var useLocalCurrency: Bool = PeraUserDefaults.shouldUseLocalCurrencyInSwap ?? false
    @Published var localPercentageSelected: PercentageValue?
    @Published var localSlippageSelected: SlippageValue?
    
    // MARK: - Internal State
    private var slippageSelected: SlippageValue?
    
    // MARK: - Init
    init(slippageSelected: SlippageValue?) {
        self.slippageSelected = slippageSelected
        setupInitialValues()
    }
    
    // MARK: - Setup
    private func setupInitialValues() {
        guard let slippageSelected else { return }
        let slippageValue = slippageSelected.value * 100
        
        switch slippageSelected {
        case .custom:
            slippageText = slippageValue.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", slippageValue) : String(format: "%.1f", slippageValue)
            localSlippageSelected = slippageSelected
        case .c05:
            slippageText = String(format: "%.1f", slippageValue)
            localSlippageSelected = slippageSelected
        default:
            slippageText = String(format: "%.0f", slippageValue)
            localSlippageSelected = slippageSelected
        }
    }
    
    // MARK: - Helpers
    func updateText(_ newValue: String, for type: TextFieldType) {
        let formatted = DecimalInputFormatter.format(newValue)
        switch type {
        case .percentage:
            percentageText = formatted
            updatePercentageSelection(from: percentageText)
        case .slippage:
            slippageText = formatted
            updateSlippageSelection(from: slippageText)
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
        guard let doubleValue = Double(text) else {
            localSlippageSelected = .custom(value: 0)
            return
        }
        
        if let match = SlippageValue.allDefaultCases.first(where: { $0.value == doubleValue / 100 }) {
            localSlippageSelected = match
        } else {
            localSlippageSelected = .custom(value: doubleValue / 100)
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
