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

//   SwitchSwapButton.swift

import SwiftUI

struct SwitchSwapButton: View {
    
    // MARK: - Properties
    let onTap: () -> Void
    
    // MARK: - Body
    var body: some View {
        SwiftUI.Button(action: onTap) {
            Image(.iconRepeat)
                .resizable()
                .renderingMode(.template)
                .foregroundColor(Color.Text.main)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
        }
        .background(
            RoundedRectangle(cornerRadius: 40)
                .fill(Color.Defaults.bg)
                .overlay(
                    RoundedRectangle(cornerRadius: 40)
                        .stroke(Color.Helpers.Gray.gray200, lineWidth: 1)
                )
        )
        .frame(width: 40, height: 32)
    }
}
