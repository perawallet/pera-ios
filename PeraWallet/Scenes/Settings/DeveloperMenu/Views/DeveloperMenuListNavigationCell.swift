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

//   DeveloperMenuListNavigationCell.swift

import SwiftUI
import pera_wallet_core

struct DeveloperMenuListNavigationCell: View {
    
    // MARK: - Properties
    
    let item: SecretDeveloperSettings
    
    // MARK: - Body

    var body: some View {
        HStack {
            if let icon = item.image {
                Image(uiImage: icon)
                    .resizable()
                    .frame(width: 24, height: 24)
                    .padding(.trailing, 10)
            }

            Text(item.name)
                .font(.DMSans.regular.size(15))
                .foregroundStyle(Color.Text.main)
            Spacer()
        }
        .padding(.horizontal, 12)
        .frame(height: 50)
    }
}
