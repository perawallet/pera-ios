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

//   JointAccountInviteConfirmationOverlayAccountRow.swift

import SwiftUI

struct JointAccountInviteConfirmationOverlayAccountRow: View {
    
    // MARK: - Properties
    
    let image: ImageType
    let title: String
    let subtitle: String?
    let onCopyAction: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        CoreAccountRow(image: image, title: title, subtitle: subtitle) {
            Image(.Icons.copy)
                .resizable()
                .frame(width: 24.0, height: 24.0)
                .foregroundStyle(Color.Text.gray)
                .onTapGesture(perform: onCopyAction)
        }
    }
}
