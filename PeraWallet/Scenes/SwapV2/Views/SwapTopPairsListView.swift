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

//   SwapTopPairsListView.swift

import SwiftUI
import pera_wallet_core

struct SwapTopPairsListView: View {
    @ObservedObject var viewModel: SwapTopPairViewModel
    var onRowTap: ((SwapTopPair) -> Void)?
    
    var body: some View {
        VStack {
            HStack {
                Text("top5-swaps-title")
                    .font(.dmSans.medium.size(15))
                    .foregroundStyle(Color.Text.main)
                Spacer()
                Text("swap-volume-title")
                    .font(.dmSans.regular.size(15))
                    .foregroundStyle(Color.Text.gray)
            }
            Spacer().frame(height: 8)
            
            if viewModel.isListEmpty {
                HStack {
                    Text("no-swap-activity-placeholder-text")
                        .font(.dmSans.regular.size(15))
                        .foregroundStyle(Color.Text.gray)
                    Spacer()
                }
                .frame(height: 72)
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                VStack(spacing: 5) {
                    ForEach(Array(viewModel.swapTopPairsList.prefix(5).enumerated()), id: \.0) { index, swapTopPair in
                        HStack(alignment: .center) {
                            Text("\(index + 1).")
                                .font(.dmSans.regular.size(19))
                                .foregroundStyle(Color.Text.gray)
                                .frame(width: 26, alignment: .leading)
                            
                            Spacer().frame(width: 8)
                            
                            ZStack(alignment: .topLeading) {
                                AsyncImage(url: URL(string: swapTopPair.assetA.logo ?? .empty)) { phase in
                                    switch phase {
                                    case .empty, .failure:
                                        EmptyView()
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFit()
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                                .frame(width: 24, height: 24)
                                .clipShape(Circle())
                                .offset(x: -12 + 5, y: -12 + 5)
                                
                                AsyncImage(url: URL(string: swapTopPair.assetB.logo ?? .empty)) { phase in
                                    switch phase {
                                    case .empty, .failure:
                                        EmptyView()
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFit()
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                                .frame(width: 24, height: 24)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.Defaults.bg, lineWidth: 1))
                                .offset(x: 12 - 5, y: 12 - 5)
                            }
                            .frame(width: 48, height: 48)
                            .padding(5)
                            
                            Spacer().frame(width: 8)
                            Text(viewModel.rowTitleFor(index: index))
                                .font(.dmSans.medium.size(15))
                                .foregroundStyle(Color.Text.main)
                            Spacer()
                            Text(viewModel.volumeFor(index: index))
                                .font(.dmSans.regular.size(15))
                                .foregroundStyle(Color.Text.gray)
                        }
                        .frame(height: 72)
                        .frame(maxWidth: .infinity)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            onRowTap?(swapTopPair)
                        }
                    }
                }
            }
        }
        .padding(.top, 24)
        .padding(.horizontal, 24)
    }
}
