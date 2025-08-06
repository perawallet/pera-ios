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

//   AssetSwapButton.swift

import SwiftUI

struct AssetSwapButton: View {

    // MARK: - Properties
    @Binding var asset: Asset
    private let iconSize: CGFloat = 24
    
    let onTap: () -> Void

    // MARK: - Body
    var body: some View {
        SwiftUI.Button(action: onTap) {
            HStack(spacing: 0) {
                Group {
                    if asset.isAlgo {
                        Image("icon-algo-circle").resizable()
                    } else if let url = asset.logoURL {
                        AsyncImage(url: url) { image in
                            image.resizable()
                        } placeholder: {
                            Image("icon-swap-empty").resizable()
                        }
                    } else {
                        Image("icon-swap-empty").resizable()
                    }
                }
                .frame(width: iconSize, height: iconSize)
                Spacer().frame(width: 6)
                Text(asset.naming.displayNames.primaryName)
                    .font(.dmSans.regular.size(15.0))
                    .foregroundStyle(Color.Text.main)
                    .lineLimit(1)
                Spacer().frame(width: 8)
                Image("icon-arrow-24")
                    .resizable()
                    .frame(width: 24, height: 24)
            }
            .padding(12)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(height: 48)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.Layer.grayLightest)
        )
        .frame(maxWidth: 250)
        .fixedSize(horizontal: true, vertical: false)
    }
}
