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

//   InboxButton.swift

import SwiftUI

struct InboxButton: View {
    
    // MARK: - Properties
    
    var text: String
    var onTap: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: 6.0) {
            Image(.Icons.inbox)
                .resizable()
                .frame(width: 16.0, height: 16.0)
            Text(text)
                .font(.DMSans.medium.size(15.0))
            Image(.Icons.arrow)
                .resizable()
                .frame(width: 16.0, height: 16.0)
        }
        .foregroundStyle(Color.ButtonSquare.icon)
        .padding(.leading, 8.0)
        .padding(.trailing, 12.0)
        .frame(height: 32.0)
        .background(Color.ButtonSquare.bg)
        .cornerRadius(16.0)
        .onTapGesture(perform: onTap)
    }
}
