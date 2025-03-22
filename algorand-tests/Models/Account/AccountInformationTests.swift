// Copyright 2022 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//  AccountInformationTests.swift

import XCTest

@testable import pera_staging

class AccountInformationTests: XCTestCase {

    private let account = Bundle.main.decode(AccountInformation.self, from: "AccountInformationA.json")
    
    func testInitialization() {
        // Given
        let hdWalletAddressDetail = HDWalletAddressDetail(
            walletId: "1",
            account: 0,
            change: 0,
            keyIndex: 0)
        
        
        let account = AccountInformation(
            address: "test-address",
            name: "Test Account",
            isWatchAccount: false,
            ledgerDetail: nil,
            rekeyDetail: nil,
            receivesNotification: false,
            preferredOrder: 3,
            isBackedUp: true,
            hdWalletAddressDetail: hdWalletAddressDetail
        )

        // Then
        XCTAssertEqual(account.address, "test-address")
        XCTAssertEqual(account.name, "Test Account")
        XCTAssertFalse(account.isWatchAccount)
        XCTAssertNil(account.ledgerDetail)
        XCTAssertNil(account.rekeyDetail)
        XCTAssertFalse(account.receivesNotification)
        XCTAssertEqual(account.preferredOrder, 3)
        XCTAssertTrue(account.isBackedUp)
        XCTAssertNotNil(account.hdWalletAddressDetail)
    }
    
    func testDecodingWithAllFields() throws {
        // Given
        let json = """
        {
            "address": "test-address",
            "name": "Test Account",
            "type": "standard",
            "receivesNotification": false,
            "preferredOrder": 5,
            "isBackedUp": true
        }
        """.data(using: .utf8)!

        // When
        let decodedAccount = try JSONDecoder().decode(AccountInformation.self, from: json)

        // Then
        XCTAssertEqual(decodedAccount.address, "test-address")
        XCTAssertEqual(decodedAccount.name, "Test Account")
        XCTAssertFalse(decodedAccount.receivesNotification)
        XCTAssertEqual(decodedAccount.preferredOrder, 5)
        XCTAssertTrue(decodedAccount.isBackedUp)
        XCTAssertNil(decodedAccount.hdWalletAddressDetail)
    }
    
    func testUpdateName() {
        // Given
        let account = AccountInformation(
            address: "test-address",
            name: "Old Account Name",
            isWatchAccount: false,
            isBackedUp: true
        )
        
        // When
        account.updateName("New Account Name")
        
        // Then
        XCTAssertEqual(account.name, "New Account Name")
    }
    
    func testAddRekeyDetail() {
        // Given
        let accountB = Bundle.main.decode(response: Account.self, from: "AccountA.json")
        let ledgerDetail = Bundle.main.decode(LedgerDetail.self, from: "LedgerDetail.json")
        
        // When
        account.addRekeyDetail(ledgerDetail, for: accountB.address)
        
        // Then
        XCTAssertNotNil(account.rekeyDetail)
    }
}
