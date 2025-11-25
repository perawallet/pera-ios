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

//   SwapButton.swift

import SwiftUI

struct SwapButton: View {
    
    // MARK: - Properties
    let onTap: () -> Void
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.Layer.grayLighter)
                .frame(height: 1)
                .frame(maxWidth: .infinity)
            Spacer().frame(height: 8)
            SwiftUI.Button(action: onTap) {
                Text("title-swap")
                    .font(.DMSans.medium.size(15))
                    .foregroundStyle(Color.ButtonPrimary.text)
                    .frame(maxWidth: .infinity, minHeight: 52)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.ButtonPrimary.bg)
                    )
            }
            .padding(.horizontal, 8)
            Spacer().frame(height: 8)
            Rectangle()
                .fill(Color.Layer.grayLighter)
                .frame(height: 1)
                .frame(maxWidth: .infinity)
        }
        .frame(height: 68)
        .frame(maxWidth: .infinity)
    }
}
