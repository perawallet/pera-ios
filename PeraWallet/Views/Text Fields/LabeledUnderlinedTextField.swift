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

//   LabeledUnderlinedTextField.swift

import SwiftUI

struct LabeledUnderlinedTextField: View {
    
    // MARK: - Properties
    
    let title: LocalizedStringKey
    let placeholder: LocalizedStringKey
    @Binding var text: String
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading) {
            FormTitleLabel(title: title)
                .padding(.bottom, 2.0)
            TextField(placeholder, text: $text)
                .font(.DMSans.regular.size(15.0))
                .foregroundStyle(Color.Text.gray)
                .padding(.bottom, 4.0)
            Rectangle()
                .frame(height: 1.0)
                .foregroundStyle(Color.Shadows.TextField.defaultBg)
        }
    }
}
