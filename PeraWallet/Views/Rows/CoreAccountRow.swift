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

//   CoreAccountRow.swift

import SwiftUI

struct CoreAccountRow<TrailingView: View>: View {
    
    // MARK: - Properties
    
    let image: ImageType
    let title: String
    let subtitle: String?
    
    @ViewBuilder let trailingView: () -> TrailingView
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: 0.0) {
            RoundedIconView(image: image, size: 40.0, padding: 8.0)
                .padding(.vertical, 18.0)
            VStack(alignment: .leading) {
                Text(title)
                    .font(.DMSans.regular.size(15.0))
                    .foregroundStyle(Color.Text.main)
                if let subtitle {
                    Text(subtitle)
                        .font(.DMSans.regular.size(13.0))
                        .foregroundStyle(Color.Text.grayLighter)
                }
            }
            .padding(.leading, 16.0)
            Spacer()
            trailingView()
        }
        .padding(.horizontal, 24.0)
        .defaultPeraRowStyle()
    }
}
