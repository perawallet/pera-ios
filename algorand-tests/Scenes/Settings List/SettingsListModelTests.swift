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

//   SettingsListModelTests.swift

@testable import pera_staging
import Testing

@Suite("View Models - SettingsListModelTests Tests", .tags(.settingsList, .model))
struct SettingsListModelTests {
    
    // MARK: - Constants
    
    private let appVersion: String = .random(length: 10)
    
    // MARK: - Properties
    
    private let accountsService: AccountServiceMock
    private let settingsListModel: SettingsListModel
    
    // MARK: - Initialisers
    
    @MainActor
    init() throws {
        accountsService = AccountServiceMock()
        settingsListModel = SettingsListModel(appVersion: appVersion)
    }
    
    // MARK: - Tests - App Version
    
    @Test("Passing the App Version to the View Model")
    func appVersionInViewModel() {
        let result = settingsListModel.viewModel.appVersion
        #expect(result == appVersion)
    }
    
    // MARK: - Helpers
    
    private func update(accounts: [PeraAccount]) async throws {
        accountsService.accountsPublisher.send(accounts)
        try await Task.sleep(for: .milliseconds(10.0))
    }
}

private extension String {
    
    static func random(length: UInt) -> Self {
        let chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let collection = (0..<length).compactMap { _ in chars.randomElement() }
        return String(collection)
    }
}
