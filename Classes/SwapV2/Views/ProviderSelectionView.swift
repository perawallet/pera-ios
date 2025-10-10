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

//   ProviderSelectionView.swift

import SwiftUI

struct ProviderSelectionView: View {
    // MARK: - Properties
    @Binding var selectedProvider: Provider
    let onTap: () -> Void
    
    // MARK: - Body
    var body: some View {
        VStack (alignment: .leading) {
            Text("title-swap-provider")
                .font(.dmSans.regular.size(13.0))
                .foregroundStyle(Color.Text.gray)
            SwiftUI.Button(action: onTap) {
                HStack (alignment: .center) {
                    HStack  (alignment: .center) {
                        $selectedProvider.wrappedValue.icon
                            .frame(width: 16, height: 16)
                        Spacer().frame(width: 4)
                        Text($selectedProvider.wrappedValue.name)
                            .font(.dmSans.regular.size(15))
                            .foregroundStyle(Color.Text.main)
                    }
                    Spacer()
                    Text($selectedProvider.wrappedValue.exchangeRate)
                        .font(.dmSans.regular.size(15))
                        .foregroundStyle(Color.Text.main)
                    Spacer().frame(width: 3)
                    Image("icon-arrow-24")
                        .resizable()
                        .frame(width: 20, height: 20)
                }
            }
            .padding(.top, 8)
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity)
    }
}
