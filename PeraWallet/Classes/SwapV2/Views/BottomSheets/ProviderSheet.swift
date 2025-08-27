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

enum SelectedProvider: Equatable {
    case auto
    case provider(String)
    
    static func == (lhs: SelectedProvider, rhs: SelectedProvider) -> Bool {
        switch (lhs, rhs) {
        case (.auto, .auto):
            return true
        case let (.provider(a), .provider(b)):
            return a == b
        default:
            return false
        }
    }
    
    var isAuto: Bool {
        switch self {
        case .auto:
            return true
        case .provider:
            return false
        }
    }
    
    var providerId: String {
        switch self {
        case .auto:
            return "auto"
        case let .provider(id):
            return id
        }
    }
}

struct ProviderSheet: View {
    @SwiftUI.Environment(\.dismiss) private var dismiss
    
    var availableProviders: [SwapProviderV2]
    
    var height: CGFloat {
        CGFloat(150 + ((availableProviders.count + 1) * 72))
    }
    
    @State private var selectedProvider: SelectedProvider
    
    let onProviderSelected: (SelectedProvider) -> Void
    
    init(
        availableProviders: [SwapProviderV2],
        selectedProvider: SelectedProvider,
        onProviderSelected: @escaping (SelectedProvider) -> Void
    ) {
        self.availableProviders = availableProviders
        self._selectedProvider = State(initialValue: selectedProvider)
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
                    onProviderSelected(selectedProvider)
                    dismiss()
                }
            }

            List {
                AutoProviderListItem(selectedProvider: $selectedProvider)
                    .onTapGesture {
                        selectedProvider = .auto
                    }
                ForEach(availableProviders, id: \.name) { provider in
                    ProviderListItem(provider: provider, selectedProvider: $selectedProvider)
                        .listRowSeparator(.hidden)
                        .onTapGesture {
                            selectedProvider = .provider(provider.name)
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
    @Binding var selectedProvider: SelectedProvider
    
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
            
            Image(selectedProvider == .provider(provider.name) ? "icon-radio-selected" : "icon-radio-unselected")
                .resizable()
                .frame(width: 24, height: 24)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 64)
    }
}

private struct AutoProviderListItem: View {
    // MARK: - Properties
    @Binding var selectedProvider: SelectedProvider
    
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
            Text("title-best-price-available")
                .font(.dmSans.regular.size(15))
                .foregroundStyle(Color.Text.gray)
            Spacer().frame(width: 16)
            Image(selectedProvider == .auto ? "icon-radio-selected" : "icon-radio-unselected")
                .resizable()
                .frame(width: 24, height: 24)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 64)
    }
}
