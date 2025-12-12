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

//   SecretDevListView.swift

import SwiftUI
import pera_wallet_core

struct SecretDevListView: View {

    private enum NavigationOption {
        case logs
    }
    
    // MARK: - Properties
    
    @Binding private var navigationPath: NavigationPath
    private var settings: [SecretDeveloperSettings] = [.enableTestCards]
    @State private var enableTestCards = PeraUserDefaults.enableTestCards ?? false
    @State private var enableTestXOSwapPage = PeraUserDefaults.enableTestXOSwapPage ?? false
    
    // MARK: - Initialisers
    
    init(navigationPath: Binding<NavigationPath>) {
        _navigationPath = navigationPath
        if AppEnvironment.current.isTestNet {
            settings.append(.enableTestXOSwapPage)
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        List(settings, id: \.self) { item in
                switch item {
                case .enableTestCards:
                    SecretDevListToggleCell(item: item, isOn: $enableTestCards)
                    .listRowSeparator(.hidden)
                case .enableTestXOSwapPage:
                    SecretDevListToggleCell(item: item, isOn: $enableTestXOSwapPage)
                    .listRowSeparator(.hidden)
                }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .onChange(of: enableTestCards) { newValue in
            PeraUserDefaults.enableTestCards = newValue
        }
        .onChange(of: enableTestXOSwapPage) { newValue in
            PeraUserDefaults.enableTestXOSwapPage = newValue
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarTitle("settings-secret-dev-menu")
        .navigationBarBackButtonHidden()
        .navigationDestination(for: NavigationOption.self) {
            buildView(option: $0)
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                SwiftUI.Button(action: { navigationPath.removeLast() }) {
                    Image(.iconBack)
                        .foregroundStyle(Color.Text.main)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Image(systemName: "list.bullet.rectangle")
                    .onTapGesture { moveTo(option: .logs) }
            }
        }
    }
    
    // MARK: - View Builders
    
    @ViewBuilder
    private func buildView(option: NavigationOption) -> some View {
        switch option {
        case .logs:
            LogsView(navigationPath: $navigationPath)
        }
    }
    
    // MARK: - Actions
    
    private func moveTo(option: NavigationOption) {
        navigationPath.append(option)
    }
}
