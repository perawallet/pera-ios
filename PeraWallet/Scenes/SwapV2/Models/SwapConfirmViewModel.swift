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

//   SwapConfirmViewModel.swift

import pera_wallet_core
import SwiftUI

class SwapConfirmViewModel: ObservableObject {
    let selectedAccount: Account
    let selectedAssetIn: AssetItem
    let selectedAssetOut: AssetItem
    let selectedAssetInAmount: String
    let selectedAssetOutAmount: String
    let selectedAssetInAmountInSecondaryCurrency: String
    let selectedAssetOutAmountInSecondaryCurrency: String
    let price: String
    let provider: SwapProviderV2
    let slippageTolerance: String
    let priceImpact: String
    let minimumReceived: String
    let exchangeFee: String
    let peraFee: String
    let selectedNetwork: ALGAPI.Network
    
    @Published var confirmationState: ConfirmSlideButtonState = .idle
    
    init(
        selectedAccount: Account,
        selectedAssetIn: AssetItem,
        selectedAssetOut: AssetItem,
        selectedAssetInAmount: String,
        selectedAssetOutAmount: String,
        selectedAssetInAmountInSecondaryCurrency: String,
        selectedAssetOutAmountInSecondaryCurrency: String,
        price: String,
        provider: SwapProviderV2,
        slippageTolerance: String,
        priceImpact: String,
        minimumReceived: String,
        exchangeFee: String,
        peraFee: String,
        confirmationState: ConfirmSlideButtonState,
        selectedNetwork: ALGAPI.Network
    ) {
        self.selectedAccount = selectedAccount
        self.selectedAssetIn = selectedAssetIn
        self.selectedAssetOut = selectedAssetOut
        self.selectedAssetInAmount = selectedAssetInAmount
        self.selectedAssetOutAmount = selectedAssetOutAmount
        self.selectedAssetInAmountInSecondaryCurrency = selectedAssetInAmountInSecondaryCurrency
        self.selectedAssetOutAmountInSecondaryCurrency = selectedAssetOutAmountInSecondaryCurrency
        self.price = price
        self.provider = provider
        self.slippageTolerance = slippageTolerance
        self.priceImpact = priceImpact
        self.minimumReceived = minimumReceived
        self.exchangeFee = exchangeFee
        self.peraFee = peraFee
        self.confirmationState = confirmationState
        self.selectedNetwork = selectedNetwork
    }
}

extension SwapConfirmViewModel {
    private var priceImpactValue: Double? {
        Double(priceImpact.replacingOccurrences(of: "%", with: ""))
    }
    
    var highPriceImpactWarning: LocalizedStringKey? {
        guard let value = priceImpactValue else {
            return nil
        }
        
        switch value {
        case let v where v > 15:
            return "swap-price-impact-greater-than-15-warning-message"
        case let v where v > 5:
            return "swap-price-impact-warning-message"
        default:
            return nil
        }
    }
    
    var isSwapDisabled: Bool {
        (priceImpactValue ?? 0) > 15
    }
}

enum ConfirmSlideButtonState: Equatable {
    case idle
    case loading
    case success
    case error
    
    var buttonBackgroundColor: Color {
        switch self {
        case .idle, .loading:
            Color.ButtonHelper.peraIcon
        case .success:
            Color.Helpers.positive
        case .error:
            Color.Helpers.negative
        }
    }
    
    var buttonAndTextOpacity: Double {
        switch self {
        case .idle:
            return 1
        case .success, .error, .loading:
            return 0
        }
    }
    
    var iconName: String? {
        switch self {
        case .idle, .loading:
            return nil
        case .success:
            return "icon-success-24"
        case .error:
            return "icon-info-24"
        }
    }
    
}
