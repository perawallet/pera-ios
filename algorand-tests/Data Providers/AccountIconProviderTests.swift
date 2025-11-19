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

//   AccountIconProviderTests.swift

@testable import pera_staging
import Testing

@Suite("Data Providers - AccountIconProvider Tests", .tags(.dataProvider))
struct AccountIconProviderTests {
    
    // MARK: - Constants
    
    private static let inputAccountTypes: [PeraAccount.AccountType] = [.algo25, .universalWallet, .watch, .ledger, .joint, .invalid]
    private static let inputAuthTypes: [PeraAccount.AuthorizedAccountType] = [.algo25, .universalWallet, .ledger, .invalid]
    
    private static let expectedIconDataForAccountTypes: [ImageType.IconData] = [
        ImageType.IconData(image: .Icons.wallet, tintColor: .Wallet.wallet4Icon, backgroundColor: .Wallet.wallet4), // algo25
        ImageType.IconData(image: .Icons.walletUniversal, tintColor: .Wallet.wallet4Icon, backgroundColor: .Wallet.wallet4),  // universalWallet
        ImageType.IconData(image: .Icons.watchAccount, tintColor: .Wallet.wallet1Icon, backgroundColor: .Wallet.wallet1), // watch
        ImageType.IconData(image: .Icons.ledger, tintColor: .Wallet.wallet3Icon, backgroundColor: .Wallet.wallet3), // ledger
        ImageType.IconData(image: .Icons.group, tintColor: .Wallet.wallet1, backgroundColor: .Wallet.wallet1Icon), // joint
        ImageType.IconData(image: .Icons.rekeyedAccount, tintColor: .Helpers.negative, backgroundColor: .Helpers.negativeLighter) // invalid
    ]
    
    private static let normalWalletExpectedIconDataForAuthTypes: [ImageType.IconData] = [
        ImageType.IconData(image: .Icons.rekeyedAccount, tintColor: .Wallet.wallet4Icon, backgroundColor: .Wallet.wallet4), // algo25
        ImageType.IconData(image: .Icons.rekeyedAccount, tintColor: .Wallet.wallet4Icon, backgroundColor: .Wallet.wallet4),  // universalWallet
        ImageType.IconData(image: .Icons.rekeyedAccount, tintColor: .Wallet.wallet3Icon, backgroundColor: .Wallet.wallet3), // ledger
        ImageType.IconData(image: .Icons.rekeyedAccount, tintColor: .Helpers.negative, backgroundColor: .Helpers.negativeLighter) // invalid
    ]
    
    private static let otherAccountTypeExpectedIconDataForAuthTypes: [ImageType.IconData] = [
        ImageType.IconData(image: .Icons.rekeyedAccount, tintColor: .Wallet.wallet1Icon, backgroundColor: .Wallet.wallet1), // algo25
        ImageType.IconData(image: .Icons.rekeyedAccount, tintColor: .Wallet.wallet1Icon, backgroundColor: .Wallet.wallet1),  // universalWallet
        ImageType.IconData(image: .Icons.rekeyedAccount, tintColor: .Wallet.wallet1Icon, backgroundColor: .Wallet.wallet1), // ledger
        ImageType.IconData(image: .Icons.rekeyedAccount, tintColor: .Helpers.negative, backgroundColor: .Helpers.negativeLighter) // invalid
    ]
    
    // MARK: - Tests
    
    @Test("Icon data for different account types", arguments: zip(inputAccountTypes, expectedIconDataForAccountTypes))
    func iconDataForAccountType(accountType: PeraAccount.AccountType, expectedIconData: ImageType.IconData) {
        
        let peraAccount = PeraAccount(
            address: "",
            type: accountType,
            authType: nil,
            amount: 0.0,
            titles: PeraAccount.Titles(primary: "", secondary: nil),
            sortingIndex: .random(in: 0...100)
        )
        
        let result = AccountIconProvider.iconData(account: peraAccount)
        #expect(result == expectedIconData)
    }
    
    @Test("Icon data for Algo25 account and different auth types", arguments: zip(inputAuthTypes, normalWalletExpectedIconDataForAuthTypes))
    func algo25IconDataForAuthType(authType: PeraAccount.AuthorizedAccountType, expectedIconData: ImageType.IconData) {
            
        let peraAccount = PeraAccount(
            address: "",
            type: .algo25,
            authType: authType,
            amount: 0.0,
            titles: PeraAccount.Titles(primary: "", secondary: nil),
            sortingIndex: .random(in: 0...100)
        )
        
        let result = AccountIconProvider.iconData(account: peraAccount)
        #expect(result == expectedIconData)
    }
    
    @Test("Icon data for Universal Wallet account and different auth types", arguments: zip(inputAuthTypes, normalWalletExpectedIconDataForAuthTypes))
    func universalWalletIconDataForAuthType(authType: PeraAccount.AuthorizedAccountType, expectedIconData: ImageType.IconData) {
            
        let peraAccount = PeraAccount(
            address: "",
            type: .universalWallet,
            authType: authType,
            amount: 0.0,
            titles: PeraAccount.Titles(primary: "", secondary: nil),
            sortingIndex: .random(in: 0...100)
        )
        
        let result = AccountIconProvider.iconData(account: peraAccount)
        #expect(result == expectedIconData)
    }
    
    @Test("Icon data for Watch account and different auth types", arguments: zip(inputAuthTypes, otherAccountTypeExpectedIconDataForAuthTypes))
    func watchAccountIconDataForAuthType(authType: PeraAccount.AuthorizedAccountType, expectedIconData: ImageType.IconData) {
            
        let peraAccount = PeraAccount(
            address: "",
            type: .watch,
            authType: authType,
            amount: 0.0,
            titles: PeraAccount.Titles(primary: "", secondary: nil),
            sortingIndex: .random(in: 0...100)
        )
        
        let result = AccountIconProvider.iconData(account: peraAccount)
        #expect(result == expectedIconData)
    }
    
    @Test("Icon data for Ledger account and different auth types", arguments: zip(inputAuthTypes, otherAccountTypeExpectedIconDataForAuthTypes))
    func ledgerAccountIconDataForAuthType(authType: PeraAccount.AuthorizedAccountType, expectedIconData: ImageType.IconData) {
            
        let peraAccount = PeraAccount(
            address: "",
            type: .watch,
            authType: authType,
            amount: 0.0,
            titles: PeraAccount.Titles(primary: "", secondary: nil),
            sortingIndex: .random(in: 0...100)
        )
        
        let result = AccountIconProvider.iconData(account: peraAccount)
        #expect(result == expectedIconData)
    }
    
    @Test("Icon data for Joint account and different auth types", arguments: zip(inputAuthTypes, otherAccountTypeExpectedIconDataForAuthTypes))
    func jointAccountIconDataForAuthType(authType: PeraAccount.AuthorizedAccountType, expectedIconData: ImageType.IconData) {
            
        let peraAccount = PeraAccount(
            address: "",
            type: .watch,
            authType: authType,
            amount: 0.0,
            titles: PeraAccount.Titles(primary: "", secondary: nil),
            sortingIndex: .random(in: 0...100)
        )
        
        let result = AccountIconProvider.iconData(account: peraAccount)
        #expect(result == expectedIconData)
    }
    
    @Test("Icon data for Invalid account and different auth types", arguments: zip(inputAuthTypes, otherAccountTypeExpectedIconDataForAuthTypes))
    func invalidAccountIconDataForAuthType(authType: PeraAccount.AuthorizedAccountType, expectedIconData: ImageType.IconData) {
            
        let peraAccount = PeraAccount(
            address: "",
            type: .watch,
            authType: authType,
            amount: 0.0,
            titles: PeraAccount.Titles(primary: "", secondary: nil),
            sortingIndex: .random(in: 0...100)
        )
        
        let result = AccountIconProvider.iconData(account: peraAccount)
        #expect(result == expectedIconData)
    }
}
