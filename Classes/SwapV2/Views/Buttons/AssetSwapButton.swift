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
    @Binding var icon: Image
    @Binding var text: String
    let onTap: () -> Void

    // MARK: - Body
    var body: some View {
        SwiftUI.Button(action: onTap) {
            HStack(spacing: 0) {
                icon
                    .resizable()
                    .frame(width: 24, height: 24)
                Spacer().frame(width: 6)
                Text(text.uppercased())
                    .font(.dmSans.regular.size(15.0))
                    .foregroundStyle(Color.Text.main)
                    .frame(width: 40, alignment: .leading)
                Spacer().frame(width: 8)
                Image("icon-arrow-24")
                    .resizable()
                    .frame(width: 24, height: 24)
            }
            .padding(12)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.Layer.grayLightest)
        )
        .frame(width: 126, height: 48)
    }
}
