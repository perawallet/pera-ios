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

//   SwapSettingsToogle.swift

import SwiftUI

struct SwapSettingsToogle: View {
    
    let title: LocalizedStringKey
    let text: LocalizedStringKey
    
    @Binding var isOn: Bool
    
    var body: some View {
        Text(title)
            .font(.dmSans.regular.size(13))
            .foregroundStyle(Color.Text.gray)
            .frame(maxWidth: .infinity, alignment: .leading)
        
        Spacer().frame(height: 8)
        
        SwiftUI.Toggle(isOn: $isOn) {
            Text(text)
                .font(.dmSans.regular.size(15))
                .foregroundColor(Color.Text.main)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .toggleStyle(SwitchToggleStyle())
        .frame(height: 52)
    }
}
