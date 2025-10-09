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
    @ObservedObject private(set) var viewModel: SwapHistoryViewModel
    var onRowTap: ((SwapHistory) -> Void)?
    var onSeeAllTap: (() -> Void)?
    
    var body: some View {
        VStack {
            HStack {
                Text("swap-history-title")
                    .font(.dmSans.medium.size(15))
                    .foregroundStyle(Color.Text.main)
                Spacer()
                if viewModel.shouldShowSeeAllButton {
                    SwiftUI.Button {
                        onSeeAllTap?()
                    } label: {
                        Text("see-all-title")
                            .font(.dmSans.medium.size(15))
                            .foregroundStyle(Color.Helpers.positive)
                    }
                }
            }
            .padding(.horizontal, 24)
            Spacer().frame(height: 8)
            if let swapHistoryList = viewModel.uniqueSwapHistoryList {
                if swapHistoryList.isEmpty {
                    HStack {
                        Text("no-swap-history-placeholder-text")
                            .font(.dmSans.regular.size(13))
                            .foregroundStyle(Color.Text.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            Spacer().frame(width: 24)
                            ForEach(swapHistoryList, id: \.historyId) { item in
                                SwapHistoryListItem(item: item)
                                    .onTapGesture {
                                        onRowTap?(item)
                                    }
                            }
                        }
                    }
                }
            } else {
                HStack {
                    Image(.iconInfo18)
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(Color.Helpers.negative)
                        .frame(width: 16, height: 16)
                    Spacer().frame(width: 8)
                    Text("swap-history-error-message")
                        .font(.dmSans.regular.size(13))
                        .foregroundStyle(Color.Helpers.negative)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
            }
        }
        .padding(.top, 24)
        .padding(.bottom, 24)
    }
}
