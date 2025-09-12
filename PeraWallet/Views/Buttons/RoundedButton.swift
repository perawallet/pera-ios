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

//   RoundedButton.swift

import SwiftUI

struct RoundedButton: View {
    
    // MARK: - Properties
    
    let text: LocalizedStringKey
    var backgroundColor: Color = Color.ButtonSecondary.bg
    var textColor: Color = Color.ButtonSecondary.text
    let onTap: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        Text(text)
            .frame(maxWidth: .infinity)
            .frame(height: 52.0)
            .background(backgroundColor)
            .foregroundStyle(textColor)
            .font(.dmSans.medium.size(15.0))
            .cornerRadius(4.0)
            .onTapGesture { onTap() }
    }
}
