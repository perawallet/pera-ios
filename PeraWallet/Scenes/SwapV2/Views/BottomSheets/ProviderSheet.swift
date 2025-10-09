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

    @StateObject var viewModel: ProviderSheetViewModel
    let onProviderSelected: (SelectedProvider) -> Void
    let onAnalyticsEvent: (SwapAnalyticsEvent) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            SheetTitleView(title: "title-change-provider") { action in
                switch action {
                case .dismiss:
                    onAnalyticsEvent(.swapSelectProviderClose)
                    dismiss()
                case .apply:
                    guard viewModel.availableProviders.isNonEmpty else {
                        dismiss()
                        return
                    }
                    onProviderSelected(viewModel.selectedProvider)
                    dismiss()
                }
            }
            .padding(.horizontal, 24)

            List {
                AutoProviderListItem(selectedProvider: $viewModel.selectedProvider)
                    .onTapGesture {
                        viewModel.selectedProvider = .auto
                    }
                ForEach(viewModel.availableProviders, id: \.name) { provider in
                    ProviderListItem(
                        provider: provider,
                        quotePrimaryValue: viewModel.quotePrimaryValue(for: provider.name),
                        quoteSecondaryValue: viewModel.quoteSecondaryValue(for: provider.name),
                        selectedProvider: $viewModel.selectedProvider
                    )
                    .listRowSeparator(.hidden)
                    .onTapGesture {
                        viewModel.selectedProvider = .provider(provider.name)
                        onAnalyticsEvent(.swapSelectProviderRouter(name: provider.name))
                    }
                }
            }
            .listStyle(.plain)
            .listRowSpacing(8)
            .scrollDisabled(true)
            Spacer()
        }
        .background(Color.Defaults.bg)
        .presentationDetents([.height(viewModel.height)])
        .presentationDragIndicator(.hidden)
    }
}

private struct ProviderListItem: View {
    // MARK: - Properties
    var provider: SwapProviderV2
    var quotePrimaryValue: String
    var quoteSecondaryValue: String
    @Binding var selectedProvider: SelectedProvider
    
    // MARK: - Body
    var body: some View {
        HStack (alignment: .center) {            
            if let url = URL(string: provider.iconUrl) {
                AsyncImage(url: url) { image in
                    image.resizable()
                } placeholder: {
                    EmptyView()
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                Spacer().frame(width: 16)
            }
            
            Text(provider.displayName)
                .font(.dmSans.regular.size(15))
                .foregroundStyle(Color.Text.main)
            Spacer()
            VStack(alignment: .trailing, spacing: 0) {
                Text(quotePrimaryValue)
                    .font(.dmSans.regular.size(15))
                    .foregroundStyle(Color.Text.main)
                Text(quoteSecondaryValue)
                    .font(.dmSans.regular.size(13))
                    .foregroundStyle(Color.Text.gray)
            }
            Spacer().frame(width: 16)
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
            Image(.iconSparkles)
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
