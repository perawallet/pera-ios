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

//   ProviderSheet.swift

import SwiftUI
import pera_wallet_core

struct ProviderSheet: View {
    @SwiftUI.Environment(\.dismiss) private var dismiss
    
    var availableProviders: [SwapProviderV2]
    
    var height: CGFloat {
        CGFloat(150 + ((availableProviders.count + 1) * 72))
    }
    
    @State private var selectedProviderID: String
    
    let onProviderSelected: (String) -> Void
    
    init(
        availableProviders: [SwapProviderV2],
        selectedProviderID: String,
        onProviderSelected: @escaping (String) -> Void
    ) {
        self.availableProviders = availableProviders
        self._selectedProviderID = State(initialValue: selectedProviderID)
        self.onProviderSelected = onProviderSelected
    }


    var body: some View {
        VStack(spacing: 0) {
            SheetTitleView(title: "title-change-provider") { action in
                switch action {
                case .dismiss:
                    dismiss()
                case .apply:
                    guard availableProviders.count > 0 else {
                        dismiss()
                        return
                    }

                    onProviderSelected(selectedProviderID)
                    
                    dismiss()
                }
            }

            List {
                AutoProviderListItem(selectedProviderID: $selectedProviderID)
                    .onTapGesture {
                        selectedProviderID = "auto"
                    }
                ForEach(availableProviders, id: \.name) { provider in
                    ProviderListItem(provider: provider, selectedProviderID: $selectedProviderID)
                        .listRowSeparator(.hidden)
                        .onTapGesture {
                            selectedProviderID = provider.name
                        }
                }
            }
            .listStyle(.plain)
            .listRowSpacing(8)
            .scrollDisabled(true)
            Spacer()
        }
        .background(Color.Defaults.bg)
        .presentationDetents([.height(height)])
        .presentationDragIndicator(.hidden)
    }
    
    
}


private struct ProviderListItem: View {
    // MARK: - Properties
    var provider: SwapProviderV2
    @Binding var selectedProviderID: String
    
    // MARK: - Body
    var body: some View {
        HStack (alignment: .center) {
            Image("icon-verified")
                .resizable()
                .frame(width: 40, height: 40)
                .clipShape(Circle())
            Spacer().frame(width: 16)
            Text(provider.displayName)
                .font(.dmSans.regular.size(15))
                .foregroundStyle(Color.Text.main)
            Spacer()
            Image(selectedProviderID == provider.name ? "icon-radio-selected" : "icon-radio-unselected")
                .resizable()
                .frame(width: 24, height: 24)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 64)
    }
}

private struct AutoProviderListItem: View {
    // MARK: - Properties
    @Binding var selectedProviderID: String
    
    // MARK: - Body
    var body: some View {
        HStack (alignment: .center) {
            Image("icon-sparkles")
                .resizable()
                .padding(8)
                .frame(width: 40, height: 40)
                .background(Circle().fill(Color.Wallet.wallet4))
                .clipShape(Circle())
            Spacer().frame(width: 16)
            Text("title-auto")
                .font(.dmSans.regular.size(15))
                .foregroundStyle(Color.Text.main)
            Spacer()
            Image(selectedProviderID == "auto" ? "icon-radio-selected" : "icon-radio-unselected")
                .resizable()
                .frame(width: 24, height: 24)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 64)
    }
}
