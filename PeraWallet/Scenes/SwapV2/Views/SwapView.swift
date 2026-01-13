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

//   SwapView.swift

import SwiftUI
import Combine
import pera_wallet_core
import MacaroonVendors

enum SwapViewAction {
    case showInfo
    case selectAccount
    case selectAssetIn(for: Account)
    case selectAssetOut(for: Account)
    case getQuote(for: Double)
    case confirmSwap
    case showSwapConfirmationBanner(success: String?, error: String?)
    case calculatePeraFee(forAmount: Double, withPercentage: Double)
    case selectSwap(assetIn: SwapAsset, assetOut: SwapAsset)
    case openExplorer(transactionGroupId: String, pairing: String)
    case trackAnalytics(event: SwapAnalyticsEvent)
    case onSwitchAssets
}

enum SwapAnalyticsEvent {
    case swapHistorySeeAll
    case swapHistorySelect(pairing: String)
    case swapTopPairSelect(pairing: String)
    case swapSelectProvider
    case swapSelectProviderClose
    case swapSelectProviderApply
    case swapSelectProviderRouter(name: String)
    case swapSettingsClose
    case swapSettingsApply
    case swapSettingsPercentage(value: String)
    case swapSettingsSlippage(value: String)
    case swapSettingsLocalCurrency(on: Bool)
    case swapConfirmTapped
}

enum SwapViewSheet: Identifiable {
    case settings
    case provider(availableProviders: [SwapProviderV2])
    case confirmSwap
    case swapHistory
    
    var id: String {
        switch self {
        case .settings: return "settings"
        case .provider: return "provider"
        case .confirmSwap: return "confirmSwap"
        case .swapHistory: return "swapHistory"
        }
    }
}

struct SwapView: View {
    
    // MARK: - Properties
    @ObservedObject var viewModel: SwapSharedViewModel
    var onAction: ((SwapViewAction) -> Void)?
    
    @State private var activeSheet: SwapViewSheet?
    
    // MARK: - Body
    var body: some View {
        VStack (spacing: 0) {
            headerView
            ScrollView {
                VStack (spacing: 0) {
                    assetSelectionView
                    if viewModel.shouldShowSwapButton {
                        swapActionView
                    }
                    
                    SwapHistoryListView(viewModel: SwapHistoryViewModel(swapHistoryList: viewModel.swapHistoryList)) { swapHistory in
                        onAction?(.trackAnalytics(event: .swapHistorySelect(pairing: swapHistory.title)))
                        onAction?(.selectSwap(assetIn: swapHistory.assetIn, assetOut: swapHistory.assetOut))
                    } onSeeAllTap: {
                        onAction?(.trackAnalytics(event: .swapHistorySeeAll))
                        activeSheet = .swapHistory
                    }
                    
                    SwapTopPairsListView(viewModel: SwapTopPairViewModel(swapTopPairsList: viewModel.swapTopPairsList)) { swapTopPair in
                        onAction?(.trackAnalytics(event: .swapTopPairSelect(pairing: swapTopPair.title)))
                        onAction?(.selectSwap(assetIn: swapTopPair.assetA, assetOut: swapTopPair.assetB))
                    }
                }
                .frame(maxHeight: .infinity, alignment: .top)
                .sheet(item: $activeSheet, content: sheetContent)
                .onChange(of: viewModel.selectedProvider) { newValue in
                    viewModel.selectQuote(with: newValue)
                }
            }
        }
        .background(Color.Defaults.bg)
    }
    
    // MARK: - Subviews
    
    private var headerView: some View {
        SwapTitleView(selectedAccount: $viewModel.selectedAccount) { action in
            switch action {
            case .accountSelection:
                onAction?(.selectAccount)
            case .info:
                onAction?(.showInfo)
            }
        }
    }
    
    private var assetSelectionView: some View {
        ZStack {
            VStack (spacing: 0) {
                AssetSelectionView(
                    type: .pay,
                    assetItem: $viewModel.selectedAssetIn,
                    network: $viewModel.selectedNetwork,
                    amountText: Binding(
                        get: { viewModel.payingText },
                        set: { newValue in
                            let filteredValue = viewModel.filterPayingText(newValue)
                            guard filteredValue != viewModel.payingText else { return }
                            
                            viewModel.payingText = filteredValue
                            viewModel.updatePayingText(filteredValue) {
                                onAction?(.getQuote(for: $0))
                            }
                        }
                    ),
                    amountTextInSecondaryCurrency: Binding(
                        get: { viewModel.payingTextInSecondaryCurrency.isEmpty ?
                            (PeraUserDefaults.shouldUseLocalCurrencyInSwap ?? false ? SwapSharedViewModel.defaultAmountValue : viewModel.fiatFormat(with: 0.0))
                            : viewModel.payingTextInSecondaryCurrency },
                        set: { viewModel.payingTextInSecondaryCurrency = $0 }
                    ),
                    isLoading: $viewModel.isLoadingPayAmount,
                    isLoadingQuote: Binding<Bool?>(
                        get: { viewModel.isLoadingReceiveAmount },
                        set: { viewModel.isLoadingReceiveAmount = $0 ?? false }
                    ),
                    isBalanceNotSufficient: $viewModel.isBalanceNotSufficient
                ) {
                    onAction?(.selectAssetIn(for: $viewModel.selectedAccount.wrappedValue))
                }
                AssetSelectionView(
                    type: .receive,
                    assetItem: $viewModel.selectedAssetOut,
                    network: $viewModel.selectedNetwork,
                    amountText: $viewModel.receivingText,
                    amountTextInSecondaryCurrency: Binding(
                        get: { viewModel.receivingTextInSecondaryCurrency.isEmpty
                            ? (PeraUserDefaults.shouldUseLocalCurrencyInSwap ?? false ? SwapSharedViewModel.defaultAmountValue : viewModel.fiatFormat(with: 0.0))
                            : viewModel.receivingTextInSecondaryCurrency },
                        set: { viewModel.receivingTextInSecondaryCurrency = $0 }
                    ),
                    isLoading: $viewModel.isLoadingReceiveAmount,
                    isLoadingQuote: .constant(nil),
                    isBalanceNotSufficient: .constant(false)
                ) {
                    onAction?(.selectAssetOut(for: $viewModel.selectedAccount.wrappedValue))
                }
            }
            .padding(.horizontal, 8)
            
            HStack {
                SwitchSwapButton {
                    viewModel.switchAssets {
                        onAction?(.onSwitchAssets)
                        viewModel.updatePayingText(viewModel.payingText) { onAction?(.getQuote(for: $0)) }
                    }
                }
                Spacer()
                SettingsSwapButton { action in
                    switch action {
                    case .settings:
                        activeSheet = .settings
                    case .max:
                        handlePercentageChange(.max)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, viewModel.isBalanceNotSufficient ? 50 : 0)
        }
    }
    
    private var swapActionView: some View {
        VStack(spacing: 0) {
            providerSelectionView
            SwapButton {
                guard !viewModel.payingText.isEmpty, !viewModel.receivingText.isEmpty else { return }
                onAction?(.trackAnalytics(event: .swapConfirmTapped))
                activeSheet = .confirmSwap
            }
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .animation(.easeInOut, value: viewModel.shouldShowSwapButton)
        }
    }
    
    private var providerSelectionView: some View {
        let providerViewModel = ProviderSelectionViewModel(providerId: viewModel.selectedProvider.providerId, iconUrl: viewModel.activeProvider?.iconUrl ?? .empty, displayName: viewModel.activeProvider?.displayName ?? .empty, rate: viewModel.providerRate)
        
        return ProviderSelectionView(viewModel: providerViewModel) {
            guard let providers = viewModel.availableProviders else { return }
            onAction?(.trackAnalytics(event: .swapSelectProvider))
            activeSheet = .provider(availableProviders: providers)
        }
        .padding(.top, 16)
        .padding(.bottom, 12)
    }
    
    @ViewBuilder
    private func sheetContent(for sheet: SwapViewSheet) -> some View {
        switch sheet {
        case .settings:
            SwapSettingsSheet(slippageSelected: viewModel.slippageSelected) { newPercentageSelected, newSlippageSelected in
                onAction?(.trackAnalytics(event: .swapSettingsApply))
                if let newPercentageSelected {
                    handlePercentageChange(newPercentageSelected)
                } else {
                    updateValuesAfterSettingsApplied()
                }
                handleSlippageChange(newSlippageSelected)
            } onAnalyticsEvent: { event in
                onAction?(.trackAnalytics(event: event))
            }
        case .provider(availableProviders: let providers):
            let vm = ProviderSheetViewModel(
                selectedProvider: viewModel.selectedProvider,
                availableProviders: providers,
                quoteList: viewModel.quoteList
            )
            ProviderSheet(viewModel: vm) { selectedProvider in
                onAction?(.trackAnalytics(event: .swapSelectProviderApply))
                viewModel.selectedProvider = selectedProvider
            } onAnalyticsEvent: { event in
                onAction?(.trackAnalytics(event: event))
            }
        case .confirmSwap:
            if let confirmSwapModel = viewModel.confirmSwapModel() {
                ConfirmSwapView(viewModel: confirmSwapModel) {
                    onAction?(.confirmSwap)
                } onSwapSuccess: { successMessage in
                    onAction?(.showSwapConfirmationBanner(success: successMessage, error: nil))
                } onSwapError: { errorMessage in
                    onAction?(.showSwapConfirmationBanner(success: nil, error: errorMessage))
                }
            }
        case .swapHistory:
            SwapHistorySheet(viewModel: SwapHistoryViewModel(swapHistoryList: viewModel.swapHistoryList)) { swapHistory in
                guard let transactionGroupId = swapHistory.transactionGroupId else { return }
                onAction?(.openExplorer(transactionGroupId: transactionGroupId, pairing: swapHistory.title))
            }
        }
    }
    
    private func handlePercentageChange(_ newPercentage: PercentageValue) {
        viewModel.isLoadingPayAmount = true
        let amount = NSDecimalNumber(decimal: viewModel.selectedAssetIn.asset.decimalAmount).doubleValue
        viewModel.isBalanceNotSufficient = amount > NSDecimalNumber(decimal: viewModel.selectedAssetIn.asset.decimalAmount).doubleValue
        onAction?(.calculatePeraFee(forAmount: amount, withPercentage: newPercentage.value))
    }
    
    private func handleSlippageChange(_ newSlippage: SlippageValue?) {
        let slippageChanged = viewModel.slippageSelected != newSlippage
        viewModel.slippageSelected = (newSlippage?.value ?? 0) > 0 ? newSlippage : nil
        
        if slippageChanged && viewModel.shouldShowSwapButton {
            viewModel.updatePayingText(viewModel.payingText) { onAction?(.getQuote(for: $0)) }
        }
    }
    
    private func updateValuesAfterSettingsApplied() {
        let value = viewModel.payingText.numericValue()
        if PeraUserDefaults.shouldUseLocalCurrencyInSwap ?? false {
            viewModel.payingText = viewModel.fiatFormat(with: value)
        } else {
            viewModel.payingText = String(value)
        }
        viewModel.updatePayingText(viewModel.payingText) { onAction?(.getQuote(for: $0)) }
    }
}
