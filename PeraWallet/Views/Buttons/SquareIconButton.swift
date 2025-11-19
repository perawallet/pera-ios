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

//   SquareIconButton.swift

import SwiftUI

struct SquareIconButton: View {
    
    // MARK: - Properties
    
    let icon: ImageResource
    let isEnabled: Bool
    var onTap: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        Image(icon)
            .foregroundColor(isEnabled ? .ButtonSquare.icon : .Text.grayLighter)
            .padding(8.0)
            .background(isEnabled ? Color.ButtonSquare.bg : Color.ButtonPrimary.newDisabledBg)
            .cornerRadius(8.0)
            .onTapGesture { onTapAction() }
    }
    
    // MARK: - Actions
    
    private func onTapAction() {
        guard isEnabled else { return }
        onTap()
    }
}
