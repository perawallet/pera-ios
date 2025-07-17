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

//   AccountDataProviderTests.swift

@testable import pera_staging
import Testing
import Foundation

@Suite("Data Providers - AccountDataProvider Tests", .serialized, .tags(.accountDataProvider))
struct AccountDataProviderTests {
    
    // MARK: - Constants
    
    private static let testedAddress: String = "VETIGP3I6RCUVLVYNDW5UA2OJMXB5WP6L6HJ3RWO2R37GP4AVETICXC55I"
    private static let authAddress: String = "K4ZUMM5OOPXFCDRP5DKIRQS577GAMB6TKZ4AYEQIZV7OFTJCJ6JAMZWP3A"
    private var testedAddress: String { Self.testedAddress }
    private var authAddress: String { Self.authAddress }
        
    // MARK: - Tests - Account Type

    @Test("Account type for address without private data stored locally")
    func accountTypeForAccountWithoutPrivateData() async throws {
        
        let accountDataProvider = try await makeAccountDataProvider(createPrivateDataForAddress: nil)
        let localAccount = AccountInformation(address: testedAddress, name: "Test Account", isWatchAccount: false, isBackedUp: false)
        
        let result = accountDataProvider.accountType(localAccount: localAccount)
        
        #expect(result == .invalid)
    }

    @Test("Account type for address with private data stored locally")
    func accountTypeForAccountWithPrivateData() async throws {
        
        let accountDataProvider = try await makeAccountDataProvider(createPrivateDataForAddress: testedAddress)
        let localAccount = AccountInformation(address: testedAddress, name: "Test Account", isWatchAccount: false, isBackedUp: false)
        
        let result = accountDataProvider.accountType(localAccount: localAccount)
        
        #expect(result == .algo25)
    }
    
    @Test("Account type for watch account", arguments: [nil, testedAddress, authAddress])
    func accountTypeForWatchAccount(address: String?) async throws {
        
        let accountDataProvider = try await makeAccountDataProvider(createPrivateDataForAddress: address)
        let localAccount = AccountInformation(address: testedAddress, name: "Test Account", isWatchAccount: true, isBackedUp: false)
        
        let result = accountDataProvider.accountType(localAccount: localAccount)
        
        #expect(result == .watch)
    }
    
    @Test("Account type for universal wallet account with private data stored locally")
    func accountTypeForUniversalWalletAccountWithPrivateData() async throws {
        
        let accountDataProvider = try await makeAccountDataProvider(createPrivateDataForAddress: testedAddress)
        let universalWalletDetails = HDWalletAddressDetail(walletId: "123", account: 123, change: 123, keyIndex: 123)
        let localAccount = AccountInformation(address: testedAddress, name: "Test Account", isWatchAccount: false, isBackedUp: false, hdWalletAddressDetail: universalWalletDetails)
        
        let result = accountDataProvider.accountType(localAccount: localAccount)
        
        #expect(result == .universalWallet)
    }
    
    // MARK: - Tests - Authorization Type
    
    @Test("Authorization type for non-rekeyed account", arguments: [nil, testedAddress])
    func authTypeForNonRekeyedAccount(authAddress: String?) async throws {
        
        let accountDataProvider = try await makeAccountDataProvider(createPrivateDataForAddress: nil)
        let indexerAccount = IndexerAccount(address: testedAddress, authAddr: authAddress)
        
        let result = accountDataProvider.authorizationType(indexerAccount: indexerAccount, localAccounts: [])
        
        #expect(result == nil)
    }
    
    @Test("Authorization type for rekeyed account without private data stored locally",
          arguments: [
            [AccountInformation(address: authAddress, name: "Test Account", isWatchAccount: false, isBackedUp: false, hdWalletAddressDetail: nil)],
            []
          ]
    )
    func authTypeForAccountRekeyedWithWalletWithoutPrivateData(localAccounts: [AccountInformation]) async throws {
        
        let accountDataProvider = try await makeAccountDataProvider(createPrivateDataForAddress: nil)
        let indexerAccount = IndexerAccount(address: testedAddress, authAddr: authAddress)
        
        let result = accountDataProvider.authorizationType(indexerAccount: indexerAccount, localAccounts: localAccounts)
        
        #expect(result == .invalid)
    }
    
    @Test("Authorization type for rekeyed account with private data stored locally")
    func authTypeForAccountRekeyedWithWalletWithPrivateData() async throws {
        
        let accountDataProvider = try await makeAccountDataProvider(createPrivateDataForAddress: authAddress)
        let indexerAccount = IndexerAccount(address: testedAddress, authAddr: authAddress)
        
        let localAccount = AccountInformation(address: authAddress, name: "Test Account", isWatchAccount: false, isBackedUp: false, hdWalletAddressDetail: nil)
        let result = accountDataProvider.authorizationType(indexerAccount: indexerAccount, localAccounts: [localAccount])
        
        #expect(result == .wallet)
    }
    
    @Test("Authorization type for rekeyed account using ledger without private data stored locally",
          arguments: [
            [AccountInformation(address: testedAddress, name: "Test Account", isWatchAccount: false, isBackedUp: false, hdWalletAddressDetail: nil)],
            []
          ]
    )
    func authTypeForAccountRekeyedWithLedgerWithoutPrivateData(localAccounts: [AccountInformation]) async throws {
        
        let accountDataProvider = try await makeAccountDataProvider(createPrivateDataForAddress: authAddress)
        let indexerAccount = IndexerAccount(address: testedAddress, authAddr: authAddress)
        
        let result = accountDataProvider.authorizationType(indexerAccount: indexerAccount, localAccounts: localAccounts)
        
        #expect(result == .invalid)
    }
    
    @Test("Authorization type for rekeyed account using ledger with private data stored locally")
    func authTypeForAccountRekeyedWithLedgerWithPrivateData() async throws {
        
        let accountDataProvider = try await makeAccountDataProvider(createPrivateDataForAddress: authAddress)
        let indexerAccount = IndexerAccount(address: testedAddress, authAddr: authAddress)
        
        let ledgerDetails = LedgerDetail(id: nil, name: nil, indexInLedger: 0)
        let localAccount = AccountInformation(address: authAddress, name: "Test Account", isWatchAccount: false, ledgerDetail: ledgerDetails, isBackedUp: false, hdWalletAddressDetail: nil)
        let result = accountDataProvider.authorizationType(indexerAccount: indexerAccount, localAccounts: [localAccount])
        
        #expect(result == .ledger)
    }
    
    // MARK: - Helpers
    
    private func makeAccountDataProvider(removePrivateDataForAddresses: [String] = [testedAddress, authAddress], createPrivateDataForAddress: String?) async throws -> AccountDataProvider {
        let session = try #require(await AppDelegate.shared?.appConfiguration.session)
        
        removePrivateDataForAddresses
            .forEach { session.removePrivateData(for: $0) }
        
        if let createPrivateDataForAddress {
            session.savePrivate(Data(), for: createPrivateDataForAddress)
        }
        return AccountDataProvider(legacySessionManager: session)
    }
}

private extension Tag {
    @Tag static var accountDataProvider: Self
}
