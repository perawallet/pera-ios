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

//   RoundedMenuRow.swift

import SwiftUI

struct RoundedMenuRow: View {
    
    // MARK: - Properties
    
    let icon: ImageResource
    let title: LocalizedStringKey
    let description: LocalizedStringKey
    let isNewBadgeVisible: Bool
    
    // MARK: - Body
    
    var body: some View {
        HStack(alignment: .top) {
            Image(icon)
                .resizable()
                .frame(width: 24.0, height: 24.0)
                .foregroundStyle(Color.Text.main)
                .padding(.trailing, 12.0)
            VStack(alignment: .leading) {
                HStack {
                    Text(title)
                        .font(.DMSans.medium.size(19.0))
                        .foregroundStyle(Color.Text.main)
                    if isNewBadgeVisible {
                        Text("common-badge-new")
                            .font(.DMSans.medium.size(11.0))
                            .foregroundStyle(Color.Wallet.wallet4Icon)
                            .padding(.vertical, 4.0)
                            .padding(.horizontal, 8.0)
                            .background(Color.Wallet.wallet4)
                            .cornerRadius(8.0)
                    }
                }
                .frame(height: 28.0)
                Text(description)
                    .font(.DMSans.regular.size(13.0))
                    .foregroundStyle(Color.Text.gray)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16.0)
        .background(Color.Layer.grayLighter)
        .cornerRadius(16.0)
        .defaultPeraRowStyle()
    }
}
