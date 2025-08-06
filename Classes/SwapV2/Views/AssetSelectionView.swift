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
    @Binding var balanceText: String
    @Binding var asset: Asset
    let onTap: () -> Void
    
    @State private var payingText = ""
    
    // MARK: - Body
    var body: some View {
        VStack {
            HStack {
                Text(isPayingView ? "title-you-pay" : "title-you-receive")
                    .font(.dmSans.regular.size(13.0))
                    .foregroundStyle(Color.Text.gray)
                Spacer()
                Text(balanceText)
                    .font(.dmSans.regular.size(13.0))
                    .foregroundStyle(Color.Text.gray)
            }
            .padding(.top, 40)
            Spacer().frame(height: 12)
            HStack(alignment: .center) {
                VStack(alignment: .leading) {
                    TextField("0.00", text: $payingText)
                        .font(.dmSans.medium.size(19.0))
                        .foregroundStyle(Color.Text.gray)
                        .disabled(!isPayingView)
                        .frame(maxWidth: 200)
                        .multilineTextAlignment(.leading)
                    Text("$0.0")
                        .font(.dmSans.regular.size(13.0))
                        .foregroundStyle(Color.Text.gray)
                        .frame(maxWidth: 200, alignment: .leading)
                }
                Spacer()
                AssetSwapButton(asset: $asset, onTap: onTap)
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
