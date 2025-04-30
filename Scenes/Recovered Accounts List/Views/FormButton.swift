// Copyright 2025 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   FormButton.swift

import SwiftUI

struct FormButton: View {
    
    enum Style: Equatable {
        case primary
        case secondary
        case disabled
    }
    
    // MARK: - Properties
    
    var text: LocalizedStringKey
    var style: Style
    var action: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            SwiftUI.Button(
                action: action,
                label: {
                    Text(text)
                        .font(.dmSans.medium.size(15.0))
                        .tint(style.textColor)
                        .padding()
                }
            )
            .frame(height: 52.0)
            .frame(maxWidth: .infinity)
            .background(style.backgroundColor)
            .cornerRadius(4.0)
            .disabled(style.isDisabled)
            .animation(.easeInOut(duration: 0.2), value: style)
        }
    }
}

private extension FormButton.Style {
    
    var backgroundColor: Color {
        switch self {
        case .primary:
            return Color(uiColor: Colors.Button.Primary.background.uiColor) // FIXME: Replace Color with Color from assets catalogue.
        case .secondary:
            return Color(uiColor: Colors.Button.Secondary.background.uiColor) // FIXME: Replace Color with Color from assets catalogue.
        case .disabled:
            return Color(uiColor: Colors.Button.Primary.disabledBackground.uiColor) // FIXME: Replace Color with Color from assets catalogue.
        }
    }
    
    var textColor: Color {
        switch self {
        case .primary:
            return Color(uiColor: Colors.Button.Primary.text.uiColor) // FIXME: Replace Color with Color from assets catalogue.
        case .secondary:
            return Color(uiColor: Colors.Button.Secondary.text.uiColor) // FIXME: Replace Color with Color from assets catalogue.
        case .disabled:
            return Color(uiColor: Colors.Button.Primary.disabledText.uiColor) // FIXME: Replace Color with Color from assets catalogue.
        }
    }
    
    var isDisabled: Bool {
        switch self {
        case .primary, .secondary:
            return false
        case .disabled:
            return true
        }
    }
}

#Preview {
    FormButton(text: "I'm Button", style: .primary) {}
}
