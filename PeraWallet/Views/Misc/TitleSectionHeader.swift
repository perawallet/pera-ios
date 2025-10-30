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

//   TitleSectionHeader.swift

import SwiftUI

struct TitleSectionHeader: View {

    // MARK: - Properties
    
    let title: String
    
    // MARK: - Body
    
    var body: some View {
        Text(title)
            .font(.DMSans.medium.size(13.0))
            .foregroundStyle(Color.Text.gray)
            .padding(.leading, 24.0)
            .listRowInsets(EdgeInsets())
    }
}
