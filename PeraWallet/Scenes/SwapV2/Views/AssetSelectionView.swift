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

//   AssetSelectionView.swift

import SwiftUI
import pera_wallet_core

enum AssetSelectionType {
    case pay
    case receive
    
    var title: LocalizedStringKey {
        switch self {
        case .pay:
            return "title-you-pay"
        case .receive:
            return "title-you-receive"
        }
    }
    
    var textEditorDisabled: Bool {
        switch self {
        case .pay:
            return false
        case .receive:
            return true
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .pay:
            return Color.Defaults.bg
        case .receive:
            return Color.Layer.grayLighter
        }
    }
}

struct AssetSelectionView: View {
    // MARK: - Properties
    var type: AssetSelectionType
    @Binding var assetItem: AssetItem
    @Binding var amountText: String
    @Binding var amountTextInUSD: String
    @FocusState private var isPayingFocused: Bool
    @Binding var isLoading: Bool
    
    let onAssetSelectionTap: () -> Void
    
    // MARK: - Body
    var body: some View {
        VStack {
            HStack {
                Text(type.title)
                    .font(.dmSans.regular.size(13.0))
                    .foregroundStyle(Color.Text.gray)
                Spacer()
                Text(assetItem.balance ?? SwapSharedViewModel.defaultAmountValue)
                    .font(.dmSans.regular.size(13.0))
                    .foregroundStyle(Color.Text.gray)
            }
            .padding(.top, 40)
            Spacer().frame(height: 12)
            HStack(alignment: .center) {
                VStack(alignment: .leading) {
                    if isLoading {
                        ShimmerSUIView()
                            .frame(width: 100, height: 19, alignment: .leading)
                            .cornerRadius(3)
                    } else {
                        TextField(SwapSharedViewModel.defaultAmountValue, text: Binding(
                            get: { amountText },
                            set: { amountText = $0.isEmpty ? SwapSharedViewModel.defaultAmountValue : $0 }
                        ))
                        .keyboardType(.decimalPad)
                        .font(.dmSans.medium.size(19.0))
                        .foregroundStyle(Color.Text.gray)
                        .disabled(type.textEditorDisabled)
                        .frame(maxWidth: 200)
                        .multilineTextAlignment(.leading)
                        .focused($isPayingFocused)
                        .onChange(of: isPayingFocused) { focused in
                            if focused && (amountText == "0" || amountText == "0.0" || amountText == "0,0") {
                                amountText = ""
                            }
                        }
                    }

                    if isLoading {
                        ShimmerSUIView()
                            .frame(width: 80, height: 13, alignment: .leading)
                            .cornerRadius(2)
                    } else {
                        Text(amountTextInUSD)
                            .keyboardType(.decimalPad)
                            .font(.dmSans.regular.size(13.0))
                            .foregroundStyle(Color.Text.gray)
                            .frame(maxWidth: 200, alignment: .leading)
                    }
                }
                Spacer()
                AssetSwapButton(assetItem: $assetItem, onTap: onAssetSelectionTap)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .frame(height: 144)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(type.backgroundColor)
        )
    }
}
