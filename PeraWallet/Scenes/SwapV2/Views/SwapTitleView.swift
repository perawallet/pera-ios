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

//   SwapTitleView.swift

import SwiftUI
import pera_wallet_core

enum SwapTitleViewAction {
    case info
    case accountSelection
}

struct SwapTitleView: View {
    
    // MARK: - Properties
    @Binding var selectedAccount: Account
    let onTap: (SwapTitleViewAction) -> Void
    
    // MARK: - Body
    var body: some View {
        HStack {
            HStack {
                Text("title-swap")
                    .font(.dmSans.medium.size(19.0))
                    .foregroundStyle(Color.Text.main)
                Spacer().frame(width: 10)
                SwiftUI.Button {
                    onTap(.info)
                } label: {
                    Image("icon-info-gray")
                        .resizable()
                        .frame(width: 24, height: 24)
                }
            }
            Spacer()
            AccountSelectionButton(selectedAccount: $selectedAccount) { onTap(.accountSelection) }
        }
        .padding(.horizontal, 24)
        .frame(height: 60)
        .background(Color.Defaults.bg)

    }
}
