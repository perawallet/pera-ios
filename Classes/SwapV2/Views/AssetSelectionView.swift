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

//   AssetSelectionView.swift

import SwiftUI

struct AssetSelectionView: View {
    // MARK: - Properties
    @Binding var isPayingView: Bool
    @Binding var assetItem: AssetItem
    @Binding var balanceText: String?
    
    private let defaultValue = Formatter.decimalFormatter(minimumFractionDigits: 1, maximumFractionDigits: 1).string(for: Decimal(0))!
    
    let onTap: () -> Void
    
    // MARK: - Body
    var body: some View {
        VStack {
            HStack {
                Text(isPayingView ? "title-you-pay" : "title-you-receive")
                    .font(.dmSans.regular.size(13.0))
                    .foregroundStyle(Color.Text.gray)
                Spacer()
                Text(assetItem.balance ?? defaultValue)
                    .font(.dmSans.regular.size(13.0))
                    .foregroundStyle(Color.Text.gray)
            }
            .padding(.top, 40)
            Spacer().frame(height: 12)
            HStack(alignment: .center) {
                VStack(alignment: .leading) {
                    TextField(defaultValue, text: Binding(
                        get: { balanceText ?? defaultValue },
                        set: { balanceText = $0.isEmpty ? defaultValue : $0 }
                    ))
                        .keyboardType(.decimalPad)
                        .font(.dmSans.medium.size(19.0))
                        .foregroundStyle(Color.Text.gray)
                        .disabled(!isPayingView)
                        .frame(maxWidth: 200)
                        .multilineTextAlignment(.leading)
                    Text(defaultValue)
                        .keyboardType(.decimalPad)
                        .font(.dmSans.regular.size(13.0))
                        .foregroundStyle(Color.Text.gray)
                        .frame(maxWidth: 200, alignment: .leading)
                }
                Spacer()
                AssetSwapButton(assetItem: $assetItem, onTap: onTap)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .frame(height: 144)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isPayingView ? Color.Defaults.bg : Color.Layer.grayLighter)
        )
    }
}

extension AssetItem {
    var balance: String? {
        let asset = asset

        let formatter = currencyFormatter
        formatter.formattingContext = currencyFormattingContext ?? .listItem
        formatter.isValueHidden = isAmountHidden
        if asset.isAlgo {
            formatter.currency = AlgoLocalCurrency()
            return formatter.format(asset.decimalAmount)
        } else {
            formatter.currency = nil
            return formatter.format(asset.decimalAmount)?.appending(" \(asset.naming.unitName ?? asset.naming.displayNames.primaryName)")
        }
    }
}
