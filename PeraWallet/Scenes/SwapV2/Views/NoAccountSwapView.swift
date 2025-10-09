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

//   NoAccountSwapView.swift

import SwiftUI
import pera_wallet_core

enum NoAccountSwapTitleViewAction {
    case info
    case createAccount
}

struct NoAccountSwapView: View {
    
    // MARK: - Properties
    @ObservedObject var viewModel: NoAccountViewModel
    var onAction: ((NoAccountSwapTitleViewAction) -> Void)?
    
    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                HStack {
                    Text("title-swap")
                        .font(.dmSans.medium.size(19.0))
                        .foregroundStyle(Color.Text.main)
                    Spacer().frame(width: 10)
                    SwiftUI.Button {
                        onAction?(.info)
                    } label: {
                        Image("icon-info-gray")
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(Color.Defaults.bg)
                
                Spacer().frame(height: 26)
                
                VStack(alignment: .center) {
                    Spacer().frame(height: 62)
                    Text("account-select-search-empty-title")
                        .font(.dmSans.medium.size(15))
                        .foregroundStyle(Color.Text.main)
                    
                    Spacer().frame(height: 8)
                    
                    Text("swap-empty-accounts-title")
                        .font(.dmSans.regular.size(15))
                        .foregroundStyle(Color.Text.gray)
                    
                    Spacer().frame(height: 32)
                    
                    SwiftUI.Button {
                        onAction?(.createAccount)
                    } label: {
                        HStack(alignment: .center, spacing: 12) {
                            //FIXME: Please replace it with template
                            Image("icon-asset-add")
                                .renderingMode(.template)
                                .foregroundStyle(Color.ButtonPrimary.text)
                                .frame(width: 24, height: 24)
                            
                            Text("create-account-title")
                                .font(.dmSans.medium.size(15))
                                .foregroundStyle(Color.ButtonPrimary.text)
                        }
                    }
                    .frame(height: 52)
                    .frame(maxWidth: .infinity)
                    .background(Color.ButtonPrimary.bg)
                    .cornerRadius(4)
                    .padding(.horizontal, 60)
                    
                    Spacer()
                }
                .frame(height: 264)
                .frame(maxWidth: .infinity)
                .background(Color.Layer.grayLighter)
                .cornerRadius(12)
                .padding(.horizontal, 8)
                
                SwapTopPairsListView(viewModel: SwapTopPairViewModel(swapTopPairsList: viewModel.swapTopPairsList))
                
                Spacer()
            }
        }
    }
}
