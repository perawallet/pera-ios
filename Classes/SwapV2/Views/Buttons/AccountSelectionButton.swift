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

//   AccountSelectionButton.swift

import SwiftUI

struct AccountSelectionButton: View {
    
    // MARK: - Properties
    @Binding var account: Account?
    
    let onTap: () -> Void
    
    // MARK: - Body
    var body: some View {
        SwiftUI.Button(action: onTap) {
            HStack(spacing: 0) {
                Group {
                    if let account {
                        Image(uiImage: account.typeImage)
                            .resizable()
                    } else {
                        Image("icon-unknown-account")
                            .resizable()
                    }
                }
                .frame(width: 28, height: 28)
                .clipShape(Circle())
                Spacer().frame(width: 8)
                Group {
                    if let account {
                        Text(account.primaryDisplayName)
                    } else {
                        Text("title-select-account")
                    }
                }
                .font(.dmSans.medium.size(13.0))
                .foregroundStyle(Color.Text.gray)
                .frame(minWidth: 85, alignment: .leading)
                Spacer().frame(width: 8)
                Image("icon-dropdown-arrow")
                    .resizable()
                    .frame(width: 16, height: 16)
            }
            .padding(.vertical, 6)
            .padding(.leading, 4)
            .padding(.trailing, 12)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(height: 40)
        .background(
            RoundedRectangle(cornerRadius: 60)
                .fill(Color.Defaults.bg)
                .overlay(
                    RoundedRectangle(cornerRadius: 60)
                        .stroke(Color.Helpers.Gray.gray200, lineWidth: 1)
                )
        )
        .frame(maxWidth: 250)
        .fixedSize(horizontal: true, vertical: false)
        
    }
}
