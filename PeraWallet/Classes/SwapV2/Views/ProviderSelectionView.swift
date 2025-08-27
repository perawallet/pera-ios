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

//   ProviderSelectionView.swift

import SwiftUI
import pera_wallet_core

struct ProviderSelectionView: View {
    // MARK: - Properties
    var viewModel: ProviderSelectionViewModel
    
    let onTap: () -> Void
    
    // MARK: - Body
    var body: some View {
        VStack (alignment: .leading) {
            viewModel.title
                .font(.dmSans.regular.size(13.0))
                .foregroundStyle(Color.Text.gray)
            SwiftUI.Button(action: onTap) {
                HStack (alignment: .center) {
                    HStack  (alignment: .center) {
                        Group {
                            if let url = URL(string: viewModel.iconUrl) {
                                URLImageSUIView(url: url)
                                    .frame(width: 16, height: 16)
                                    .scaledToFit()
                            } else {
                                EmptyView()
                            }
                        }
                        Spacer().frame(width: 4)
                        Text(viewModel.displayName)
                            .font(.dmSans.regular.size(15))
                            .foregroundStyle(Color.Text.main)
                    }
                    Spacer()
                    Text(viewModel.rate)
                        .font(.dmSans.regular.size(15))
                        .foregroundStyle(Color.Text.main)
                    Spacer().frame(width: 3)
                    Image("icon-arrow-24")
                        .resizable()
                        .frame(width: 20, height: 20)
                }
            }
            .padding(.top, 8)
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity)
    }
}
