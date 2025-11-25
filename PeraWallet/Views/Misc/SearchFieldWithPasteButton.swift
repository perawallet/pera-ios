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

//   SearchFieldWithPasteButton.swift

import SwiftUI

struct SearchFieldWithPasteButton: View {
    
    // MARK: - Properties
    
    let placeholder: LocalizedStringKey
    @Binding var text: String
    var onPasteButtonTap: () -> Void
    
    @FocusState private var isFocused: Bool
    
    // MARK: - Body
    
    var body: some View {
        HStack {
            Image(.Icons.search)
                .resizable()
                .foregroundStyle(Color.Text.grayLighter)
                .frame(width: 24.0, height: 24.0)
                .padding(.vertical, 8.0)
                .padding(.leading, 12.0)
            TextField(placeholder, text: $text)
                .focused($isFocused)
                .font(.DMSans.regular.size(13.0))
                .foregroundStyle(Color.Text.main)
                .padding(.leading, 8.0)
            if !isFocused {
                SwiftUI.Button(action: onPasteButtonTap) {
                    Image(.Icons.paste)
                        .resizable()
                        .foregroundStyle(Color.Text.gray)
                        .frame(width: 24.0, height: 24.0)
                        .padding(.trailing, 12.0)
                }
            }
        }
        .background(Color.Layer.grayLighter)
        .cornerRadius(4.0)
    }
}
