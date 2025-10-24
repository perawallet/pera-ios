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

//   AccountNameFormatterTests.swift

@testable import pera_staging
import Testing
import pera_wallet_core

@Suite("Formatters - AccountNameFormatter Tests", .tags(.formatter))
struct AccountNameFormatterTests {
    
    // MARK: - Constants
    
    private static let secondaryTitlesForUnnamedAccounts = [
        nil, // algo25
        nil, // universalWallet
        String(localized: "common-account-type-name-watch"), // watch
        String(localized: "common-account-type-name-ledger"), // ledger
        String(localized: "common-account-type-name-joint"), // joint
        String(localized: "common-account-type-name-no-auth"), // invalid
    ]
        
    
    // MARK: - Tests
    
    @Test("Formatting titles for named, non-rekeyed accounts", arguments: PeraAccount.AccountType.allCases)
    func titlesForNamedAccountWithoutRekeying(accountType: PeraAccount.AccountType) {
        
        let address = "123456789012345678901234567890"
        let name = "Name #1"
        
        let localAccount = AccountInformation(address: address, name: name, isWatchAccount: false, isBackedUp: false)
        
        let result = AccountNameFormatter.accountTitles(localAccount: localAccount, accountType: accountType, authorizedAccountType: nil)
        let expectedResult = PeraAccount.Titles(primary: name, secondary: address.shortAddressDisplay)
        
        #expect(result == expectedResult)
    }
    
    @Test("Formatting titles for named, rekeyed accounts with valid authorized account type", arguments: PeraAccount.AccountType.allCases, [PeraAccount.AuthorizedAccountType.algo25, .universalWallet, .ledger])
    func titlesForNamedAccountWithRekeying(accountType: PeraAccount.AccountType, authorizedAccountType: PeraAccount.AuthorizedAccountType) {
        
        let address = "123456789012345678901234567890"
        let name = "Name #1"
        
        let localAccount = AccountInformation(address: address, name: name, isWatchAccount: false, isBackedUp: false)
        
        let result = AccountNameFormatter.accountTitles(localAccount: localAccount, accountType: accountType, authorizedAccountType: authorizedAccountType)
        let expectedResult = PeraAccount.Titles(primary: name, secondary: String(localized: "common-account-type-name-rekeyed"))
        
        #expect(result == expectedResult)
    }
    
    @Test("Formatting titles for named, rekeyed accounts with invalid authorized account type", arguments: PeraAccount.AccountType.allCases)
    func titlesForNamedAccountRekeyedWithInvalidAccount(accountType: PeraAccount.AccountType) {
        
        let address = "123456789012345678901234567890"
        let name = "Name #1"
        
        let localAccount = AccountInformation(address: address, name: name, isWatchAccount: false, isBackedUp: false)
        
        let result = AccountNameFormatter.accountTitles(localAccount: localAccount, accountType: accountType, authorizedAccountType: .invalid)
        let expectedResult = PeraAccount.Titles(primary: name, secondary: String(localized: "common-account-type-name-no-auth"))
        
        #expect(result == expectedResult)
    }
    
    @Test("Formatting titles for unnamed, non-rekeyed accounts", arguments: zip(PeraAccount.AccountType.allCases, secondaryTitlesForUnnamedAccounts))
          func titlesForUnnamedAccountWithoutRekeying(accountType: PeraAccount.AccountType, secondaryTitle: String?) {
        
        let address = "123456789012345678901234567890"
        let name = ""
        
        let localAccount = AccountInformation(address: address, name: name, isWatchAccount: false, isBackedUp: false)
        
        let result = AccountNameFormatter.accountTitles(localAccount: localAccount, accountType: accountType, authorizedAccountType: nil)
        let expectedResult = PeraAccount.Titles(primary: address.shortAddressDisplay, secondary: secondaryTitle)
        
        #expect(result == expectedResult)
    }
    
    @Test("Formatting titles for unnamed, rekeyed accounts with valid authorized account type", arguments: PeraAccount.AccountType.allCases, [PeraAccount.AuthorizedAccountType.algo25, .universalWallet, .ledger])
    func titlesForUnamedAccountWithRekeying(accountType: PeraAccount.AccountType, authorizedAccountType: PeraAccount.AuthorizedAccountType) {
        
        let address = "123456789012345678901234567890"
        let name = ""
        
        let localAccount = AccountInformation(address: address, name: name, isWatchAccount: false, isBackedUp: false)
        
        let result = AccountNameFormatter.accountTitles(localAccount: localAccount, accountType: accountType, authorizedAccountType: authorizedAccountType)
        let expectedResult = PeraAccount.Titles(primary: address.shortAddressDisplay, secondary: String(localized: "common-account-type-name-rekeyed"))
        
        #expect(result == expectedResult)
    }
    
    @Test("Formatting titles for unnamed, rekeyed accounts with invalid authorized account type", arguments: PeraAccount.AccountType.allCases)
    func titlesForUnamedAccountRekeyedWithInvalidAccount(accountType: PeraAccount.AccountType) {
        
        let address = "123456789012345678901234567890"
        let name = ""
        
        let localAccount = AccountInformation(address: address, name: name, isWatchAccount: false, isBackedUp: false)
        
        let result = AccountNameFormatter.accountTitles(localAccount: localAccount, accountType: accountType, authorizedAccountType: .invalid)
        let expectedResult = PeraAccount.Titles(primary: address.shortAddressDisplay, secondary: String(localized: "common-account-type-name-no-auth"))
        
        #expect(result == expectedResult)
    }
    
    @Test("Formatting titles for non-rekeyed accounts with short address as a name", arguments: zip(PeraAccount.AccountType.allCases, secondaryTitlesForUnnamedAccounts))
    func titlesForAccountWithAddressNameWithoutRekeying(accountType: PeraAccount.AccountType, secondaryTitle: String?) {
        
        let address = "123456789012345678901234567890"
        let name = address.shortAddressDisplay
        
        let localAccount = AccountInformation(address: address, name: name, isWatchAccount: false, isBackedUp: false)
        
        let result = AccountNameFormatter.accountTitles(localAccount: localAccount, accountType: accountType, authorizedAccountType: nil)
        let expectedResult = PeraAccount.Titles(primary: address.shortAddressDisplay, secondary: secondaryTitle)
        
        #expect(result == expectedResult)
    }
    
    @Test("Formatting titles for rekeyd accounts with short address as a name and valid authorized account type", arguments: PeraAccount.AccountType.allCases, [PeraAccount.AuthorizedAccountType.algo25, .universalWallet, .ledger])
    func titlesForAccountWithAddressNameAndRekeying(accountType: PeraAccount.AccountType, authorizedAccountType: PeraAccount.AuthorizedAccountType) {
        
        let address = "123456789012345678901234567890"
        let name = address.shortAddressDisplay
        
        let localAccount = AccountInformation(address: address, name: name, isWatchAccount: false, isBackedUp: false)
        
        let result = AccountNameFormatter.accountTitles(localAccount: localAccount, accountType: accountType, authorizedAccountType: authorizedAccountType)
        let expectedResult = PeraAccount.Titles(primary: address.shortAddressDisplay, secondary: String(localized: "common-account-type-name-rekeyed"))
        
        #expect(result == expectedResult)
    }
    
    @Test("Formatting titles for rekeyd accounts with short address as a name and invalid authorized account type", arguments: PeraAccount.AccountType.allCases)
    func titlesForUnamedAccountRekeyedWithAddressNameAndInvalidAccount(accountType: PeraAccount.AccountType) {
        
        let address = "123456789012345678901234567890"
        let name = address.shortAddressDisplay
        
        let localAccount = AccountInformation(address: address, name: name, isWatchAccount: false, isBackedUp: false)
        
        let result = AccountNameFormatter.accountTitles(localAccount: localAccount, accountType: accountType, authorizedAccountType: .invalid)
        let expectedResult = PeraAccount.Titles(primary: address.shortAddressDisplay, secondary: String(localized: "common-account-type-name-no-auth"))
        
        #expect(result == expectedResult)
    }
}
