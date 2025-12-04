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

    // MARK: - Properties
    
    @Binding private var navigationPath: NavigationPath
    private var settings: [SecretDeveloperSettings] = [.enableTestCards]
    @State private var enableTestCards = PeraUserDefaults.enableTestCards ?? false
    
    // MARK: - Initialisers
    
    init(navigationPath: Binding<NavigationPath>) {
        _navigationPath = navigationPath
    }
    
    // MARK: - Setups
    var body: some View {
        List {
            ForEach(settings, id: \.self) { item in
                SecretDevListToggleCell(item: item, isOn: $enableTestCards)
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .onChange(of: enableTestCards) { newValue in
            PeraUserDefaults.enableTestCards = newValue
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarTitle("settings-secret-dev-menu")
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(
                placement: .topBarLeading,
                content: {
                    SwiftUI.Button(action: { navigationPath.removeLast() }) {
                        Image(.iconBack)
                            .foregroundStyle(Color.Text.main)
                    }
                }
            )
        }
    }
}
