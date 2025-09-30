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

//   SwapHistoryListView.swift

import SwiftUI
import pera_wallet_core

struct SwapHistoryListView: View {
    @ObservedObject var viewModel: SwapHistoryViewModel
    var onRowTap: ((SwapHistory) -> Void)?
    
    var body: some View {
        VStack {
            HStack {
                Text("swap-history-title")
                    .font(.dmSans.medium.size(15))
                    .foregroundStyle(Color.Text.main)
                Spacer()
                SwiftUI.Button {
                    print("---see all")
                } label: {
                    Text("see-all-title")
                        .font(.dmSans.medium.size(15))
                        .foregroundStyle(Color.Helpers.positive)
                }
            }
            Spacer().frame(height: 8)
            if viewModel.isListEmpty {
                HStack {
                    Text("no-swap-history-placeholder-text")
                        .font(.dmSans.regular.size(15))
                        .foregroundStyle(Color.Text.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Spacer().frame(height: 5)
            }
        }
        .frame(height: 72)
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .padding(.bottom, 24)
    }
}
