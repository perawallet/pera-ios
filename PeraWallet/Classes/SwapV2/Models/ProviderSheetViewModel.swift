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

//   ProviderSheetViewModel.swift

import SwiftUI
import pera_wallet_core

enum SelectedProvider: Equatable {
    case auto
    case provider(String)
    
    static func == (lhs: SelectedProvider, rhs: SelectedProvider) -> Bool {
        switch (lhs, rhs) {
        case (.auto, .auto):
            return true
        case let (.provider(a), .provider(b)):
            return a == b
        default:
            return false
        }
    }
    
    var isAuto: Bool {
        switch self {
        case .auto:
            return true
        case .provider:
            return false
        }
    }
    
    var providerId: String {
        switch self {
        case .auto:
            return "auto"
        case let .provider(id):
            return id
        }
    }
}

final class ProviderSheetViewModel: ObservableObject {
    @Published var selectedProvider: SelectedProvider
    var availableProviders: [SwapProviderV2]
    var quoteList: [SwapQuote]?
    
    var height: CGFloat {
        CGFloat(150 + ((availableProviders.count + 1) * 72))
    }
    
    init(
        selectedProvider: SelectedProvider,
        availableProviders: [SwapProviderV2],
        quoteList: [SwapQuote]?
    ) {
        self.selectedProvider = selectedProvider
        self.availableProviders = availableProviders
        self.quoteList = quoteList
    }
    
    func quotePrimaryValue(for providerID: String) -> String {
        guard let quoteList = quoteList else { return "-" }
        
        let amount = quoteList.first { $0.provider?.rawValue == providerID }?.amountOutUSDValue
        
        
        return Formatter.decimalFormatter(minimumFractionDigits: 0, maximumFractionDigits: 8).string(for: amount) ?? "-"
    }
    
    func quoteSecondaryValue(for providerID: String) -> String {
        return "-"
    }
}
