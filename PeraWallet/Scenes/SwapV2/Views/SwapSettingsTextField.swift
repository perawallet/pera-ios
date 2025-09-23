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
    
    let title: LocalizedStringKey
    let placeholder: LocalizedStringKey
    
    @Binding var text: String
    
    var body: some View {
        Text(title)
            .font(.dmSans.regular.size(13))
            .foregroundStyle(Color.Text.gray)
            .frame(maxWidth: .infinity, alignment: .leading)
        Spacer().frame(height: 8)
        TextField(placeholder, text: $text)
            .frame(height: 52)
            .foregroundStyle(Color.Text.grayLighter)
            .keyboardType(.numberPad)
            .onChange(of: text) { new in
                let digits = new.filter { $0.isNumber }
                if digits != new { text = digits }
                if let n = Int(digits) {
                    let clamped = min(max(n, 1), 100)
                    text = String(clamped)
                } else {
                    text = ""
                }
            }
        Rectangle()
            .fill(Color.Layer.grayLighter)
            .frame(height: 1)
            .frame(maxWidth: .infinity)
    }
}
