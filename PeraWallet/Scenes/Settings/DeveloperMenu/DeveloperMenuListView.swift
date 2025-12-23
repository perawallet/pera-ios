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

//   DeveloperMenuListView.swift

import SwiftUI
import pera_wallet_core

struct DeveloperMenuListView: View {
    
    struct LogsMetadata: Identifiable {
        let id: UUID = UUID()
        let url: URL
    }

    // MARK: - Properties
    
    var onBackPressed: (() -> Void)?
    
    @ObservedObject var model: DeveloperMenuModel
    @State private var enableTestCards = PeraUserDefaults.enableTestCards ?? false
    
    @State private var logsMetadata: LogsMetadata?
    
    private let logger: PeraLogger = .shared
    
    
    // MARK: - Setups
    var body: some View {
        ZStack {
            List {
                ForEach(model.settings, id: \.self) { item in
                    switch item {
                    case .enableTestCards:
                        DeveloperMenuListToggleCell(item: item, isOn: $enableTestCards)
                            .listRowSeparator(.hidden)
                    case .overrideRemoteConfig:
                        NavigationLink(destination: RemoteConfigListView(model: model)) {
                            DeveloperMenuListNavigationCell(item: item)
                        }
                        .listRowSeparator(.hidden)
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .onChange(of: enableTestCards) { newValue in
                PeraUserDefaults.enableTestCards = newValue
            }
            VStack {
                Spacer()
                RoundedButton(text: "settings-secret-dev-menu-export-logs", style: .primary, isEnabled: true) {
                    createLogsFile()
                }
                FormButton(text: "disable-dev-options-title", style: .primary) {
                    PeraUserDefaults.shouldShowDevMenu = false
                    onBackPressed?()
                }
            }
            .padding(24.0)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarTitle("settings-secret-dev-menu")
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(
                placement: .topBarLeading,
                content: {
                    SwiftUI.Button(action: { onBackPressed?() }) {
                        Image(.iconBack)
                            .foregroundStyle(Color.Text.main)
                    }
                }
            )
        }
        .sheet(item: $logsMetadata) {
            ShareSheet(activityItems: [$0.url])
        }
    }
    
    private func onShareSheetDismissAction() {
        Task {
            try? await logger.deleteExportedLogsFile()
        }
    }
    
    private func createLogsFile() {
        Task {
            guard let fileURL = try? await logger.createLogsFile() else { return }
            logsMetadata = LogsMetadata(url: fileURL)
        }
    }
}
