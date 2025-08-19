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

//   SettingsListCell.swift

import SwiftUI

struct SettingsListCell: View {
    
    // MARK: - Properties
    
    let icon: ImageResource
    let title: String
    
    // MARK: - Body
    
    var body: some View {
        HStack {
            Image(icon)
                .resizable()
                .foregroundStyle(Color.Text.main)
                .frame(width: 24.0, height: 24.0)
                .padding(.trailing, 16.0)
            VStack(alignment: .leading, spacing: 8.0) {
                Text(title)
                    .font(.dmSans.regular.size(15.0))
                    .foregroundStyle(Color.Text.main)
            }
            Spacer()
            Image(.iconListArrow)
        }
        .padding(.horizontal, 24.0)
        .frame(height: 64.0)
    }
}

struct SettingsListCell_Preview: PreviewProvider {
    
    static var previews: some View {
        SettingsListCell(icon: .iconWallet, title: "Hello, World!")
            .previewLayout(.fixed(width: 400.0, height: 64.0))
    }
}
