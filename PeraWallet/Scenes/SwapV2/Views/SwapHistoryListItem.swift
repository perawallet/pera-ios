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

//   SwapHistoryListItem.swift

import SwiftUI
import pera_wallet_core

struct SwapHistoryListItem: View {
    let item: SwapHistory
    
    var body: some View {
        VStack {
            HStack {
                SwapLogosView(assetIn: item.assetIn, assetOut: item.assetOut)

                Text(item.title)
                    .font(.dmSans.medium.size(15))
                    .foregroundStyle(Color.Text.main)
            }
            .padding(.vertical, 4)
            .padding(.horizontal, 12)
            .background(Color.Defaults.bg)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.Shadows.Cards.shadow2, lineWidth: 1)
            )
            .shadow(color: Color.Shadows.Cards.shadow1, radius: 4, x: 0, y: 2)
        }
        .padding(.vertical, 5)
    }
}
