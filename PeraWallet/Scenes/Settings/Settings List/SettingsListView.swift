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

//   SettingsListView.swift

import SwiftUI
import pera_wallet_core

struct SettingsListView: View {
    
    enum LegacyNavigationOption {
        case back
        case security
        case contacts
        case notifications
        case walletConnect
        case currency
        case theme
        case rateApp
        case developer
    }
    
    private enum NavigationOption {
        case help
        case termsAndServices
        case privacyPolicy
    }
    
    // MARK: - Properties
    
    private let model: SettingsListModelable
    
    @ObservedObject private var viewModel: SettingsListViewModel
    @State private var navigationPath = NavigationPath()
    
    // MARK: - UIKit Compatibility
    
    var onLegacyNavigationOptionSelected: ((LegacyNavigationOption) -> Void)?
    var onLogoutButtonTap: (() -> Void)?
    
    // MARK: - Initialisers
    
    init(model: SettingsListModelable) {
        self.model = model
        self.viewModel = model.viewModel
        setupStyles()
    }
    
    // MARK: - Setups
    
    private func setupStyles() {
        NavigationBarStyle.applyStyle()
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            List {
                ForEach(viewModel.sections) { section in
                    Section(header: ListSectionHeader(text: section.title)) {
                        ForEach(section.rows) { row in
                            SettingsListCell(icon: row.icon, title: row.title)
                                .settingsViewRowStyle()
                                .contentShape(Rectangle())
                                .onTapGesture { handleTapOnRow(row: row) }
                        }
                    }
                }
                RoundedButton(text: "settings-logout-title") { onLogoutButtonTap?() }
                    .settingsViewRowStyle()
                    .padding(.horizontal, 24.0)
                Text("settings-app-version-\(viewModel.appVersion)")
                    .settingsViewRowStyle()
                    .frame(maxWidth: .infinity)
                    .font(.dmSans.regular.size(13.0))
                    .foregroundStyle(Color.Text.grayLighter)
            }
            .listStyle(.grouped)
            .listSectionSeparator(.hidden)
            .scrollContentBackground(.hidden)
            .background(Color.Defaults.bg)
            .navigationTitle("title-settings")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: NavigationOption.self) {
                buildView(option: $0)
                    .navigationBarHidden(true)
                    .ignoresSafeArea(edges: .top)
            }
            .toolbar {
                ToolbarItem(
                    placement: .topBarLeading,
                    content: {
                        SwiftUI.Button(action: handleBackButtonTap) {
                            Image(.iconBack)
                                .foregroundStyle(Color.Text.main)
                        }
                    }
                )
            }
        }
    }
    
    // MARK: - Actions
    
    private func moveTo(option: NavigationOption) {
        navigationPath.append(option)
    }
    
    // MARK: - Handlers
    
    private func handleTapOnRow(row: SettingsListViewModel.Row) {
        switch row {
        case .security:
            onLegacyNavigationOptionSelected?(.security)
        case .contacts:
            onLegacyNavigationOptionSelected?(.contacts)
        case .notifications:
            onLegacyNavigationOptionSelected?(.notifications)
        case .walletConnect:
            onLegacyNavigationOptionSelected?(.walletConnect)
        case .currency:
            onLegacyNavigationOptionSelected?(.currency)
        case .theme:
            onLegacyNavigationOptionSelected?(.theme)
        case .help:
            moveTo(option: .help)
        case .rateApp:
            onLegacyNavigationOptionSelected?(.rateApp)
        case .termsAndServices:
            moveTo(option: .termsAndServices)
        case .privacyPolicy:
            moveTo(option: .privacyPolicy)
        case .developer:
            onLegacyNavigationOptionSelected?(.developer)
        }
    }
    
    private func handleBackButtonTap() {
        onLegacyNavigationOptionSelected?(.back)
    }
    
    // MARK: - View Builders
    
    @ViewBuilder
    private func buildView(option: NavigationOption) -> some View {
        switch option {
        case .help:
            buildWebView(link: AlgorandWeb.support.link)
        case .termsAndServices:
            buildWebView(link: AlgorandWeb.termsAndServices.link)
        case .privacyPolicy:
            buildWebView(link: AlgorandWeb.privacyPolicy.link)
        }
    }
    
    @ViewBuilder
    private func buildWebView(link: URL?) -> some View {
        if let link {
            WebView(url: link)
        }
    }
}

#Preview {
    SettingsListView(model: MockedSettingsListModel())
}

// MARK: - Mocks

final class MockedSettingsListModel: SettingsListModelMockable {
    
    var viewModel: SettingsListViewModel = SettingsListViewModel()
    
    init() {
        update(sections: [
            .accountSection,
            .appPreferencesSection,
            .supportSection
        ])
        update(appVersion: "1.2.3 - Mock")
    }
}
