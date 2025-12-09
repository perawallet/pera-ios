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

//   DeveloperMenuListToggleCell.swift

import SwiftUI

struct DeveloperMenuListToggleCell: View {
    
    // MARK: - Properties
    
    let item: SecretDeveloperSettings
    @Binding var isOn: Bool

    // MARK: - Body
    
    var body: some View {
        SwiftUI.Toggle(isOn: $isOn) {
            HStack {
                if let image = item.image {
                    Image(uiImage: image)
                        .resizable()
                        .frame(width: 24, height: 24)
                        .padding(.trailing, 10)
                }
                Text(item.name)
                    .font(.DMSans.regular.size(15))
                    .foregroundStyle(Color.Text.main)
            }
            .padding(.horizontal, 12)
            .frame(height: 50)
        }
    }
}
