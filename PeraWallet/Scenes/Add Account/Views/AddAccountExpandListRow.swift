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

//   AddAccountExpandListRow.swift

import SwiftUI

struct AddAccountExpandListRow: View {
    
    // MARK: - Body
    
    var body: some View {
        HStack {
            Image(.Icons.arrow)
                .rotationEffect(.degrees(90.0))
                .padding(8.0)
                .foregroundStyle(Color.Text.main)
                .background(Color.Layer.grayLighter)
                .cornerRadius(8.0)
            Text("add-account-expand-row-text")
                .font(.DMSans.medium.size(15.0))
                .foregroundStyle(Color.Text.main)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .defaultPeraRowStyle()
    }
}
