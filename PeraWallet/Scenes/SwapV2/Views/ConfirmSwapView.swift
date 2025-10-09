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

//   ConfirmSwapView.swift

import SwiftUI
import pera_wallet_core

enum SwapInfoSheet: Identifiable {
    case slippageTolerance
    case priceImpact
    case exchangeFee
    
    var id: String {
        switch self {
        case .slippageTolerance: "slippageTolerance"
        case .priceImpact: "priceImpact"
        case .exchangeFee: "exchangeFee"
        }
    }
    
    var title: LocalizedStringKey {
        switch self {
        case .slippageTolerance: "swap-slippage-title"
        case .priceImpact: "swap-price-impact-title"
        case .exchangeFee: "title-exchange-fee"
        }
    }
    
    var text: LocalizedStringKey {
        switch self {
        case .slippageTolerance: "swap-slippage-tolerance-info-body"
        case .priceImpact: "swap-price-impact-info-body"
        case .exchangeFee: "swap-exchange-fee-info-body"
        }
    }
    
    var height: CGFloat {
        switch self {
        case .slippageTolerance: 320
        case .exchangeFee: 280
        case .priceImpact: 250
        }
    }
}

struct ConfirmSwapView: View {
    @SwiftUI.Environment(\.dismiss) private var dismiss
    
    @ObservedObject var viewModel: SwapConfirmViewModel
    
    @State private var activeSheet: SwapInfoSheet?
    
    var onConfirmTap: () -> Void
    var onSwapSuccess: (String) -> Void
    var onSwapError: (String) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                HStack {
                    SwiftUI.Button(action: {
                        dismiss()
                    }) {
                        Image(.iconClose)
                            .frame(width: 24, height: 24)
                    }
                    Spacer()
                }
                .frame(maxHeight: .infinity, alignment: .center)
                .padding(.horizontal, 24)
                VStack {
                    Text("swap-confirm-title")
                        .font(.dmSans.medium.size(15))
                        .foregroundStyle(Color.Text.main)
                    Spacer().frame(height: 2)
                    HStack {
                        Image(uiImage: viewModel.selectedAccount.typeImage)
                            .resizable()
                            .frame(width: 16, height: 16)
                        Spacer().frame(width: 6)
                        Text(viewModel.selectedAccount.primaryDisplayName)
                            .font(.dmSans.regular.size(13))
                            .foregroundStyle(Color.Text.gray)
                    }
                }
            }
            .frame(height: 60)
            .padding(.top, 8)
            .padding(.bottom, 10)
            ConfirmSwapAssetView(assetItem: viewModel.selectedAssetIn, network: viewModel.selectedNetwork, assetAmount: viewModel.selectedAssetInAmount, assetAmountInUSD: viewModel.selectedAssetInAmountInSecondaryCurrency)
            
            HStack {
                Rectangle()
                    .fill(Color.Layer.grayLighter)
                    .frame(height: 1)
                    .frame(maxWidth: .infinity)
                Text("title-to")
                    .font(.dmSans.medium.size(11))
                    .foregroundStyle(Color.Text.grayLighter)
                    .padding(.horizontal, 14)
                Rectangle()
                    .fill(Color.Layer.grayLighter)
                    .frame(height: 1)
                    .frame(maxWidth: .infinity)
            }
            .frame(height: 16)
            .padding(.vertical, 4)
            ConfirmSwapAssetView(assetItem: viewModel.selectedAssetOut, network: viewModel.selectedNetwork, assetAmount: viewModel.selectedAssetOutAmount, assetAmountInUSD: viewModel.selectedAssetOutAmountInSecondaryCurrency)
            Rectangle()
                .fill(Color.Layer.grayLighter)
                .frame(height: 1)
                .frame(maxWidth: .infinity)
                .padding(.top, 20)
            VStack {
                HStack {
                    Text("title-price")
                        .font(.dmSans.regular.size(13))
                        .foregroundStyle(Color.Text.gray)
                    Spacer()
                    Text(viewModel.price)
                        .font(.dmSans.regular.size(13))
                        .foregroundStyle(Color.Text.main)
                    Spacer().frame(width: 8)
                    Image(.iconRepeat)
                        .resizable()
                        .frame(width: 20, height: 20)
                }
                .padding(.top, 28)
                .padding(.bottom, 16)
                HStack {
                    Text("title-provider")
                        .font(.dmSans.regular.size(13))
                        .foregroundStyle(Color.Text.gray)
                    Spacer()
                    if let url = URL(string: viewModel.provider.iconUrl) {
                        AsyncImage(url: url) { image in
                            image.resizable()
                        } placeholder: {
                            EmptyView()
                        }
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .clipShape(Circle())
                    }
                    Text(viewModel.provider.displayName)
                        .font(.dmSans.regular.size(13))
                        .foregroundStyle(Color.Text.main)
                }
                .padding(.bottom, 16)
                HStack {
                    Text("swap-slippage-title")
                        .font(.dmSans.regular.size(13))
                        .foregroundStyle(Color.Text.gray)
                    Spacer().frame(width: 6)
                    SwiftUI.Button {
                        activeSheet = .slippageTolerance
                    } label: {
                        Image(.iconInfo20)
                    }
                    Spacer()
                    Text(viewModel.slippageTolerance)
                        .font(.dmSans.regular.size(13))
                        .foregroundStyle(Color.Text.main)
                }
                .padding(.bottom, 16)
                HStack {
                    Text("swap-price-impact-title")
                        .font(.dmSans.regular.size(13))
                        .foregroundStyle(viewModel.highPriceImpactWarning != nil ? Color.Helpers.negative : Color.Text.gray)
                    Spacer().frame(width: 6)
                    SwiftUI.Button {
                        activeSheet = .priceImpact
                    } label: {
                        if viewModel.highPriceImpactWarning != nil {
                            Image(.iconInfo20)
                                .renderingMode(.template)
                                .foregroundColor(Color.Helpers.negative)
                        } else {
                            Image(.iconInfo20)
                        }
                    }
                    Spacer()
                    Text(viewModel.priceImpact)
                        .font(.dmSans.regular.size(13))
                        .foregroundStyle(viewModel.highPriceImpactWarning != nil ? Color.Helpers.negative : Color.Text.main)
                }
                .padding(.bottom, 16)
                HStack {
                    Text("swap-confirm-minimum-received-title")
                        .font(.dmSans.regular.size(13))
                        .foregroundStyle(Color.Text.gray)
                    Spacer()
                    Text(viewModel.minimumReceived)
                        .font(.dmSans.regular.size(13))
                        .foregroundStyle(Color.Text.main)
                }
                .padding(.bottom, 16)
                HStack {
                    Text("title-exchange-fee")
                        .font(.dmSans.regular.size(13))
                        .foregroundStyle(Color.Text.gray)
                    Spacer().frame(width: 6)
                    SwiftUI.Button {
                        activeSheet = .exchangeFee
                    } label: {
                        Image(.iconInfo20)
                    }
                    Spacer()
                    Text(viewModel.exchangeFee)
                        .font(.dmSans.regular.size(13))
                        .foregroundStyle(Color.Text.main)
                }
                .padding(.bottom, 16)
                HStack {
                    Text("swap-confirm-pera-fee-title")
                        .font(.dmSans.regular.size(13))
                        .foregroundStyle(Color.Text.gray)
                    Spacer()
                    Text(viewModel.peraFee)
                        .font(.dmSans.regular.size(13))
                        .foregroundStyle(Color.Text.main)
                }
                Spacer().frame(height: 20)
                if let warningMessage = viewModel.highPriceImpactWarning {
                    HStack(alignment: .top, spacing: 4) {
                        Image(.iconInfoRed)
                            .resizable()
                            .frame(width: 20, height: 20)
                        Text(warningMessage)
                            .font(.dmSans.medium.size(13))
                            .foregroundStyle(Color.Helpers.negative)
                            .frame(maxWidth: .infinity)
                    }
                } else {
                    Spacer().frame(height: 45)
                }
            }
            .padding(.bottom, 20)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 24)
            ConfirmSlideButton(state: $viewModel.confirmationState, isSwapDisabled: viewModel.isSwapDisabled) {
                onConfirmTap()
            }
            .disabled(viewModel.isSwapDisabled)
            .padding(.horizontal, 20)
            Spacer()
        }
        .onChange(of: viewModel.confirmationState) { newState in
            switch newState {
            case .idle, .loading: break
            case .success:
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    dismiss()
                    let assetInUnitName = viewModel.selectedAssetIn.asset.naming.displayNames.primaryName
                    let assetOutUnitName = viewModel.selectedAssetOut.asset.naming.displayNames.primaryName
                    onSwapSuccess(String(format: String(localized: "swap-success-toast-text"), assetInUnitName, assetOutUnitName))
                }
            case .error:
                onSwapError("Error!")
            }
        }
        .background(Color.Defaults.bg)
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
        .sheet(item: $activeSheet) { sheet in
            ConfirmSwapInfoSheet(infoSheet: sheet)
        }
    }
}

private struct ConfirmSwapAssetView: View {
    // MARK: - Properties
    var assetItem: AssetItem
    var network: ALGAPI.Network
    var assetAmount: String
    var assetAmountInUSD: String
    
    // MARK: - Body
    var body: some View {
        HStack (alignment: .center) {
            Group {
                if assetItem.asset.isAlgo {
                    Image(.iconAlgoCircle).resizable()
                } else if assetItem.asset.isUSDC(for: network) {
                    Image(.iconUsdcCircle).resizable()
                } else if let url = assetItem.asset.logoURL {
                    AsyncImage(url: url) { image in
                        image.resizable()
                    } placeholder: {
                        Image(.iconSwapEmpty).resizable()
                    }
                } else {
                    Image(.iconSwapEmpty).resizable()
                }
            }
            .frame(width: 40, height: 40)
            Spacer().frame(width: 16)
            VStack (alignment: .leading) {
                Text(assetAmount)
                    .font(.dmSans.medium.size(18))
                    .foregroundStyle(Color.Text.main)
                Text(assetAmountInUSD)
                    .font(.dmSans.regular.size(13))
                    .foregroundStyle(Color.Text.grayLighter)
            }
            Spacer()
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.Layer.grayLightest)
                HStack {
                    Text(assetItem.asset.naming.unitName ?? assetItem.asset.naming.displayNames.primaryName)
                        .font(.dmSans.regular.size(15))
                        .foregroundStyle(Color.Text.main)
                    Spacer().frame(width: 6)
                    Group {
                        if assetItem.asset.verificationTier.isVerified {
                            Image(.iconVerified).resizable()
                        } else if assetItem.asset.verificationTier.isTrusted {
                            Image(.iconTrusted).resizable()
                        } else {
                            EmptyView()
                        }
                    }
                    .frame(width: 16, height: 16)
                }
                .padding(.horizontal, 16)
            }
            .frame(minWidth: 94)
            .frame(height: 48)
            .fixedSize(horizontal: true, vertical: false)
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 90)
    }
}
