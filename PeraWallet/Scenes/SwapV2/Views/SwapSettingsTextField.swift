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

//   SwapSettingsTextField.swift

import SwiftUI

struct SwapSettingsTextField: View {
    
    let textFieldType: TextFieldType
    @Binding var text: String
    
    var body: some View {
        Text(textFieldType.title)
            .font(.DMSans.regular.size(13))
            .foregroundStyle(Color.Text.gray)
            .frame(maxWidth: .infinity, alignment: .leading)
        Spacer().frame(height: 8)
        TextField(textFieldType.placeholder, text: $text)
            .frame(height: 52)
            .foregroundStyle(Color.Text.grayLighter)
            .keyboardType(.numberPad)
        Rectangle()
            .fill(Color.Layer.grayLighter)
            .frame(height: 1)
            .frame(maxWidth: .infinity)
    }
}
