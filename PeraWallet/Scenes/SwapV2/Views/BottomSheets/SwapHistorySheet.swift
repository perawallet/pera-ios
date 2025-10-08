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

//   SwapHistorySheet.swift

import SwiftUI
import pera_wallet_core

struct SwapHistorySheet: View {
    @SwiftUI.Environment(\.dismiss) private var dismiss
    
    @ObservedObject private(set) var viewModel: SwapHistoryViewModel
    var onRowTap: ((SwapHistory) -> Void)?
    
    var body: some View {
        SwiftUI.ScrollView {
            VStack() {
                ZStack {
                    HStack {
                        SwiftUI.Button(action: {
                            dismiss()
                        }) {
                            Image("icon-close")
                                .frame(width: 24, height: 24)
                        }
                        Spacer()
                            .font(.dmSans.medium.size(15))
                            .foregroundStyle(Color.Helpers.positive)
                    }
                    .frame(maxHeight: .infinity, alignment: .center)
                    Text("swap-history-title")
                        .font(.dmSans.medium.size(15))
                        .foregroundStyle(Color.Text.main)
                        .frame(maxHeight: .infinity, alignment: .center)
                }
                .frame(height: 44)
                .padding(24)
                
                VStack {
                    if let swapHistoryList = viewModel.uniqueSwapHistoryList {
                        ForEach(swapHistoryList, id: \.historyId) { swapHistoryItem in
                            VStack(spacing: 0) {
                                HStack(alignment: .center, spacing: 0) {
                                    SwapLogosView(assetIn: swapHistoryItem.assetIn, assetOut: swapHistoryItem.assetOut)
                                        .padding(.trailing, 8)
                                    
                                    VStack(alignment: .leading) {
                                        Text(swapHistoryItem.swappedText)
                                            .font(.dmSans.regular.size(15))
                                            .foregroundStyle(Color.Text.main)
                                            .padding(.bottom, 4)
                                        HStack {
                                            Text(swapHistoryItem.resultText)
                                                .font(.dmSans.bold.size(15))
                                                .foregroundStyle(Color.Text.main)
                                                .padding(.trailing, 5)
                                            Text("\u{30FB}")
                                                .font(.dmSans.regular.size(15))
                                                .foregroundStyle(Color.Text.gray)
                                                .padding(.trailing, 5)
                                            Text(swapHistoryItem.dateText)
                                                .font(.dmSans.regular.size(15))
                                                .foregroundStyle(Color.Text.gray)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                    }
                                    
                                    Spacer()
                                    
                                    Image("icon-external-link")
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                }
                                .padding(.vertical, 5)
                                
                                Divider()
                                    .background(Color.Layer.grayLighter)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 24)
                            .onTapGesture {
                                onRowTap?(swapHistoryItem)
                                dismiss()
                            }
                        }
                    } else {
                        EmptyView()
                    }
                }
                
                Spacer()
            }
            .background(Color.Defaults.bg)
            .presentationDetents([.large])
            .presentationDragIndicator(.hidden)
        }
        .background(Color.Defaults.bg)
        .ignoresSafeArea(edges: .top)
    }
    
}

