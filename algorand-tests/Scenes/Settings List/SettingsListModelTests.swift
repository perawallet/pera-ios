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
        let session = try #require(AppDelegate.shared!.appConfiguration.session)
        accountsService = AccountServiceMock()
        settingsListModel = SettingsListModel(accountsService: accountsService, appVersion: appVersion, legacySessionManager: session)
    }
    
    // MARK: - Tests - Accounts that needs backup count
    
    @Test("Accounts that needs backup count for empty wallet")
    func accountsNeedBackupCountForEmptyWallet() async throws {
        
        try await update(accounts: [])
        
        let accountsNeedBackupCountCollection = accountsNeedBackupCountCollection()
        let accountsNeedBackupCount = try #require(accountsNeedBackupCountCollection.first)
        
        #expect(accountsNeedBackupCountCollection.count == 1)
        #expect(accountsNeedBackupCount == 0)
    }
    
    @Test("Accounts that needs backup count for non empty wallet without excluded accounts",
          arguments: [
            [
                PeraAccount(address: "123", type: .algo25, authType: nil),
                PeraAccount(address: "234", type: .algo25, authType: nil),
                PeraAccount(address: "345", type: .algo25, authType: nil),
                PeraAccount(address: "456", type: .algo25, authType: nil),
                PeraAccount(address: "567", type: .algo25, authType: nil)
            ],
            [
                PeraAccount(address: "123", type: .algo25, authType: .wallet),
                PeraAccount(address: "234", type: .algo25, authType: .wallet),
                PeraAccount(address: "345", type: .algo25, authType: .wallet),
                PeraAccount(address: "456", type: .algo25, authType: .wallet),
                PeraAccount(address: "567", type: .algo25, authType: .wallet)
            ],
            [
                PeraAccount(address: "123", type: .algo25, authType: .ledger),
                PeraAccount(address: "234", type: .algo25, authType: .ledger),
                PeraAccount(address: "345", type: .algo25, authType: .ledger),
                PeraAccount(address: "456", type: .algo25, authType: .ledger),
                PeraAccount(address: "567", type: .algo25, authType: .ledger)
            ],
            [
                PeraAccount(address: "123", type: .universalWallet, authType: nil),
                PeraAccount(address: "234", type: .universalWallet, authType: nil),
                PeraAccount(address: "345", type: .universalWallet, authType: nil),
                PeraAccount(address: "456", type: .universalWallet, authType: nil),
                PeraAccount(address: "567", type: .universalWallet, authType: nil)
            ],
            [
                PeraAccount(address: "123", type: .watch, authType: nil),
                PeraAccount(address: "234", type: .watch, authType: nil),
                PeraAccount(address: "345", type: .watch, authType: nil),
                PeraAccount(address: "456", type: .watch, authType: nil),
                PeraAccount(address: "567", type: .watch, authType: nil)
            ],
            [
                PeraAccount(address: "123", type: .algo25, authType: nil),
                PeraAccount(address: "234", type: .universalWallet, authType: .wallet),
                PeraAccount(address: "345", type: .watch, authType: .ledger),
                PeraAccount(address: "456", type: .algo25, authType: nil),
                PeraAccount(address: "567", type: .universalWallet, authType: nil)
            ]
          ]
    )
    func accountsNeedBackupCountForNonEmptyWallet(accounts: [PeraAccount]) async throws {
        
        try await update(accounts: accounts)
        
        let accountsNeedBackupCountCollection = accountsNeedBackupCountCollection()
        let accountsNeedBackupCount = try #require(accountsNeedBackupCountCollection.first)
        
        #expect(accountsNeedBackupCountCollection.count == 1)
        #expect(accountsNeedBackupCount == 5)
    }
    
    @Test("Accounts need backup count for non empty wallet with excluded accounts",
          arguments: [
            [PeraAccount(address: "001", type: .invalid, authType: nil), PeraAccount(address: "002", type: .invalid, authType: nil)],
            [PeraAccount(address: "001", type: .watch, authType: .invalid), PeraAccount(address: "002", type: .watch, authType: .invalid)],
            [PeraAccount(address: "001", type: .invalid, authType: nil), PeraAccount(address: "002", type: .universalWallet, authType: .invalid)]
          ]
    )
    func accountsNeedBackupCountForNonEmptyWalletWithExcludedAccounts(excludedAccounts: [PeraAccount]) async throws {
        
        var accounts = [
            PeraAccount(address: "123", type: .algo25, authType: .wallet),
            PeraAccount(address: "234", type: .algo25, authType: .wallet),
            PeraAccount(address: "345", type: .algo25, authType: .wallet),
            PeraAccount(address: "456", type: .algo25, authType: .wallet),
            PeraAccount(address: "567", type: .algo25, authType: .wallet)
        ]
        
        accounts += excludedAccounts
        try await update(accounts: accounts)
        
        let accountsNeedBackupCountCollection = accountsNeedBackupCountCollection()
        let accountsNeedBackupCount = try #require(accountsNeedBackupCountCollection.first)
        
        #expect(accountsNeedBackupCountCollection.count == 1)
        #expect(accountsNeedBackupCount == 5)
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
    
    private func accountsNeedBackupCountCollection() -> [Int] {
        settingsListModel.viewModel.sections
            .flatMap(\.rows)
            .compactMap {
                switch $0 {
                case let .secureBackup(accountsNeedBackupCount):
                    return accountsNeedBackupCount
                default:
                    return nil
                }
            }
    }
}

private extension String {
    
    static func random(length: UInt) -> Self {
        let chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let collection = (0..<length).compactMap { _ in chars.randomElement() }
        return String(collection)
    }
}
