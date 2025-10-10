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

//   SwapLogosView.swift

import SwiftUI
import pera_wallet_core

struct SwapLogosView: View {
    
    // MARK: - Properties
    let assetIn: SwapAsset
    let assetOut: SwapAsset
    
    // MARK: - Body
    var body: some View {
        ZStack(alignment: .topLeading) {
            AsyncImage(url: URL(string: assetIn.logo ?? .empty)) { phase in
                switch phase {
                case .empty, .failure:
                    Image(.iconSwapEmpty)
                        .resizable()
                        .scaledToFit()
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                @unknown default:
                    Image(.iconSwapEmpty)
                        .resizable()
                        .scaledToFit()
                }
            }
            .frame(width: 24, height: 24)
            .clipShape(Circle())
            .offset(x: -12 + 5, y: -12 + 5)
            
            AsyncImage(url: URL(string: assetOut.logo ?? .empty)) { phase in
                switch phase {
                case .empty, .failure:
                    Image(.iconSwapEmpty)
                        .resizable()
                        .scaledToFit()
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                @unknown default:
                    Image(.iconSwapEmpty)
                        .resizable()
                        .scaledToFit()
                }
            }
            .frame(width: 24, height: 24)
            .background(Color.Defaults.bg)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.Defaults.bg, lineWidth: 1))
            .offset(x: 12 - 5, y: 12 - 5)
        }
        .frame(width: 48, height: 48)
        .padding(5)
    }
}
