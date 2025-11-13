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

//   RoundedTextField.swift

import SwiftUI

struct RoundedTextField: View {
    
    // MARK: - Properties
    
    var icon: ImageResource? = nil
    var placeholder: LocalizedStringKey? = nil
    @Binding var text: String
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: 0.0) {
            if let icon {
                Image(icon)
                    .resizable()
                    .foregroundStyle(Color.Text.grayLighter)
                    .frame(width: 24.0, height: 24.0)
                    .padding(.vertical, 8.0)
                    .padding(.trailing, 8.0)
            }
            PeraTextField(placeholder: placeholder, text: $text)
                .font(.DMSans.regular.size(13.0))
                .foregroundStyle(Color.Text.main)
        }
        .frame(height: 40.0)
        .padding(.horizontal, 12.0)
        .background(Color.Layer.grayLighter)
        .cornerRadius(4.0)
    }
}
