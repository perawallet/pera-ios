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

enum SwapInfoSheet: Identifiable {
    case slippageTolerance
    case priceImpact

    var id: String {
        switch self {
        case .slippageTolerance: return "slippageTolerance"
        case .priceImpact: return "priceImpact"
        }
    }
    
    var title: LocalizedStringKey {
        switch self {
        case .slippageTolerance: return "swap-slippage-title"
        case .priceImpact: return "swap-price-impact-title"
        }
    }
    
    var text: LocalizedStringKey {
        switch self {
        case .slippageTolerance: return "swap-slippage-tolerance-info-body"
        case .priceImpact: return "swap-price-impact-info-body"
        }
    }
    
    var height: CGFloat {
        switch self {
        case .slippageTolerance: return 320
        case .priceImpact: return 250
        }
    }
}

struct ConfirmSwapView: View {
    @SwiftUI.Environment(\.dismiss) private var dismiss
    
    var viewModel: SwapConfirmViewModel
    
    @State private var activeSheet: SwapInfoSheet?

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                HStack {
                    SwiftUI.Button(action: {
                        dismiss()
                    }) {
                        Image("icon-close")
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
            .padding(.bottom, 30)
            ConfirmSwapAssetView(assetItem: viewModel.selectedAssetIn, assetAmount: viewModel.selectedAssetInAmount)

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
            ConfirmSwapAssetView(assetItem: viewModel.selectedAssetOut, assetAmount: viewModel.selectedAssetOutAmount)
            Rectangle()
                .fill(Color.Layer.grayLighter)
                .frame(height: 1)
                .frame(maxWidth: .infinity)
                .padding(.top, 40)
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
                    Image("icon-repeat")
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
                    viewModel.provider.icon
                        .resizable()
                        .frame(width: 20, height: 20)
                    Text(viewModel.provider.name)
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
                        Image("icon-info-20")
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
                        .foregroundStyle(Color.Text.gray)
                    Spacer().frame(width: 6)
                    SwiftUI.Button {
                        activeSheet = .priceImpact
                    } label: {
                        Image("icon-info-20")
                    }
                    Spacer()
                    Text(viewModel.priceImpact)
                        .font(.dmSans.regular.size(13))
                        .foregroundStyle(Color.Text.main)
                }
                .padding(.bottom, 16)
                HStack {
                   Text("swap-confirm-minimum-received-title")
                        .font(.dmSans.regular.size(13))
                        .foregroundStyle(Color.Text.gray)
                    Spacer()
                    Text("1,365,310.296595 AKTA")
                        .font(.dmSans.regular.size(13))
                        .foregroundStyle(Color.Text.main)
                }
                .padding(.bottom, 16)
                HStack {
                   Text("title-exchange-fee")
                        .font(.dmSans.regular.size(13))
                        .foregroundStyle(Color.Text.gray)
                    Spacer()
                    Text("0.219412")
                        .font(.dmSans.regular.size(13))
                        .foregroundStyle(Color.Text.main)
                }
                .padding(.bottom, 16)
                HStack {
                   Text("swap-confirm-pera-fee-title")
                        .font(.dmSans.regular.size(13))
                        .foregroundStyle(Color.Text.gray)
                    Spacer()
                    Text("0.149382")
                        .font(.dmSans.regular.size(13))
                        .foregroundStyle(Color.Text.main)
                }
                .padding(.bottom, 32)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 24)
            ConfirmSlideButton() {
                print("confirmed!")
            }
                .padding(.horizontal, 24)
            Spacer()
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
    var assetAmount: String
    
    // MARK: - Body
    var body: some View {
        HStack (alignment: .center) {
            Group {
                if assetItem.asset.isAlgo {
                    Image("icon-algo-circle").resizable()
                } else if let url = assetItem.asset.logoURL {
                    AsyncImage(url: url) { image in
                        image.resizable()
                    } placeholder: {
                        Image("icon-swap-empty").resizable()
                    }
                } else {
                    Image("icon-swap-empty").resizable()
                }
            }
            .frame(width: 40, height: 40)
            Spacer().frame(width: 16)
            VStack (alignment: .leading) {
                Text(assetAmount)
                    .font(.dmSans.medium.size(18))
                    .foregroundStyle(Color.Text.main)
                Text("-")
                    .font(.dmSans.regular.size(13))
                    .foregroundStyle(Color.Text.grayLighter)
            }
            Spacer()
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.Layer.grayLightest)
                HStack {
                    Text(assetItem.asset.naming.displayNames.primaryName)
                        .font(.dmSans.regular.size(15))
                        .foregroundStyle(Color.Text.main)
                    Spacer().frame(width: 6)
                    Group {
                        if assetItem.asset.verificationTier.isVerified {
                            Image("icon-verified").resizable()
                        } else if assetItem.asset.verificationTier.isTrusted {
                            Image("icon-trusted").resizable()
                        } else {
                            EmptyView()
                        }
                    }
                    .frame(width: 16, height: 16)
                }
                .padding(.horizontal, 16)
            }
            .frame(width: 94, height: 48)
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 105)
    }
}
