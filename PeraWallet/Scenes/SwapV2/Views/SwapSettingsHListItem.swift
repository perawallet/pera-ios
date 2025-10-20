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

//   SwapSettingsHListItem.swift

import SwiftUI

struct SwapSettingsHListItem: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        SwiftUI.Button(action: action) {
            Text(title)
                .font(.DMSans.regular.size(13.0))
                .foregroundColor(isSelected ? Color.Helpers.positive : Color.ButtonSecondary.text)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 48)
                        .fill(isSelected ? Color.Helpers.positiveLighter : Color.ButtonSecondary.bg)
                )
        }
        .buttonStyle(.plain)
    }
}
