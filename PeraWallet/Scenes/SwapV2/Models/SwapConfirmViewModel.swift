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
    let selectedAssetInAmountInUSD: String
    let selectedAssetOutAmountInUSD: String
    let price: String
    let provider: SwapProviderV2
    let slippageTolerance: String
    let priceImpact: String
    let minimumReceived: String
    let exchangeFee: String
    let peraFee: String
    
    @Published var confirmationState: ConfirmSlideButtonState = .idle
    
    init(
        selectedAccount: Account,
        selectedAssetIn: AssetItem,
        selectedAssetOut: AssetItem,
        selectedAssetInAmount: String,
        selectedAssetOutAmount: String,
        selectedAssetInAmountInUSD: String,
        selectedAssetOutAmountInUSD: String,
        price: String,
        provider: SwapProviderV2,
        slippageTolerance: String,
        priceImpact: String,
        minimumReceived: String,
        exchangeFee: String,
        peraFee: String,
        confirmationState: ConfirmSlideButtonState
    ) {
        self.selectedAccount = selectedAccount
        self.selectedAssetIn = selectedAssetIn
        self.selectedAssetOut = selectedAssetOut
        self.selectedAssetInAmount = selectedAssetInAmount
        self.selectedAssetOutAmount = selectedAssetOutAmount
        self.selectedAssetInAmountInUSD = selectedAssetInAmountInUSD
        self.selectedAssetOutAmountInUSD = selectedAssetOutAmountInUSD
        self.price = price
        self.provider = provider
        self.slippageTolerance = slippageTolerance
        self.priceImpact = priceImpact
        self.minimumReceived = minimumReceived
        self.exchangeFee = exchangeFee
        self.peraFee = peraFee
        self.confirmationState = confirmationState
    }
}

enum ConfirmSlideButtonState {
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
