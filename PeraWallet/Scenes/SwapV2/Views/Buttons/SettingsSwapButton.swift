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

//   SettingsSwapButton.swift

import SwiftUI

enum SettingsSwapButtonAction {
    case settings
    case max
}

struct SettingsSwapButton: View {

    // MARK: - Properties
    let onTap: (SettingsSwapButtonAction) -> Void

    // MARK: - Body
    var body: some View {
        HStack(spacing: 0) {
            SwiftUI.Button {
                onTap(.settings)
            } label: {
                Image(.iconAssetManage)
                    .resizable()
                    .frame(width: 16, height: 16)
                    .clipShape(Circle())
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
            }
            Rectangle()
                .fill(Color.Layer.grayLighter)
                .frame(width: 1)
                .padding(.vertical, 8)
            SwiftUI.Button {
                onTap(.max)
            } label: {
                Text("send-transaction-max-button-title")
                    .font(.dmSans.bold.size(11.0))
                    .foregroundStyle(Color.Helpers.positive)
                    .frame(width: 25, alignment: .leading)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 40)
                .fill(Color.Defaults.bg)
                .overlay(
                    RoundedRectangle(cornerRadius: 40)
                        .stroke(Color.Helpers.Gray.gray200, lineWidth: 1)
                )
        )
        .frame(width: 90, height: 32)
    }
}
